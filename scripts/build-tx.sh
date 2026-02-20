#!/usr/bin/env bash
set -euo pipefail

# build-tx.sh - Build a transaction to submit the treasury withdrawal governance action.
# Usage: scripts/build-tx.sh <network-flag>
#   e.g.  scripts/build-tx.sh --mainnet
#         scripts/build-tx.sh --testnet-magic 2

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

# ── Validate prerequisites ──────────────────────────────────────────────────

ACTION_FILE="${REPO_ROOT}/treasury-withdrawal.action"
if [[ ! -f "$ACTION_FILE" ]]; then
    echo "Error: Governance action file not found: ${ACTION_FILE}" >&2
    echo "Run 'make governance-action' first." >&2
    exit 1
fi

if [[ -z "${PAYMENT_ADDRESS:-}" ]]; then
    echo "Error: PAYMENT_ADDRESS is not set." >&2
    echo "Set it in config.env or export it." >&2
    exit 1
fi

# ── Query UTxOs ──────────────────────────────────────────────────────────────

echo "=== Build Transaction ==="
echo ""
echo "Network:  ${NETWORK_FLAG[*]}"
echo "Address:  ${PAYMENT_ADDRESS}"
echo ""
echo "Querying UTxOs..."

UTXO_OUTPUT=$(cardano-cli conway query utxo \
    "${NETWORK_FLAG[@]}" \
    --address "$PAYMENT_ADDRESS" \
    --out-file /dev/stdout)

# Parse the first UTxO with sufficient funds
TX_IN=$(echo "$UTXO_OUTPUT" | jq -r 'to_entries | .[0].key // empty')

if [[ -z "$TX_IN" ]]; then
    echo "Error: No UTxOs found at ${PAYMENT_ADDRESS}" >&2
    echo "Fund this address before building the transaction." >&2
    exit 1
fi

echo "Using UTxO: ${TX_IN}"
echo ""

# ── Build transaction ────────────────────────────────────────────────────────

TX_RAW="${REPO_ROOT}/tx.raw"

cardano-cli conway transaction build \
    "${NETWORK_FLAG[@]}" \
    --tx-in "$TX_IN" \
    --change-address "$PAYMENT_ADDRESS" \
    --proposal-file "$ACTION_FILE" \
    --out-file "$TX_RAW"

echo "Transaction built: ${TX_RAW}"
