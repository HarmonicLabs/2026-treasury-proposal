#!/usr/bin/env bash
set -euo pipefail

# sign-tx-hw.sh — Sign an unsigned transaction with a Ledger hardware wallet.
#
# Signs `tx.unsigned` (the "Unwitnessed Tx" envelope saved by the treasury CLI's
# transactionDialog "Save to file" option) with the payment HW key via
# cardano-hw-cli, and writes the assembled signed tx to `tx.signed`.
#
# cardano-hw-cli has no one-shot "sign"; the flow is:
#   1. transaction transform  — normalize to canonical CBOR (HW wallets require it)
#   2. transaction witness     — produce a witness on the Ledger (confirm on device)
#   3. cardano-cli assemble    — merge the witness into the final signed tx
#
# Usage (from the offchain dir, or anywhere):
#   utils/sign-tx-hw.sh                       # tx.unsigned -> tx.signed, mainnet
#   utils/sign-tx-hw.sh path/to/tx.unsigned   # custom input
#   NETWORK=preprod utils/sign-tx-hw.sh       # testnet magic 1
#
# Env overrides:
#   NETWORK                  mainnet (default) | preprod | preview
#   PAYMENT_HW_SIGNING_FILE  path to the .hwsfile (default: <repo>/keys/payment.hwsfile)
#   TX_SIGNED                output path (default: alongside the input, tx.signed)

# ── Resolve locations ────────────────────────────────────────────────────────

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OFFCHAIN_DIR="$(dirname "$SCRIPT_DIR")"
REPO_ROOT="$(cd "$OFFCHAIN_DIR/../../.." && pwd)"

TX_UNSIGNED="${1:-$OFFCHAIN_DIR/tx.unsigned}"
TX_SIGNED="${TX_SIGNED:-$(dirname "$TX_UNSIGNED")/tx.signed}"
HW_PATH="${PAYMENT_HW_SIGNING_FILE:-$REPO_ROOT/keys/payment.hwsfile}"
[[ "$HW_PATH" == /* ]] || HW_PATH="$REPO_ROOT/$HW_PATH"

# ── Network flag (cardano-hw-cli witness expects --mainnet / --testnet-magic) ─

case "${NETWORK:-mainnet}" in
    mainnet) NETWORK_FLAG=(--mainnet) ;;
    preview) NETWORK_FLAG=(--testnet-magic 2) ;;
    preprod) NETWORK_FLAG=(--testnet-magic 1) ;;
    *)       echo "Error: unknown NETWORK '${NETWORK}' (use mainnet|preprod|preview)" >&2; exit 1 ;;
esac

# ── Validate prerequisites ───────────────────────────────────────────────────

for tool in cardano-hw-cli cardano-cli; do
    command -v "$tool" >/dev/null 2>&1 || { echo "Error: '$tool' not found in PATH" >&2; exit 1; }
done
[[ -f "$TX_UNSIGNED" ]] || { echo "Error: unsigned tx not found: $TX_UNSIGNED" >&2; exit 1; }
[[ -f "$HW_PATH" ]]     || { echo "Error: HW signing file not found: $HW_PATH" >&2; exit 1; }

echo "=== Sign with Ledger hardware wallet ==="
echo "Network:  ${NETWORK_FLAG[*]}"
echo "Input:    $TX_UNSIGNED"
echo "HW file:  $HW_PATH"
echo "Output:   $TX_SIGNED"
echo ""

# ── Sign: transform -> witness -> assemble ───────────────────────────────────

# Work on a transformed copy so the original tx.unsigned stays untouched. The
# witness signs the canonical body, so assemble must use the same transformed tx.
TX_TRANSFORMED="$(dirname "$TX_UNSIGNED")/tx.transformed"
WITNESS_FILE="$(dirname "$TX_UNSIGNED")/payment.witness"
cleanup() { rm -f "$TX_TRANSFORMED" "$WITNESS_FILE"; }
trap cleanup EXIT

echo "[1/3] Normalizing CBOR (cardano-hw-cli transaction transform)..."
cardano-hw-cli transaction transform \
    --tx-file "$TX_UNSIGNED" \
    --out-file "$TX_TRANSFORMED"

echo "[2/3] Witnessing on device — confirm the transaction on your Ledger..."
cardano-hw-cli transaction witness \
    "${NETWORK_FLAG[@]}" \
    --tx-file "$TX_TRANSFORMED" \
    --hw-signing-file "$HW_PATH" \
    --out-file "$WITNESS_FILE"

echo "[3/3] Assembling signed transaction (cardano-cli transaction assemble)..."
cardano-cli conway transaction assemble \
    --tx-body-file "$TX_TRANSFORMED" \
    --witness-file "$WITNESS_FILE" \
    --out-file "$TX_SIGNED"

echo ""
echo "Signed transaction written to: $TX_SIGNED"
