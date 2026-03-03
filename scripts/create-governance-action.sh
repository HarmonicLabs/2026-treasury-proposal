#!/usr/bin/env bash
set -euo pipefail

# create-governance-action.sh - Create a treasury withdrawal governance action.
# Usage: NETWORK=preview scripts/create-governance-action.sh

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

# ── Source configuration ─────────────────────────────────────────────────────

if [[ -f "${REPO_ROOT}/config.env" ]]; then
    set -a
    # shellcheck source=/dev/null
    source "${REPO_ROOT}/config.env"
    set +a
fi

# ── Network flag (governance commands use --testnet/--mainnet) ────────────────

case "${NETWORK:-preview}" in
    mainnet) NETWORK_FLAG=(--mainnet) ;;
    *)       NETWORK_FLAG=(--testnet) ;;
esac

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
    TRANSFER_AMOUNT
)

# Either RECEIVING_STAKE_VKEY (key-based) or RECEIVING_STAKE_SCRIPT_FILE (script-based) is required
if [[ -z "${RECEIVING_STAKE_VKEY:-}" && -z "${RECEIVING_STAKE_SCRIPT_FILE:-}" ]]; then
    echo "Error: Either RECEIVING_STAKE_VKEY or RECEIVING_STAKE_SCRIPT_FILE must be set." >&2
    MISSING=$((MISSING + 1))
fi

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

# ── Validate key/script files exist ───────────────────────────────────────────

resolve_path() {
    local p="$1"
    if [[ "$p" != /* ]]; then
        echo "${REPO_ROOT}/${p}"
    else
        echo "$p"
    fi
}

DEPOSIT_VKEY_PATH=$(resolve_path "$DEPOSIT_RETURN_STAKE_VKEY")
if [[ ! -f "$DEPOSIT_VKEY_PATH" ]]; then
    echo "Error: Key file not found: ${DEPOSIT_VKEY_PATH} (from DEPOSIT_RETURN_STAKE_VKEY)" >&2
    MISSING=$((MISSING + 1))
fi

# Determine receiving credential type (script vs key)
RECEIVING_FLAG=()
if [[ -n "${RECEIVING_STAKE_SCRIPT_FILE:-}" ]]; then
    RECEIVING_SCRIPT_PATH=$(resolve_path "$RECEIVING_STAKE_SCRIPT_FILE")
    if [[ ! -f "$RECEIVING_SCRIPT_PATH" ]]; then
        echo "Error: Script file not found: ${RECEIVING_SCRIPT_PATH} (from RECEIVING_STAKE_SCRIPT_FILE)" >&2
        MISSING=$((MISSING + 1))
    else
        RECEIVING_FLAG=(--funds-receiving-stake-script-file "$RECEIVING_SCRIPT_PATH")
    fi
elif [[ -n "${RECEIVING_STAKE_VKEY:-}" ]]; then
    RECEIVING_VKEY_PATH=$(resolve_path "$RECEIVING_STAKE_VKEY")
    if [[ ! -f "$RECEIVING_VKEY_PATH" ]]; then
        echo "Error: Key file not found: ${RECEIVING_VKEY_PATH} (from RECEIVING_STAKE_VKEY)" >&2
        MISSING=$((MISSING + 1))
    else
        RECEIVING_FLAG=(--funds-receiving-stake-verification-key-file "$RECEIVING_VKEY_PATH")
    fi
fi

if [[ "$MISSING" -gt 0 ]]; then
    exit 1
fi

# ── Query constitution script hash ────────────────────────────────────────────

# Query commands need --testnet-magic N, not --testnet
case "${NETWORK:-preview}" in
    mainnet) QUERY_FLAG=(--mainnet) ;;
    preprod) QUERY_FLAG=(--testnet-magic 1) ;;
    *)       QUERY_FLAG=(--testnet-magic 2) ;;
esac

echo "Querying on-chain constitution script hash..."

CONSTITUTION_JSON=$(cardano-cli conway query constitution "${QUERY_FLAG[@]}" --out-file /dev/stdout)
CONSTITUTION_SCRIPT_HASH=$(echo "$CONSTITUTION_JSON" | jq -r '.script // empty')

CONSTITUTION_FLAG=()
if [[ -n "$CONSTITUTION_SCRIPT_HASH" ]]; then
    CONSTITUTION_FLAG=(--constitution-script-hash "$CONSTITUTION_SCRIPT_HASH")
    echo "Constitution script hash: ${CONSTITUTION_SCRIPT_HASH}"
else
    echo "No constitution script hash found on-chain (skipping)"
fi

# ── Create governance action ────────────────────────────────────────────────

OUTPUT_FILE="${REPO_ROOT}/treasury-withdrawal.action"

echo ""
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
    "${RECEIVING_FLAG[@]}" \
    --transfer "$TRANSFER_AMOUNT" \
    "${CONSTITUTION_FLAG[@]}" \
    --out-file "$OUTPUT_FILE"

echo "Governance action created: ${OUTPUT_FILE}"
