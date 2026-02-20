#!/usr/bin/env bash
set -euo pipefail

# create-governance-action.sh - Create a treasury withdrawal governance action.
# Usage: scripts/create-governance-action.sh <network-flag>
#   e.g.  scripts/create-governance-action.sh --mainnet
#         scripts/create-governance-action.sh --testnet-magic 2

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

# ── Source configuration ─────────────────────────────────────────────────────

if [[ -f "${REPO_ROOT}/config.env" ]]; then
    # shellcheck source=/dev/null
    source "${REPO_ROOT}/config.env"
fi

# ── Parse network flag ───────────────────────────────────────────────────────

if [[ $# -lt 1 ]]; then
    echo "Usage: $(basename "$0") <network-flag>" >&2
    echo "  e.g. $(basename "$0") --mainnet" >&2
    echo "       $(basename "$0") --testnet-magic 2" >&2
    exit 1
fi

NETWORK_FLAG=("$@")

# ── Read metadata hash ──────────────────────────────────────────────────────

HASH_FILE="${REPO_ROOT}/metadata/metadata-hash.txt"

if [[ ! -f "$HASH_FILE" ]]; then
    echo "Error: Metadata hash not found at ${HASH_FILE}" >&2
    echo "Run 'make hash' first." >&2
    exit 1
fi

ANCHOR_DATA_HASH=$(cat "$HASH_FILE")

if [[ -z "$ANCHOR_DATA_HASH" ]]; then
    echo "Error: Metadata hash file is empty." >&2
    exit 1
fi

# ── Validate required env vars ──────────────────────────────────────────────

REQUIRED_VARS=(
    GOVERNANCE_ACTION_DEPOSIT
    DEPOSIT_RETURN_STAKE_VKEY
    ANCHOR_URL
    RECEIVING_STAKE_VKEY
    TRANSFER_AMOUNT
)

MISSING=0
for var in "${REQUIRED_VARS[@]}"; do
    if [[ -z "${!var:-}" ]]; then
        echo "Error: Required variable ${var} is not set." >&2
        MISSING=$((MISSING + 1))
    fi
done

if [[ "$MISSING" -gt 0 ]]; then
    echo "" >&2
    echo "Set these in config.env or export them before running." >&2
    exit 1
fi

# ── Validate key files exist ────────────────────────────────────────────────

for keyfile_var in DEPOSIT_RETURN_STAKE_VKEY RECEIVING_STAKE_VKEY; do
    keypath="${!keyfile_var}"
    # Resolve relative paths against REPO_ROOT
    if [[ "$keypath" != /* ]]; then
        keypath="${REPO_ROOT}/${keypath}"
    fi
    if [[ ! -f "$keypath" ]]; then
        echo "Error: Key file not found: ${keypath} (from ${keyfile_var})" >&2
        MISSING=$((MISSING + 1))
    fi
done

if [[ "$MISSING" -gt 0 ]]; then
    exit 1
fi

# ── Resolve key paths ───────────────────────────────────────────────────────

resolve_path() {
    local p="$1"
    if [[ "$p" != /* ]]; then
        echo "${REPO_ROOT}/${p}"
    else
        echo "$p"
    fi
}

DEPOSIT_VKEY_PATH=$(resolve_path "$DEPOSIT_RETURN_STAKE_VKEY")
RECEIVING_VKEY_PATH=$(resolve_path "$RECEIVING_STAKE_VKEY")

# ── Create governance action ────────────────────────────────────────────────

OUTPUT_FILE="${REPO_ROOT}/treasury-withdrawal.action"

echo "=== Create Treasury Withdrawal Governance Action ==="
echo ""
echo "Network:     ${NETWORK_FLAG[*]}"
echo "Deposit:     ${GOVERNANCE_ACTION_DEPOSIT} lovelace"
echo "Anchor URL:  ${ANCHOR_URL}"
echo "Data Hash:   ${ANCHOR_DATA_HASH}"
echo "Transfer:    ${TRANSFER_AMOUNT} lovelace"
echo ""

cardano-cli conway governance action create-treasury-withdrawal \
    "${NETWORK_FLAG[@]}" \
    --governance-action-deposit "$GOVERNANCE_ACTION_DEPOSIT" \
    --deposit-return-stake-verification-key-file "$DEPOSIT_VKEY_PATH" \
    --anchor-url "$ANCHOR_URL" \
    --anchor-data-hash "$ANCHOR_DATA_HASH" \
    --funds-receiving-stake-verification-key-file "$RECEIVING_VKEY_PATH" \
    --transfer "$TRANSFER_AMOUNT" \
    --out-file "$OUTPUT_FILE"

echo "Governance action created: ${OUTPUT_FILE}"
