#!/usr/bin/env bash
set -euo pipefail

# register-stake.sh - Register the stake key on-chain (required before governance actions).
# Usage: NETWORK=preprod scripts/register-stake.sh

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

if [[ -z "${DEPOSIT_RETURN_STAKE_VKEY:-}" ]]; then
    echo "Error: DEPOSIT_RETURN_STAKE_VKEY is not set." >&2
    exit 1
fi

STAKE_VKEY="${DEPOSIT_RETURN_STAKE_VKEY}"
if [[ "$STAKE_VKEY" != /* ]]; then
    STAKE_VKEY="${REPO_ROOT}/${STAKE_VKEY}"
fi

if [[ ! -f "$STAKE_VKEY" ]]; then
    echo "Error: Stake verification key not found: ${STAKE_VKEY}" >&2
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

    STAKE_HW_PATH="${DEPOSIT_RETURN_STAKE_HW_SIGNING_FILE:-}"
    if [[ -z "$STAKE_HW_PATH" ]]; then
        echo "Error: DEPOSIT_RETURN_STAKE_HW_SIGNING_FILE is not set." >&2
        exit 1
    fi
    if [[ "$STAKE_HW_PATH" != /* ]]; then
        STAKE_HW_PATH="${REPO_ROOT}/${STAKE_HW_PATH}"
    fi
    if [[ ! -f "$STAKE_HW_PATH" ]]; then
        echo "Error: Stake hardware signing file not found: ${STAKE_HW_PATH}" >&2
        exit 1
    fi
elif [[ -n "${PAYMENT_SKEY:-}" ]]; then
    PAY_SKEY="${PAYMENT_SKEY}"
    if [[ "$PAY_SKEY" != /* ]]; then
        PAY_SKEY="${REPO_ROOT}/${PAY_SKEY}"
    fi

    STAKE_SKEY="${STAKE_VKEY%.vkey}.skey"
    if [[ ! -f "$STAKE_SKEY" ]]; then
        echo "Error: Stake signing key not found: ${STAKE_SKEY}" >&2
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

# ── Create registration certificate ─────────────────────────────────────────

CERT_FILE="${REPO_ROOT}/keys/stake-reg.cert"

echo "=== Register Stake Key ==="
echo ""
echo "Network:    ${NETWORK_FLAG[*]}"
echo "Stake key:  ${STAKE_VKEY}"
echo ""

cardano-cli conway stake-address registration-certificate \
    --stake-verification-key-file "$STAKE_VKEY" \
    --key-reg-deposit-amt 2000000 \
    --out-file "$CERT_FILE"

echo "Registration certificate created: ${CERT_FILE}"

# ── Query UTxO ───────────────────────────────────────────────────────────────

echo "Querying UTxOs..."

UTXO_OUTPUT=$(cardano-cli conway query utxo \
    "${NETWORK_FLAG[@]}" \
    --address "$PAYMENT_ADDRESS" \
    --out-file /dev/stdout)

TX_IN=$(echo "$UTXO_OUTPUT" | jq -r 'to_entries | .[0].key // empty')

if [[ -z "$TX_IN" ]]; then
    echo "Error: No UTxOs found at ${PAYMENT_ADDRESS}" >&2
    exit 1
fi

echo "Using UTxO: ${TX_IN}"

# ── Build transaction ────────────────────────────────────────────────────────

TX_RAW="${REPO_ROOT}/stake-reg.raw"

cardano-cli conway transaction build \
    "${NETWORK_FLAG[@]}" \
    --tx-in "$TX_IN" \
    --change-address "$PAYMENT_ADDRESS" \
    --certificate-file "$CERT_FILE" \
    --out-file "$TX_RAW"

echo "Transaction built: ${TX_RAW}"

# ── Sign transaction ─────────────────────────────────────────────────────────

TX_SIGNED="${REPO_ROOT}/stake-reg.signed"

if [[ "$USE_HW" == true ]]; then
    PAY_WITNESS="${TX_RAW}.pay.witness"
    STAKE_WITNESS="${TX_RAW}.stake.witness"

    cardano-hw-cli transaction witness \
        "${NETWORK_FLAG[@]}" \
        --tx-file "$TX_RAW" \
        --hw-signing-file "$PAY_HW_PATH" \
        --out-file "$PAY_WITNESS"

    cardano-hw-cli transaction witness \
        "${NETWORK_FLAG[@]}" \
        --tx-file "$TX_RAW" \
        --hw-signing-file "$STAKE_HW_PATH" \
        --out-file "$STAKE_WITNESS"

    cardano-cli conway transaction assemble \
        --tx-body-file "$TX_RAW" \
        --witness-file "$PAY_WITNESS" \
        --witness-file "$STAKE_WITNESS" \
        --out-file "$TX_SIGNED"

    rm -f "$PAY_WITNESS" "$STAKE_WITNESS"
else
    cardano-cli conway transaction sign \
        "${NETWORK_FLAG[@]}" \
        --tx-body-file "$TX_RAW" \
        --signing-key-file "$PAY_SKEY" \
        --signing-key-file "$STAKE_SKEY" \
        --out-file "$TX_SIGNED"
fi

echo "Transaction signed: ${TX_SIGNED}"

# ── Submit ───────────────────────────────────────────────────────────────────

cardano-cli conway transaction submit \
    "${NETWORK_FLAG[@]}" \
    --tx-file "$TX_SIGNED"

TX_HASH=$(cardano-cli conway transaction txid --tx-file "$TX_SIGNED")

echo ""
echo "Stake key registered successfully."
echo "Transaction hash: ${TX_HASH}"
echo ""
echo "Clean up: rm -f stake-reg.raw stake-reg.signed keys/stake-reg.cert"
