#!/usr/bin/env bash
set -euo pipefail

# fund-publish.sh - Fund the proposal signing address with ADA for publishing
# script references. Ledger hardware wallets cannot sign transactions with
# script_ref outputs on mainnet, so we use the proposal software key instead.
#
# Usage: NETWORK=mainnet scripts/fund-publish.sh

# shellcheck source=scripts/_lib.sh
source "$(dirname "$0")/_lib.sh"

# ── Network flag ─────────────────────────────────────────────────────────────

case "${NETWORK:-preprod}" in
    mainnet) NETWORK_FLAG=(--mainnet) ;;
    preview) NETWORK_FLAG=(--testnet-magic 2) ;;
    *)       NETWORK_FLAG=(--testnet-magic 1) ;;
esac

# ── Validate prerequisites ──────────────────────────────────────────────────

MISSING=0

if [[ -z "${PROPOSAL_VKEY:-}" ]]; then
    echo "Error: PROPOSAL_VKEY is not set." >&2
    MISSING=$((MISSING + 1))
fi

if [[ -z "${PROPOSAL_SKEY:-}" ]]; then
    echo "Error: PROPOSAL_SKEY is not set." >&2
    MISSING=$((MISSING + 1))
fi

if [[ -z "${PAYMENT_ADDRESS:-}" ]]; then
    echo "Error: PAYMENT_ADDRESS is not set." >&2
    MISSING=$((MISSING + 1))
fi

if [[ "$MISSING" -gt 0 ]]; then
    exit 1
fi

resolve_path() {
    local p="$1"
    if [[ "$p" != /* ]]; then echo "${REPO_ROOT}/${p}"; else echo "$p"; fi
}

PROPOSAL_VKEY_PATH=$(resolve_path "$PROPOSAL_VKEY")
PROPOSAL_SKEY_PATH=$(resolve_path "$PROPOSAL_SKEY")

# ── Generate proposal keys if they don't exist ──────────────────────────────

if [[ ! -f "$PROPOSAL_VKEY_PATH" || ! -f "$PROPOSAL_SKEY_PATH" ]]; then
    echo "Generating proposal signing key pair..."
    cardano-cli conway address key-gen \
        --verification-key-file "$PROPOSAL_VKEY_PATH" \
        --signing-key-file "$PROPOSAL_SKEY_PATH"
    echo "  Created: ${PROPOSAL_VKEY_PATH}"
    echo "  Created: ${PROPOSAL_SKEY_PATH}"
fi

# ── Derive proposal address ─────────────────────────────────────────────────

PROPOSAL_ADDRESS=$(cardano-cli conway address build \
    --payment-verification-key-file "$PROPOSAL_VKEY_PATH" \
    "${NETWORK_FLAG[@]}")

# 100 ADA + margin for fees
FUND_AMOUNT=105000000

echo "=== Fund Publish Address ==="
echo ""
echo "Network:          ${NETWORK_FLAG[*]}"
echo "From:             ${PAYMENT_ADDRESS}"
echo "To:               ${PROPOSAL_ADDRESS}"
echo "Amount:           ${FUND_AMOUNT} lovelace (100 ADA + fee margin)"
echo ""

# ── Check if already funded ──────────────────────────────────────────────────

EXISTING_UTXOS=$(cardano-cli conway query utxo \
    "${NETWORK_FLAG[@]}" \
    --address "$PROPOSAL_ADDRESS" \
    --out-file /dev/stdout)

EXISTING_LOVELACE=$(echo "$EXISTING_UTXOS" | jq '[.[].value.lovelace] | add // 0')

if [[ "$EXISTING_LOVELACE" -ge "$FUND_AMOUNT" ]]; then
    echo "Proposal address already has ${EXISTING_LOVELACE} lovelace (need ${FUND_AMOUNT})."
    echo "No funding needed."
    exit 0
fi

echo "Proposal address has ${EXISTING_LOVELACE} lovelace, need ${FUND_AMOUNT}."
echo ""

# ── Query source UTxOs ───────────────────────────────────────────────────────

echo "Querying source UTxOs..."

SRC_UTXO_OUTPUT=$(cardano-cli conway query utxo \
    "${NETWORK_FLAG[@]}" \
    --address "$PAYMENT_ADDRESS" \
    --out-file /dev/stdout)

readarray -t SRC_ENTRIES < <(echo "$SRC_UTXO_OUTPUT" | jq -r '
    [to_entries[] | {key: .key, lovelace: .value.value.lovelace}]
    | sort_by(-.lovelace)
    | .[]
    | "\(.key) \(.lovelace)"
')

if [[ ${#SRC_ENTRIES[@]} -eq 0 ]]; then
    echo "Error: No UTxOs found at ${PAYMENT_ADDRESS}" >&2
    exit 1
fi

TX_INS=()
SRC_TOTAL=0
for entry in "${SRC_ENTRIES[@]}"; do
    utxo=$(echo "$entry" | awk '{print $1}')
    lovelace=$(echo "$entry" | awk '{print $2}')
    TX_INS+=("$utxo")
    SRC_TOTAL=$((SRC_TOTAL + lovelace))
    if [[ "$SRC_TOTAL" -ge "$FUND_AMOUNT" ]]; then
        break
    fi
done

if [[ "$SRC_TOTAL" -lt "$FUND_AMOUNT" ]]; then
    SRC_ADA=$(echo "scale=6; $SRC_TOTAL / 1000000" | bc)
    NEED_ADA=$(echo "scale=6; $FUND_AMOUNT / 1000000" | bc)
    echo "Error: Insufficient funds at ${PAYMENT_ADDRESS}." >&2
    echo "  Available: ${SRC_ADA} ADA" >&2
    echo "  Required:  ${NEED_ADA} ADA" >&2
    exit 1
fi

echo "Selected ${#TX_INS[@]} UTxO(s):"
for utxo in "${TX_INS[@]}"; do
    echo "  ${utxo}"
done

# ── Build funding transaction ────────────────────────────────────────────────

TX_RAW="${REPO_ROOT}/fund-publish.raw"

TX_IN_FLAGS=()
for utxo in "${TX_INS[@]}"; do
    TX_IN_FLAGS+=(--tx-in "$utxo")
done

cardano-cli conway transaction build \
    "${NETWORK_FLAG[@]}" \
    "${TX_IN_FLAGS[@]}" \
    --tx-out "${PROPOSAL_ADDRESS}+${FUND_AMOUNT}" \
    --change-address "$PAYMENT_ADDRESS" \
    --out-file "$TX_RAW"

echo "Transaction built: ${TX_RAW}"

# ── Sign with hardware wallet ───────────────────────────────────────────────

TX_SIGNED="${REPO_ROOT}/fund-publish.signed"

USE_HW=false
if [[ -n "${PAYMENT_HW_SIGNING_FILE:-}" ]]; then
    USE_HW=true
    HW_PATH=$(resolve_path "$PAYMENT_HW_SIGNING_FILE")
    if [[ ! -f "$HW_PATH" ]]; then
        echo "Error: Hardware signing file not found: ${HW_PATH}" >&2
        exit 1
    fi
fi

if [[ "$USE_HW" == true ]]; then
    echo "Signing with hardware wallet..."

    cardano-hw-cli transaction transform \
        --tx-file "$TX_RAW" \
        --out-file "$TX_RAW"

    WITNESS_FILE="${TX_RAW}.witness"

    cardano-hw-cli transaction witness \
        "${NETWORK_FLAG[@]}" \
        --tx-file "$TX_RAW" \
        --hw-signing-file "$HW_PATH" \
        --out-file "$WITNESS_FILE"

    cardano-cli conway transaction assemble \
        --tx-body-file "$TX_RAW" \
        --witness-file "$WITNESS_FILE" \
        --out-file "$TX_SIGNED"

    rm -f "$WITNESS_FILE"
elif [[ -n "${PAYMENT_SKEY:-}" ]]; then
    SKEY_PATH=$(resolve_path "$PAYMENT_SKEY")
    echo "Signing with software key..."

    cardano-cli conway transaction sign \
        "${NETWORK_FLAG[@]}" \
        --tx-body-file "$TX_RAW" \
        --signing-key-file "$SKEY_PATH" \
        --out-file "$TX_SIGNED"
else
    echo "Error: Neither PAYMENT_HW_SIGNING_FILE nor PAYMENT_SKEY is set." >&2
    exit 1
fi

# ── Submit ───────────────────────────────────────────────────────────────────

cardano-cli conway transaction submit \
    "${NETWORK_FLAG[@]}" \
    --tx-file "$TX_SIGNED"

TX_HASH=$(cardano-cli conway transaction txid --tx-file "$TX_SIGNED")

echo ""
echo "Publish address funded successfully."
echo "Transaction hash: ${TX_HASH}"
echo "Proposal address: ${PROPOSAL_ADDRESS}"
echo ""
echo "Next steps:"
echo "  1. Run the offchain CLI with WALLET_ADDRESS set to the proposal address:"
echo "     WALLET_ADDRESS=${PROPOSAL_ADDRESS}"
echo ""
echo "  2. Sign the tx.unsigned with the proposal key:"
echo "     PAYMENT_HW_SIGNING_FILE= PAYMENT_SKEY=${PROPOSAL_SKEY} NETWORK=${NETWORK:-preprod} scripts/sign-publish-tx.sh"
echo ""
echo "Clean up: rm -f fund-publish.raw fund-publish.signed"
