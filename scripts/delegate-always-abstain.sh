#!/usr/bin/env bash
set -euo pipefail

# delegate-always-abstain.sh - Delegate treasury contract stake credential to always_abstain DRep.
# Required by Cardano Constitution Article IV, Section 5.
# Usage: NETWORK=mainnet scripts/delegate-always-abstain.sh

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

TREASURY_SCRIPT="${RECEIVING_STAKE_SCRIPT_FILE:-}"
if [[ -z "$TREASURY_SCRIPT" ]]; then
    echo "Error: RECEIVING_STAKE_SCRIPT_FILE is not set in config.env." >&2
    exit 1
fi
if [[ "$TREASURY_SCRIPT" != /* ]]; then
    TREASURY_SCRIPT="${REPO_ROOT}/${TREASURY_SCRIPT}"
fi
if [[ ! -f "$TREASURY_SCRIPT" ]]; then
    echo "Error: Treasury script file not found: ${TREASURY_SCRIPT}" >&2
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
        echo "Error: Hardware signing file not found: ${PAY_HW_PATH}" >&2
        exit 1
    fi
elif [[ -n "${PAYMENT_SKEY:-}" ]]; then
    PAY_SKEY="${PAYMENT_SKEY}"
    if [[ "$PAY_SKEY" != /* ]]; then
        PAY_SKEY="${REPO_ROOT}/${PAY_SKEY}"
    fi
else
    echo "Error: Neither PAYMENT_HW_SIGNING_FILE nor PAYMENT_SKEY is set." >&2
    exit 1
fi

if [[ -z "${PAYMENT_ADDRESS:-}" ]]; then
    echo "Error: PAYMENT_ADDRESS is not set." >&2
    exit 1
fi

echo "=== Delegate Treasury to Always Abstain ==="
echo ""
echo "Network: ${NETWORK_FLAG[*]}"
echo "Script:  ${TREASURY_SCRIPT}"
echo ""

# ── Create vote delegation certificate ──────────────────────────────────────

CERT_FILE="${REPO_ROOT}/keys/treasury-vote-deleg.cert"

cardano-cli conway stake-address vote-delegation-certificate \
    --stake-script-file "$TREASURY_SCRIPT" \
    --always-abstain \
    --out-file "$CERT_FILE"

echo "Vote delegation certificate created: ${CERT_FILE}"

# ── Query UTxOs ──────────────────────────────────────────────────────────────

echo "Querying UTxOs..."

UTXO_OUTPUT=$(cardano-cli conway query utxo \
    "${NETWORK_FLAG[@]}" \
    --address "$PAYMENT_ADDRESS" \
    --out-file /dev/stdout)

# Need enough for fees + collateral; 10 ADA is generous
REQUIRED_LOVELACE=10000000

readarray -t UTXO_ENTRIES < <(echo "$UTXO_OUTPUT" | jq -r '
    [to_entries[] | {key: .key, lovelace: .value.value.lovelace}]
    | sort_by(-.lovelace)
    | .[]
    | "\(.key) \(.lovelace)"
')

if [[ ${#UTXO_ENTRIES[@]} -eq 0 ]]; then
    echo "Error: No UTxOs found at ${PAYMENT_ADDRESS}" >&2
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
    echo "  Required:  ${REQUIRED_ADA} ADA (fees + collateral)" >&2
    exit 1
fi

echo "Selected ${#TX_INS[@]} UTxO(s) totaling ${TOTAL_ADA} ADA:"
for utxo in "${TX_INS[@]}"; do
    echo "  ${utxo}"
done
echo ""

# ── Build transaction ────────────────────────────────────────────────────────

TX_IN_FLAGS=()
for utxo in "${TX_INS[@]}"; do
    TX_IN_FLAGS+=(--tx-in "$utxo")
done

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
        --certificate-script-file "$TREASURY_SCRIPT"
        --certificate-redeemer-value '{}'
    )
    echo "Warning: TREASURY_SCRIPT_REF_UTXO not set, including script inline." >&2
fi

TX_RAW="${REPO_ROOT}/vote-deleg.raw"

cardano-cli conway transaction build \
    "${NETWORK_FLAG[@]}" \
    "${TX_IN_FLAGS[@]}" \
    --tx-in-collateral "${TX_INS[0]}" \
    --change-address "$PAYMENT_ADDRESS" \
    --certificate-file "$CERT_FILE" \
    "${CERT_SCRIPT_FLAGS[@]}" \
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

TX_SIGNED="${REPO_ROOT}/vote-deleg.signed"

if [[ "$USE_HW" == true ]]; then
    WITNESS_FILE="${TX_RAW}.witness"

    cardano-hw-cli transaction witness \
        "${NETWORK_FLAG[@]}" \
        --tx-file "$TX_RAW" \
        --hw-signing-file "$PAY_HW_PATH" \
        --out-file "$WITNESS_FILE"

    cardano-cli conway transaction assemble \
        --tx-body-file "$TX_RAW" \
        --witness-file "$WITNESS_FILE" \
        --out-file "$TX_SIGNED"

    rm -f "$WITNESS_FILE"
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
echo "Treasury stake credential delegated to always_abstain."
echo "Transaction hash: ${TX_HASH}"
echo ""
echo "Clean up: rm -f vote-deleg.raw vote-deleg.signed keys/treasury-vote-deleg.cert"
