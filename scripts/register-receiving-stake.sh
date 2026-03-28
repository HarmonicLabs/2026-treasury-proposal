#!/usr/bin/env bash
set -euo pipefail

# register-receiving-stake.sh - Register the receiving (script-based) stake credential on-chain.
# Required before submitting a treasury withdrawal that sends funds to a script stake address.
# Usage: NETWORK=preprod scripts/register-receiving-stake.sh

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

# ── Source configuration ─────────────────────────────────────────────────────

if [[ -f "${REPO_ROOT}/config.env" ]]; then
    set -a
    # shellcheck source=/dev/null
    source "${REPO_ROOT}/config.env"
    set +a
fi

# ── Network flag ─────────────────────────────────────────────────────────────

case "${NETWORK:-preprod}" in
    mainnet) NETWORK_FLAG=(--mainnet) ;;
    preview) NETWORK_FLAG=(--testnet-magic 2) ;;
    *)       NETWORK_FLAG=(--testnet-magic 1) ;;
esac

# ── Validate prerequisites ──────────────────────────────────────────────────

if [[ -z "${RECEIVING_STAKE_SCRIPT_FILE:-}" ]]; then
    echo "Error: RECEIVING_STAKE_SCRIPT_FILE is not set." >&2
    echo "This script registers script-based receiving stake credentials." >&2
    echo "If using a key-based credential, use register-stake.sh instead." >&2
    exit 1
fi

SCRIPT_PATH="${RECEIVING_STAKE_SCRIPT_FILE}"
if [[ "$SCRIPT_PATH" != /* ]]; then
    SCRIPT_PATH="${REPO_ROOT}/${SCRIPT_PATH}"
fi

if [[ ! -f "$SCRIPT_PATH" ]]; then
    echo "Error: Script file not found: ${SCRIPT_PATH}" >&2
    exit 1
fi

# Determine signing mode: hardware wallet or file-based
USE_HW=false
if [[ -n "${PAYMENT_HW_SIGNING_FILE:-}" ]]; then
    USE_HW=true
    PAY_HW_PATH="$PAYMENT_HW_SIGNING_FILE"
    if [[ "$PAY_HW_PATH" != /* ]]; then
        PAY_HW_PATH="${REPO_ROOT}/${PAY_HW_PATH}"
    fi
    if [[ ! -f "$PAY_HW_PATH" ]]; then
        echo "Error: Payment hardware signing file not found: ${PAY_HW_PATH}" >&2
        exit 1
    fi
elif [[ -n "${PAYMENT_SKEY:-}" ]]; then
    PAY_SKEY="${PAYMENT_SKEY}"
    if [[ "$PAY_SKEY" != /* ]]; then
        PAY_SKEY="${REPO_ROOT}/${PAY_SKEY}"
    fi
    if [[ ! -f "$PAY_SKEY" ]]; then
        echo "Error: Payment signing key not found: ${PAY_SKEY}" >&2
        exit 1
    fi
else
    echo "Error: Neither PAYMENT_HW_SIGNING_FILE nor PAYMENT_SKEY is set." >&2
    exit 1
fi

if [[ -z "${PAYMENT_ADDRESS:-}" ]]; then
    echo "Error: PAYMENT_ADDRESS is not set." >&2
    exit 1
fi

# ── Compute script stake address and check registration ─────────────────────

STAKE_ADDR=$(cardano-cli conway stake-address build \
    --stake-script-file "$SCRIPT_PATH" \
    "${NETWORK_FLAG[@]}")

echo "=== Register Receiving Stake Credential (Script) ==="
echo ""
echo "Network:       ${NETWORK_FLAG[*]}"
echo "Script file:   ${SCRIPT_PATH}"
echo "Stake address: ${STAKE_ADDR}"
echo ""

STAKE_INFO=$(cardano-cli conway query stake-address-info \
    "${NETWORK_FLAG[@]}" \
    --address "$STAKE_ADDR" \
    --out-file /dev/stdout)

if [[ $(echo "$STAKE_INFO" | jq 'length') -gt 0 ]]; then
    echo "Script stake credential is already registered."
    echo "$STAKE_INFO" | jq '.[0]'
    exit 0
fi

echo "Script stake credential is not registered. Proceeding..."

# ── Create registration certificate ─────────────────────────────────────────

CERT_FILE="${REPO_ROOT}/keys/receiving-stake-reg.cert"

cardano-cli conway stake-address registration-certificate \
    --stake-script-file "$SCRIPT_PATH" \
    --key-reg-deposit-amt 2000000 \
    --out-file "$CERT_FILE"

echo "Registration certificate created: ${CERT_FILE}"

# ── Query UTxO ───────────────────────────────────────────────────────────────

echo "Querying UTxOs..."

UTXO_OUTPUT=$(cardano-cli conway query utxo \
    "${NETWORK_FLAG[@]}" \
    --address "$PAYMENT_ADDRESS" \
    --out-file /dev/stdout)

TX_IN=$(echo "$UTXO_OUTPUT" | jq -r 'to_entries | sort_by(.value.value.lovelace) | reverse | .[0].key // empty')

if [[ -z "$TX_IN" ]]; then
    echo "Error: No UTxOs found at ${PAYMENT_ADDRESS}" >&2
    exit 1
fi

echo "Using UTxO: ${TX_IN}"

# ── Build transaction ────────────────────────────────────────────────────────

# Use reference input if available, otherwise include script inline
if [[ -n "${TREASURY_SCRIPT_REF_UTXO:-}" ]]; then
    CERT_SCRIPT_FLAGS=(
        --certificate-tx-in-reference "$TREASURY_SCRIPT_REF_UTXO"
        --certificate-plutus-script-v3
        --certificate-reference-tx-in-redeemer-value '{}'
    )
    echo "Using reference script input: ${TREASURY_SCRIPT_REF_UTXO}"
else
    CERT_SCRIPT_FLAGS=(
        --certificate-script-file "$SCRIPT_PATH"
        --certificate-redeemer-value '{}'
    )
    echo "Warning: TREASURY_SCRIPT_REF_UTXO not set, including script inline." >&2
fi

TX_RAW="${REPO_ROOT}/receiving-stake-reg.raw"

cardano-cli conway transaction build \
    "${NETWORK_FLAG[@]}" \
    --tx-in "$TX_IN" \
    --change-address "$PAYMENT_ADDRESS" \
    --certificate-file "$CERT_FILE" \
    "${CERT_SCRIPT_FLAGS[@]}" \
    --tx-in-collateral "$TX_IN" \
    --out-file "$TX_RAW"

echo "Transaction built: ${TX_RAW}"

# ── Canonicalize CBOR (required by cardano-hw-cli) ──────────────────────────

if [[ "$USE_HW" == true ]]; then
    cardano-hw-cli transaction transform \
        --tx-file "$TX_RAW" \
        --out-file "$TX_RAW"
    echo "Transaction CBOR canonicalized."
fi

# ── Sign transaction ─────────────────────────────────────────────────────────

TX_SIGNED="${REPO_ROOT}/receiving-stake-reg.signed"

if [[ "$USE_HW" == true ]]; then
    PAY_WITNESS="${TX_RAW}.pay.witness"

    cardano-hw-cli transaction witness \
        "${NETWORK_FLAG[@]}" \
        --tx-file "$TX_RAW" \
        --hw-signing-file "$PAY_HW_PATH" \
        --out-file "$PAY_WITNESS"

    cardano-cli conway transaction assemble \
        --tx-body-file "$TX_RAW" \
        --witness-file "$PAY_WITNESS" \
        --out-file "$TX_SIGNED"

    rm -f "$PAY_WITNESS"
else
    cardano-cli conway transaction sign \
        "${NETWORK_FLAG[@]}" \
        --tx-body-file "$TX_RAW" \
        --signing-key-file "$PAY_SKEY" \
        --out-file "$TX_SIGNED"
fi

echo "Transaction signed: ${TX_SIGNED}"

# ── Submit ───────────────────────────────────────────────────────────────────

cardano-cli conway transaction submit \
    "${NETWORK_FLAG[@]}" \
    --tx-file "$TX_SIGNED"

TX_HASH=$(cardano-cli conway transaction txid --tx-file "$TX_SIGNED")

echo ""
echo "Script stake credential registered successfully."
echo "Transaction hash: ${TX_HASH}"
echo ""
echo "Clean up: rm -f receiving-stake-reg.raw receiving-stake-reg.signed keys/receiving-stake-reg.cert"
