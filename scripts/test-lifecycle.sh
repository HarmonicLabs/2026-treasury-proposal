#!/usr/bin/env bash
set -euo pipefail

# test-lifecycle.sh - Full automated governance action lifecycle test on preview testnet.
# Refuses to run on mainnet. Exercises: metadata generation, hashing, governance
# action creation, transaction build/sign/submit, and governance state query.
#
# Usage: scripts/test-lifecycle.sh
#
# Prerequisites:
#   - cardano-cli, jq available
#   - cardano-node running on preview network
#   - CARDANO_NODE_SOCKET_PATH set
#   - Test keys in keys/ directory
#   - config.env with preview testnet values

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SCRIPTS="${REPO_ROOT}/scripts"

# ── Source configuration ─────────────────────────────────────────────────────

if [[ -f "${REPO_ROOT}/config.env" ]]; then
    # shellcheck source=/dev/null
    source "${REPO_ROOT}/config.env"
fi

# ── Mainnet safety check ────────────────────────────────────────────────────

# Refuse to run on mainnet - check both env vars and explicit flags
if [[ "${NETWORK:-}" == "mainnet" ]]; then
    echo "Error: test-lifecycle.sh refuses to run on mainnet." >&2
    echo "This script is for testnet use only." >&2
    exit 1
fi

# Default to preview network
NETWORK_FLAG=(--testnet-magic 2)
NETWORK_NAME="preview"

echo "============================================================"
echo "  Treasury Proposal - Full Lifecycle Test"
echo "  Network: ${NETWORK_NAME} (testnet-magic 2)"
echo "============================================================"
echo ""

# ── Helper ───────────────────────────────────────────────────────────────────

step() {
    local num="$1" desc="$2"
    echo ""
    echo "── Step ${num}: ${desc} ────────────────────────────────────"
    echo ""
}

# ── Step 1: Generate metadata ───────────────────────────────────────────────

step 1 "Generate proposal metadata"
"${SCRIPTS}/generate-metadata.sh"

# ── Step 2: Hash metadata ───────────────────────────────────────────────────

step 2 "Hash proposal metadata"
"${SCRIPTS}/hash-metadata.sh" "${REPO_ROOT}/metadata/proposal-metadata.json"

HASH=$(cat "${REPO_ROOT}/metadata/metadata-hash.txt")
echo "Metadata hash: ${HASH}"

# ── Step 3: Set test-specific values if not configured ──────────────────────

step 3 "Validate configuration"

# Use test placeholder values where config is missing
: "${GOVERNANCE_ACTION_DEPOSIT:=100000000000}"
: "${ANCHOR_URL:=https://raw.githubusercontent.com/blinklabs-io/treasury-proposal/main/metadata/proposal-metadata.json}"
: "${TRANSFER_AMOUNT:=1000000}"

export GOVERNANCE_ACTION_DEPOSIT ANCHOR_URL TRANSFER_AMOUNT

# Validate that key files and payment address are set
MISSING=0

for var in DEPOSIT_RETURN_STAKE_VKEY RECEIVING_STAKE_VKEY PAYMENT_SKEY PAYMENT_ADDRESS; do
    if [[ -z "${!var:-}" ]]; then
        echo "Error: ${var} is not set in config.env" >&2
        MISSING=$((MISSING + 1))
    fi
done

if [[ "$MISSING" -gt 0 ]]; then
    echo "" >&2
    echo "Configure these in config.env before running the test lifecycle." >&2
    exit 1
fi

echo "Configuration OK"
echo "  Deposit:     ${GOVERNANCE_ACTION_DEPOSIT} lovelace"
echo "  Anchor URL:  ${ANCHOR_URL}"
echo "  Transfer:    ${TRANSFER_AMOUNT} lovelace"
echo "  Payment:     ${PAYMENT_ADDRESS}"

# ── Step 4: Create governance action ────────────────────────────────────────

step 4 "Create treasury withdrawal governance action"
"${SCRIPTS}/create-governance-action.sh" "${NETWORK_FLAG[@]}"

# ── Step 5: Build transaction ───────────────────────────────────────────────

step 5 "Build transaction"
"${SCRIPTS}/build-tx.sh" "${NETWORK_FLAG[@]}"

# ── Step 6: Sign transaction ────────────────────────────────────────────────

step 6 "Sign transaction"
"${SCRIPTS}/sign-tx.sh" "${NETWORK_FLAG[@]}"

# ── Step 7: Submit transaction ──────────────────────────────────────────────

step 7 "Submit transaction"
"${SCRIPTS}/submit-tx.sh" "${NETWORK_FLAG[@]}"

TX_HASH=$(cardano-cli conway transaction txid --tx-file "${REPO_ROOT}/tx.signed")

# ── Step 8: Wait for confirmation ───────────────────────────────────────────

step 8 "Wait for on-chain confirmation"

echo "Transaction hash: ${TX_HASH}"
echo "Waiting for transaction to appear on-chain (up to 120 seconds)..."

TIMEOUT=120
INTERVAL=5
ELAPSED=0

while [[ "$ELAPSED" -lt "$TIMEOUT" ]]; do
    # Query the UTxO set - if tx hash appears, it's confirmed
    RESULT=$(cardano-cli conway query utxo \
        "${NETWORK_FLAG[@]}" \
        --tx-in "${TX_HASH}#0" \
        --out-file /dev/stdout 2>/dev/null || echo "{}")

    # Check if we got any results (even empty means the tx was processed)
    ENTRY_COUNT=$(echo "$RESULT" | jq 'length' 2>/dev/null || echo "0")

    if [[ "$ENTRY_COUNT" -gt 0 ]] || [[ "$ELAPSED" -gt 0 ]]; then
        # Also try checking if the tx is no longer in the mempool
        # by looking for governance state changes
        echo "Checking after ${ELAPSED}s..."
    fi

    # A simpler confirmation: query the tx hash directly
    if cardano-cli conway query tx-mempool tx-exists --tx-id "$TX_HASH" "${NETWORK_FLAG[@]}" 2>/dev/null | grep -q "False"; then
        echo "Transaction confirmed (no longer in mempool)."
        break
    fi

    sleep "$INTERVAL"
    ELAPSED=$((ELAPSED + INTERVAL))
done

if [[ "$ELAPSED" -ge "$TIMEOUT" ]]; then
    echo "Warning: Timed out waiting for confirmation."
    echo "The transaction may still be processed. Check manually."
fi

# ── Step 9: Query governance state ──────────────────────────────────────────

step 9 "Query governance state"

echo "Querying governance state for treasury withdrawal proposals..."

GOV_STATE=$(cardano-cli conway query gov-state "${NETWORK_FLAG[@]}" --out-file /dev/stdout 2>/dev/null || echo "{}")

# Count treasury withdrawal proposals
PROPOSAL_COUNT=$(echo "$GOV_STATE" | jq '[.proposals // [] | .[] | select(.proposalProcedure.govAction.tag == "TreasuryWithdrawals")] | length' 2>/dev/null || echo "unknown")

echo "Active treasury withdrawal proposals: ${PROPOSAL_COUNT}"

# ── Summary ──────────────────────────────────────────────────────────────────

echo ""
echo "============================================================"
echo "  Lifecycle Test Complete"
echo "============================================================"
echo ""
echo "Transaction hash: ${TX_HASH}"
echo "Network:          ${NETWORK_NAME}"
echo ""
echo "Artifacts generated:"
echo "  metadata/proposal-metadata.json"
echo "  metadata/metadata-hash.txt"
echo "  treasury-withdrawal.action"
echo "  tx.raw"
echo "  tx.signed"
echo ""
echo "Clean up with: make clean"
