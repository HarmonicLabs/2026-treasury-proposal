#!/usr/bin/env bash
set -euo pipefail

# generate-test-keys.sh - Generate a fresh wallet for preprod testnet testing.
# Usage: scripts/generate-test-keys.sh

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
KEYS_DIR="${REPO_ROOT}/keys"

# ── Safety check ──────────────────────────────────────────────────────────────

if [[ -f "${KEYS_DIR}/payment.skey" ]]; then
    echo "Error: keys/payment.skey already exists." >&2
    echo "Remove existing keys first if you want to regenerate." >&2
    exit 1
fi

# ── Generate payment key pair ─────────────────────────────────────────────────

echo "=== Generate Preprod Testnet Wallet ==="
echo ""

cardano-cli conway address key-gen \
    --verification-key-file "${KEYS_DIR}/payment.vkey" \
    --signing-key-file "${KEYS_DIR}/payment.skey"

echo "  Payment key pair generated"

# ── Generate stake key pair ───────────────────────────────────────────────────

cardano-cli conway stake-address key-gen \
    --verification-key-file "${KEYS_DIR}/deposit-return-stake.vkey" \
    --signing-key-file "${KEYS_DIR}/deposit-return-stake.skey"

cp "${KEYS_DIR}/deposit-return-stake.vkey" "${KEYS_DIR}/receiving-stake.vkey"
cp "${KEYS_DIR}/deposit-return-stake.skey" "${KEYS_DIR}/receiving-stake.skey"

echo "  Stake key pair generated"

# ── Build address ─────────────────────────────────────────────────────────────

# Network flag for address build (uses --testnet-magic N)
case "${NETWORK:-preprod}" in
    mainnet) ADDR_FLAG=(--mainnet) ;;
    preview) ADDR_FLAG=(--testnet-magic 2) ;;
    *)       ADDR_FLAG=(--testnet-magic 1) ;;
esac

cardano-cli conway address build \
    "${ADDR_FLAG[@]}" \
    --payment-verification-key-file "${KEYS_DIR}/payment.vkey" \
    --stake-verification-key-file "${KEYS_DIR}/deposit-return-stake.vkey" \
    --out-file "${KEYS_DIR}/payment.addr"

ADDRESS=$(cat "${KEYS_DIR}/payment.addr")

echo ""
echo "Address: ${ADDRESS}"
echo ""
echo "Fund this address from the preprod faucet:"
echo "  https://docs.cardano.org/cardano-testnets/tools/faucet/"
echo ""
echo "Then update PAYMENT_ADDRESS in config.env"
