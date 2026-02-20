#!/usr/bin/env bash
set -euo pipefail

# submit-tx.sh - Submit a signed transaction to the Cardano network.
# Usage: scripts/submit-tx.sh <network-flag> [--confirm]
#   e.g.  scripts/submit-tx.sh --mainnet --confirm
#         scripts/submit-tx.sh --testnet-magic 2

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

# ── Source configuration ─────────────────────────────────────────────────────

if [[ -f "${REPO_ROOT}/config.env" ]]; then
    # shellcheck source=/dev/null
    source "${REPO_ROOT}/config.env"
fi

# ── Parse arguments ──────────────────────────────────────────────────────────

if [[ $# -lt 1 ]]; then
    echo "Usage: $(basename "$0") <network-flag> [--confirm]" >&2
    echo "  e.g. $(basename "$0") --mainnet --confirm" >&2
    echo "       $(basename "$0") --testnet-magic 2" >&2
    exit 1
fi

CONFIRM=false
NETWORK_FLAG=()

while [[ $# -gt 0 ]]; do
    case "$1" in
        --confirm)
            CONFIRM=true
            shift
            ;;
        *)
            NETWORK_FLAG+=("$1")
            shift
            ;;
    esac
done

if [[ ${#NETWORK_FLAG[@]} -eq 0 ]]; then
    echo "Error: No network flag provided." >&2
    exit 1
fi

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
