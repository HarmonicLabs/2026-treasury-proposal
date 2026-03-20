#!/usr/bin/env bash
set -euo pipefail

# sign-tx.sh - Sign the built transaction with the payment signing key.
# Usage: NETWORK=preprod scripts/sign-tx.sh

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

# ── Source configuration ─────────────────────────────────────────────────────

if [[ -f "${REPO_ROOT}/config.env" ]]; then
    set -a
    # shellcheck source=/dev/null
    source "${REPO_ROOT}/config.env"
    set +a
fi

# ── Network flag (sign uses --testnet-magic N) ───────────────────────────────

case "${NETWORK:-preprod}" in
    mainnet) NETWORK_FLAG=(--mainnet) ;;
    preview) NETWORK_FLAG=(--testnet-magic 2) ;;
    *)       NETWORK_FLAG=(--testnet-magic 1) ;;
esac

# ── Validate prerequisites ──────────────────────────────────────────────────

TX_RAW="${REPO_ROOT}/tx.raw"
if [[ ! -f "$TX_RAW" ]]; then
    echo "Error: Transaction body not found: ${TX_RAW}" >&2
    echo "Run 'make build-tx' first." >&2
    exit 1
fi

if [[ -z "${PAYMENT_SKEY:-}" ]]; then
    echo "Error: PAYMENT_SKEY is not set." >&2
    echo "Set it in config.env or export it." >&2
    exit 1
fi

# Resolve relative path
SKEY_PATH="$PAYMENT_SKEY"
if [[ "$SKEY_PATH" != /* ]]; then
    SKEY_PATH="${REPO_ROOT}/${SKEY_PATH}"
fi

if [[ ! -f "$SKEY_PATH" ]]; then
    echo "Error: Signing key file not found: ${SKEY_PATH}" >&2
    exit 1
fi

# ── Sign transaction ─────────────────────────────────────────────────────────

TX_SIGNED="${REPO_ROOT}/tx.signed"

echo "=== Sign Transaction ==="
echo ""
echo "Network:  ${NETWORK_FLAG[*]}"
echo "Input:    ${TX_RAW}"
echo "Key:      ${SKEY_PATH}"
echo ""

cardano-cli conway transaction sign \
    "${NETWORK_FLAG[@]}" \
    --tx-body-file "$TX_RAW" \
    --signing-key-file "$SKEY_PATH" \
    --out-file "$TX_SIGNED"

echo "Transaction signed: ${TX_SIGNED}"
