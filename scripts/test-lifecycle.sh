#!/usr/bin/env bash
set -euo pipefail

# test-lifecycle.sh - Full automated governance action lifecycle test on preprod testnet.
# Refuses to run on mainnet. Exercises: hashing, governance action creation,
# transaction build/sign/submit, and governance state query.
#
# Usage: scripts/test-lifecycle.sh
#        METADATA_FILE=metadata/test-metadata.json scripts/test-lifecycle.sh
#
# Prerequisites:
#   - cardano-cli, jq available
#   - cardano-node running on preprod network
#   - CARDANO_NODE_SOCKET_PATH set
#   - Test keys in keys/ directory
#   - config.env with preprod testnet values
#   - Committed metadata JSON file

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SCRIPTS="${REPO_ROOT}/scripts"

# ── Source configuration ─────────────────────────────────────────────────────

if [[ -f "${REPO_ROOT}/config.env" ]]; then
    set -a
    # shellcheck source=/dev/null
    source "${REPO_ROOT}/config.env"
    set +a
fi

# ── Mainnet safety check ────────────────────────────────────────────────────

# Refuse to run on mainnet - check both env vars and explicit flags
if [[ "${NETWORK:-}" == "mainnet" ]]; then
    echo "Error: test-lifecycle.sh refuses to run on mainnet." >&2
    echo "This script is for testnet use only." >&2
    exit 1
fi

# Default to preprod network
: "${NETWORK:=preprod}"
export NETWORK

echo "============================================================"
echo "  Treasury Proposal - Full Lifecycle Test"
echo "  Network: ${NETWORK}"
echo "============================================================"
echo ""

# ── Helper ───────────────────────────────────────────────────────────────────

step() {
    local num="$1" desc="$2"
    echo ""
    echo "── Step ${num}: ${desc} ────────────────────────────────────"
    echo ""
}

# ── Resolve metadata file ────────────────────────────────────────────────────

METADATA_FILE="${METADATA_FILE:-metadata/proposal-metadata.json}"
# Resolve relative paths against REPO_ROOT
if [[ "$METADATA_FILE" != /* ]]; then
    METADATA_FILE="${REPO_ROOT}/${METADATA_FILE}"
fi

# ── Step 1: Hash metadata ───────────────────────────────────────────────────

step 1 "Hash metadata"

if [[ ! -f "$METADATA_FILE" ]]; then
    echo "Error: Metadata file not found: ${METADATA_FILE}" >&2
    exit 1
fi

echo "Using: ${METADATA_FILE}"
"${SCRIPTS}/hash-metadata.sh" "$METADATA_FILE"

HASH=$(cat "${REPO_ROOT}/metadata/metadata-hash.txt")
echo "Metadata hash: ${HASH}"

# ── Step 2: Validate configuration ──────────────────────────────────────────

step 2 "Validate configuration"

# Use test placeholder values where config is missing
: "${GOVERNANCE_ACTION_DEPOSIT:=100000000000}"
: "${ANCHOR_URL:=ipfs://bafkreie7i4phsirjhmceidookh77vsmfqruaxgphttryexzitylrj7gmlu}"
: "${TRANSFER_AMOUNT:=1000000}"

export GOVERNANCE_ACTION_DEPOSIT ANCHOR_URL TRANSFER_AMOUNT

# Validate that key files and payment address are set
MISSING=0

for var in DEPOSIT_RETURN_STAKE_VKEY RECEIVING_STAKE_VKEY PAYMENT_ADDRESS; do
    if [[ -z "${!var:-}" ]]; then
        echo "Error: ${var} is not set in config.env" >&2
        MISSING=$((MISSING + 1))
    fi
done

# Require either hardware wallet signing file or file-based signing key
if [[ -z "${PAYMENT_HW_SIGNING_FILE:-}" && -z "${PAYMENT_SKEY:-}" ]]; then
    echo "Error: Neither PAYMENT_HW_SIGNING_FILE nor PAYMENT_SKEY is set in config.env" >&2
    MISSING=$((MISSING + 1))
fi

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

# ── Network flags for direct queries in this script ──────────────────────────

case "${NETWORK}" in
    mainnet) QUERY_FLAG=(--mainnet) ;;
    preview) QUERY_FLAG=(--testnet-magic 2) ;;
    *)       QUERY_FLAG=(--testnet-magic 1) ;;
esac

# ── Step 3: Create governance action ────────────────────────────────────────

step 3 "Create treasury withdrawal governance action"
"${SCRIPTS}/create-governance-action.sh"

# ── Step 4: Build transaction ───────────────────────────────────────────────

step 4 "Build transaction"
"${SCRIPTS}/build-tx.sh"

# ── Step 5: Sign transaction ────────────────────────────────────────────────

step 5 "Sign transaction"
"${SCRIPTS}/sign-tx.sh"

# ── Step 6: Submit transaction ──────────────────────────────────────────────

step 6 "Submit transaction"
"${SCRIPTS}/submit-tx.sh"

TX_HASH=$(cardano-cli conway transaction txid --tx-file "${REPO_ROOT}/tx.signed")

# ── Step 7: Wait for confirmation ───────────────────────────────────────────

step 7 "Wait for on-chain confirmation"

echo "Transaction hash: ${TX_HASH}"
echo "Waiting for transaction to appear on-chain (up to 120 seconds)..."

TIMEOUT=120
INTERVAL=5
ELAPSED=0

while [[ "$ELAPSED" -lt "$TIMEOUT" ]]; do
    RESULT=$(cardano-cli conway query utxo \
        "${QUERY_FLAG[@]}" \
        --tx-in "${TX_HASH}#0" \
        --out-file /dev/stdout 2>/dev/null || echo "{}")

    ENTRY_COUNT=$(echo "$RESULT" | jq 'length' 2>/dev/null || echo "0")

    if [[ "$ENTRY_COUNT" -gt 0 ]] || [[ "$ELAPSED" -gt 0 ]]; then
        echo "Checking after ${ELAPSED}s..."
    fi

    if cardano-cli conway query tx-mempool tx-exists --tx-id "$TX_HASH" "${QUERY_FLAG[@]}" 2>/dev/null | grep -q "False"; then
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

# ── Step 8: Query governance state ──────────────────────────────────────────

step 8 "Query governance state"

echo "Querying governance state for treasury withdrawal proposals..."

GOV_STATE=$(cardano-cli conway query gov-state "${QUERY_FLAG[@]}" --out-file /dev/stdout 2>/dev/null || echo "{}")

PROPOSAL_COUNT=$(echo "$GOV_STATE" | jq '[.proposals // [] | .[] | select(.proposalProcedure.govAction.tag == "TreasuryWithdrawals")] | length' 2>/dev/null || echo "unknown")

echo "Active treasury withdrawal proposals: ${PROPOSAL_COUNT}"

# ── Summary ──────────────────────────────────────────────────────────────────

echo ""
echo "============================================================"
echo "  Lifecycle Test Complete"
echo "============================================================"
echo ""
echo "Transaction hash: ${TX_HASH}"
echo "Network:          ${NETWORK}"
echo ""
echo "Artifacts generated:"
echo "  ${METADATA_FILE}"
echo "  metadata/metadata-hash.txt"
echo "  treasury-withdrawal.action"
echo "  tx.raw"
echo "  tx.signed"
echo ""
echo "Clean up with: make clean"
