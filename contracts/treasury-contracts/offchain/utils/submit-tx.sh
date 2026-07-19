#!/usr/bin/env bash
set -euo pipefail

# submit-tx.sh — Submit a signed transaction to the chain via Blockfrost.
#
# Reads `tx.signed` (a cardano-cli "Tx ConwayEra" text envelope), extracts the
# CBOR, and POSTs it to Blockfrost's /tx/submit. Prints the transaction hash on
# success.
#
# Usage (from the offchain dir, or anywhere):
#   utils/submit-tx.sh                     # tx.signed next to the offchain root
#   utils/submit-tx.sh path/to/tx.signed   # custom input
#
# Config:
#   BLOCKFROST_KEY  required; read from the environment, else from .env.local / .env
#                   (offchain root). The network is inferred from the key prefix.
#   NETWORK         optional override: mainnet | preprod | preview

# ── Resolve locations ────────────────────────────────────────────────────────

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OFFCHAIN_DIR="$(dirname "$SCRIPT_DIR")"

TX_SIGNED="${1:-$OFFCHAIN_DIR/tx.signed}"

# ── Load BLOCKFROST_KEY from .env.local / .env if not already set ─────────────
# (explicit environment wins; .env.local overrides .env, matching the CLI)

load_key_from() {
    local file="$1"
    [[ -f "$file" ]] || return 0
    local val
    val="$(grep -E '^[[:space:]]*BLOCKFROST_KEY=' "$file" | tail -n1 | cut -d= -f2-)"
    val="${val%\"}"; val="${val#\"}"; val="${val%\'}"; val="${val#\'}" # strip quotes
    [[ -n "$val" ]] && BLOCKFROST_KEY="$val"
}
if [[ -z "${BLOCKFROST_KEY:-}" ]]; then
    load_key_from "$OFFCHAIN_DIR/.env"
    load_key_from "$OFFCHAIN_DIR/.env.local"
fi

# ── Validate prerequisites ───────────────────────────────────────────────────

for tool in curl jq xxd; do
    command -v "$tool" >/dev/null 2>&1 || { echo "Error: '$tool' not found in PATH" >&2; exit 1; }
done
[[ -f "$TX_SIGNED" ]]            || { echo "Error: signed tx not found: $TX_SIGNED" >&2; exit 1; }
[[ -n "${BLOCKFROST_KEY:-}" ]]  || { echo "Error: BLOCKFROST_KEY not set (env or .env.local)" >&2; exit 1; }

case "${NETWORK:-${BLOCKFROST_KEY:0:7}}" in
    mainnet*) BASE="https://cardano-mainnet.blockfrost.io/api/v0" ;;
    preprod*) BASE="https://cardano-preprod.blockfrost.io/api/v0" ;;
    preview*) BASE="https://cardano-preview.blockfrost.io/api/v0" ;;
    *) echo "Error: cannot determine network from NETWORK/BLOCKFROST_KEY (expected mainnet|preprod|preview prefix)" >&2; exit 1 ;;
esac

CBOR_HEX="$(jq -er '.cborHex' "$TX_SIGNED")" || { echo "Error: no .cborHex in $TX_SIGNED" >&2; exit 1; }

echo "=== Submit transaction via Blockfrost ==="
echo "Input:    $TX_SIGNED"
echo "Endpoint: $BASE/tx/submit"
echo "Tx size:  $(( ${#CBOR_HEX} / 2 )) bytes"
echo ""

# ── Submit: POST raw CBOR bytes (application/cbor) ────────────────────────────

HTTP_BODY="$(mktemp)"
trap 'rm -f "$HTTP_BODY"' EXIT

HTTP_CODE="$(
    printf '%s' "$CBOR_HEX" | xxd -r -p | curl -sS \
        -X POST "$BASE/tx/submit" \
        -H "project_id: $BLOCKFROST_KEY" \
        -H "Content-Type: application/cbor" \
        --data-binary @- \
        -o "$HTTP_BODY" -w '%{http_code}'
)"

if [[ "$HTTP_CODE" == "200" ]]; then
    TX_HASH="$(jq -r '.' "$HTTP_BODY" 2>/dev/null || cat "$HTTP_BODY")"
    echo "Submitted. Transaction hash:"
    echo "$TX_HASH"
else
    echo "Submission failed (HTTP $HTTP_CODE):" >&2
    jq . "$HTTP_BODY" 2>/dev/null || cat "$HTTP_BODY" >&2
    exit 1
fi
