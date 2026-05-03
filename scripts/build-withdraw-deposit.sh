#!/usr/bin/env bash
set -euo pipefail

# build-withdraw-deposit.sh - Build a transaction that withdraws a returned
# governance-action deposit from the deposit-return stake address.
#
# After a treasury-withdrawal governance action expires or is ratified, the
# protocol credits the 100k ADA deposit to the rewardAccountBalance of the
# stake address that was set as --deposit-return-stake-verification-key-file
# at action creation. This script builds a stake-reward-withdrawal tx that
# pulls that balance into PAYMENT_ADDRESS.
#
# Usage: NETWORK=preprod scripts/build-withdraw-deposit.sh

# shellcheck source=scripts/_lib.sh
source "$(dirname "$0")/_lib.sh"
require_proposal_dir

# ── Network flag (query/tx commands use --testnet-magic N) ───────────────────

case "${NETWORK:-preprod}" in
    mainnet) NETWORK_FLAG=(--mainnet) ;;
    preview) NETWORK_FLAG=(--testnet-magic 2) ;;
    *)       NETWORK_FLAG=(--testnet-magic 1) ;;
esac

# ── Validate prerequisites ──────────────────────────────────────────────────

if [[ -z "${DEPOSIT_RETURN_STAKE_VKEY:-}" ]]; then
    echo "Error: DEPOSIT_RETURN_STAKE_VKEY is not set." >&2
    exit 1
fi

if [[ -z "${PAYMENT_ADDRESS:-}" ]]; then
    echo "Error: PAYMENT_ADDRESS is not set." >&2
    exit 1
fi

resolve_path() {
    local p="$1"
    if [[ "$p" != /* ]]; then echo "${REPO_ROOT}/${p}"; else echo "$p"; fi
}

DEPOSIT_VKEY=$(resolve_path "$DEPOSIT_RETURN_STAKE_VKEY")
if [[ ! -f "$DEPOSIT_VKEY" ]]; then
    echo "Error: Deposit-return stake verification key not found: ${DEPOSIT_VKEY}" >&2
    exit 1
fi

# ── Derive the deposit-return stake address ─────────────────────────────────

STAKE_ADDR=$(cardano-cli conway stake-address build \
    --stake-verification-key-file "$DEPOSIT_VKEY" \
    "${NETWORK_FLAG[@]}")

echo "=== Build Withdraw-Deposit Transaction ==="
echo ""
echo "Network:       ${NETWORK_FLAG[*]}"
echo "Stake address: ${STAKE_ADDR}"
echo "Fee source:    ${PAYMENT_ADDRESS}"
echo "Change to:     ${PAYMENT_ADDRESS}"
echo ""

# ── Query rewards balance ───────────────────────────────────────────────────

echo "Querying stake-address-info..."

STAKE_INFO=$(cardano-cli conway query stake-address-info \
    "${NETWORK_FLAG[@]}" \
    --address "$STAKE_ADDR" \
    --out-file /dev/stdout)

if [[ $(echo "$STAKE_INFO" | jq 'length') -eq 0 ]]; then
    echo "Error: Stake address is not registered: ${STAKE_ADDR}" >&2
    exit 1
fi

REWARD_BALANCE=$(echo "$STAKE_INFO" | jq -r '.[0].rewardAccountBalance')

if [[ "$REWARD_BALANCE" -eq 0 ]]; then
    LOCKED_ACTIONS=$(echo "$STAKE_INFO" | jq -r '.[0].govActionDeposits // {} | keys[]?' || true)
    if [[ -n "$LOCKED_ACTIONS" ]]; then
        echo "Error: rewardAccountBalance is 0 but the deposit is still locked." >&2
        echo "Locked at the following governance action(s):" >&2
        while IFS= read -r action; do
            echo "  ${action}" >&2
        done <<< "$LOCKED_ACTIONS"
        echo "" >&2
        echo "Deposits are returned only after the action expires or is ratified," >&2
        echo "and the change is applied at the next epoch boundary." >&2
        exit 1
    fi
    echo "Error: Nothing to withdraw — rewardAccountBalance is 0." >&2
    exit 1
fi

REWARD_ADA=$(echo "scale=6; $REWARD_BALANCE / 1000000" | bc)
echo "Reward balance: ${REWARD_BALANCE} lovelace (${REWARD_ADA} ADA)"
echo ""

# ── Pick a UTxO from PAYMENT_ADDRESS to cover fees ──────────────────────────

echo "Querying UTxOs at ${PAYMENT_ADDRESS}..."

UTXO_OUTPUT=$(cardano-cli conway query utxo \
    "${NETWORK_FLAG[@]}" \
    --address "$PAYMENT_ADDRESS" \
    --out-file /dev/stdout)

readarray -t UTXO_ENTRIES < <(echo "$UTXO_OUTPUT" | jq -r '
    [to_entries[] | {key: .key, lovelace: .value.value.lovelace}]
    | sort_by(-.lovelace)
    | .[]
    | "\(.key) \(.lovelace)"
')

if [[ ${#UTXO_ENTRIES[@]} -eq 0 ]]; then
    echo "Error: No UTxOs found at ${PAYMENT_ADDRESS} to cover fees." >&2
    exit 1
fi

FEE_UTXO=$(echo "${UTXO_ENTRIES[0]}" | awk '{print $1}')
FEE_LOVELACE=$(echo "${UTXO_ENTRIES[0]}" | awk '{print $2}')
FEE_ADA=$(echo "scale=6; $FEE_LOVELACE / 1000000" | bc)

echo "Selected fee UTxO: ${FEE_UTXO} (${FEE_ADA} ADA)"
echo ""

# ── Build transaction ────────────────────────────────────────────────────────

TX_RAW="${PROPOSAL_DIR}/withdraw-deposit.raw"

cardano-cli conway transaction build \
    "${NETWORK_FLAG[@]}" \
    --tx-in "$FEE_UTXO" \
    --withdrawal "${STAKE_ADDR}+${REWARD_BALANCE}" \
    --change-address "$PAYMENT_ADDRESS" \
    --out-file "$TX_RAW"

echo "Transaction built: ${TX_RAW}"
