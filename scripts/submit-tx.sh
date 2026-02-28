#!/usr/bin/env bash
set -euo pipefail

# submit-tx.sh - Submit a signed transaction to the Cardano network.
# Usage: NETWORK=preview scripts/submit-tx.sh [--confirm]

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

# ── Source configuration ─────────────────────────────────────────────────────

if [[ -f "${REPO_ROOT}/config.env" ]]; then
    set -a
    # shellcheck source=/dev/null
    source "${REPO_ROOT}/config.env"
    set +a
fi

# ── Parse arguments ──────────────────────────────────────────────────────────

CONFIRM=false
for arg in "$@"; do
    if [[ "$arg" == "--confirm" ]]; then
        CONFIRM=true
    fi
done

# ── Network flag (submit uses --testnet-magic N) ─────────────────────────────

case "${NETWORK:-preview}" in
    mainnet) NETWORK_FLAG=(--mainnet) ;;
    preprod) NETWORK_FLAG=(--testnet-magic 1) ;;
    *)       NETWORK_FLAG=(--testnet-magic 2) ;;
esac

# ── Validate prerequisites ──────────────────────────────────────────────────

TX_SIGNED="${REPO_ROOT}/tx.signed"
if [[ ! -f "$TX_SIGNED" ]]; then
    echo "Error: Signed transaction not found: ${TX_SIGNED}" >&2
    echo "Run 'make sign-tx' first." >&2
    exit 1
fi

# ── Confirmation prompt (mainnet safety) ─────────────────────────────────────

echo "=== Submit Transaction ==="
echo ""
echo "Network:  ${NETWORK_FLAG[*]}"
echo "File:     ${TX_SIGNED}"
echo ""

if [[ "$CONFIRM" == true ]]; then
    echo "WARNING: You are about to submit a transaction."
    echo "This action is irreversible once confirmed by the network."
    echo ""
    read -rp "Type 'yes' to proceed: " answer
    if [[ "$answer" != "yes" ]]; then
        echo "Submission aborted." >&2
        exit 1
    fi
    echo ""
fi

# ── Submit ───────────────────────────────────────────────────────────────────

cardano-cli conway transaction submit \
    "${NETWORK_FLAG[@]}" \
    --tx-file "$TX_SIGNED"

# ── Print transaction hash ──────────────────────────────────────────────────

TX_HASH=$(cardano-cli conway transaction txid --tx-file "$TX_SIGNED")
echo ""
echo "Transaction submitted successfully."
echo "Transaction hash: ${TX_HASH}"
