#!/usr/bin/env bash
set -euo pipefail

# build-tx.sh - Build a transaction to submit the treasury withdrawal governance action.
# Usage: NETWORK=preview scripts/build-tx.sh

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

# ── Source configuration ─────────────────────────────────────────────────────

if [[ -f "${REPO_ROOT}/config.env" ]]; then
    set -a
    # shellcheck source=/dev/null
    source "${REPO_ROOT}/config.env"
    set +a
fi

# ── Network flag (query/tx commands use --testnet-magic N) ───────────────────

case "${NETWORK:-preview}" in
    mainnet) NETWORK_FLAG=(--mainnet) ;;
    preprod) NETWORK_FLAG=(--testnet-magic 1) ;;
    *)       NETWORK_FLAG=(--testnet-magic 2) ;;
esac

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

# Deposit is in lovelace; we need enough to cover deposit + fees
REQUIRED_LOVELACE="${GOVERNANCE_ACTION_DEPOSIT:-100000000000}"

# Find UTxOs with ADA, sorted by value descending, accumulate until we have enough
readarray -t UTXO_ENTRIES < <(echo "$UTXO_OUTPUT" | jq -r '
    [to_entries[] | {key: .key, lovelace: .value.value.lovelace}]
    | sort_by(-.lovelace)
    | .[]
    | "\(.key) \(.lovelace)"
')

if [[ ${#UTXO_ENTRIES[@]} -eq 0 ]]; then
    echo "Error: No UTxOs found at ${PAYMENT_ADDRESS}" >&2
    echo "Fund this address before building the transaction." >&2
    exit 1
fi

TX_INS=()
TOTAL_LOVELACE=0

for entry in "${UTXO_ENTRIES[@]}"; do
    utxo=$(echo "$entry" | awk '{print $1}')
    lovelace=$(echo "$entry" | awk '{print $2}')
    TX_INS+=("$utxo")
    TOTAL_LOVELACE=$((TOTAL_LOVELACE + lovelace))
    if [[ "$TOTAL_LOVELACE" -ge "$REQUIRED_LOVELACE" ]]; then
        break
    fi
done

TOTAL_ADA=$(echo "scale=6; $TOTAL_LOVELACE / 1000000" | bc)
REQUIRED_ADA=$(echo "scale=6; $REQUIRED_LOVELACE / 1000000" | bc)

if [[ "$TOTAL_LOVELACE" -lt "$REQUIRED_LOVELACE" ]]; then
    echo "Error: Insufficient funds." >&2
    echo "  Available: ${TOTAL_ADA} ADA (${#UTXO_ENTRIES[@]} UTxOs)" >&2
    echo "  Required:  ${REQUIRED_ADA} ADA (deposit + fees)" >&2
    exit 1
fi

echo "Selected ${#TX_INS[@]} UTxO(s) totaling ${TOTAL_ADA} ADA (need ${REQUIRED_ADA}):"
for utxo in "${TX_INS[@]}"; do
    echo "  ${utxo}"
done
echo ""

# ── Check for guardrails script ──────────────────────────────────────────────

GUARDRAILS_SCRIPT="${GUARDRAILS_SCRIPT:-${REPO_ROOT}/scripts/guardrails.plutus}"
PROPOSAL_SCRIPT_FLAGS=()

if [[ -f "$GUARDRAILS_SCRIPT" ]]; then
    echo "Guardrails script: ${GUARDRAILS_SCRIPT}"
    PROPOSAL_SCRIPT_FLAGS=(
        --proposal-script-file "$GUARDRAILS_SCRIPT"
        --proposal-redeemer-value '{}'
        --tx-in-collateral "${TX_INS[0]}"
    )
else
    echo "No guardrails script found (skipping script witness)"
fi

echo ""

# ── Build transaction ────────────────────────────────────────────────────────

TX_RAW="${REPO_ROOT}/tx.raw"

# Build --tx-in flags for all selected UTxOs
TX_IN_FLAGS=()
for utxo in "${TX_INS[@]}"; do
    TX_IN_FLAGS+=(--tx-in "$utxo")
done

cardano-cli conway transaction build \
    "${NETWORK_FLAG[@]}" \
    "${TX_IN_FLAGS[@]}" \
    --change-address "$PAYMENT_ADDRESS" \
    --proposal-file "$ACTION_FILE" \
    "${PROPOSAL_SCRIPT_FLAGS[@]}" \
    --out-file "$TX_RAW"

echo "Transaction built: ${TX_RAW}"
