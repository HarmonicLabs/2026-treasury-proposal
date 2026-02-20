#!/usr/bin/env bash
set -euo pipefail

# hash-metadata.sh - Hash proposal metadata using cardano-cli blake2b-256.
# Usage: scripts/hash-metadata.sh [metadata-file]
#   metadata-file  Path to the metadata JSON (default: metadata/proposal-metadata.json)

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
METADATA_FILE="${1:-${REPO_ROOT}/metadata/proposal-metadata.json}"
HASH_OUTPUT="${REPO_ROOT}/metadata/metadata-hash.txt"

echo "=== Hash Proposal Metadata ==="
echo ""

# ── Validate input ───────────────────────────────────────────────────────────

if [[ ! -f "$METADATA_FILE" ]]; then
    echo "Error: Metadata file not found: ${METADATA_FILE}" >&2
    echo "Run 'make metadata' first to generate it." >&2
    exit 1
fi

# ── Compute hash ─────────────────────────────────────────────────────────────

HASH=$(cardano-cli hash anchor-data --file-text "$METADATA_FILE")

if [[ -z "$HASH" ]]; then
    echo "Error: cardano-cli returned empty hash." >&2
    exit 1
fi

# ── Write output ─────────────────────────────────────────────────────────────

mkdir -p "$(dirname "$HASH_OUTPUT")"
echo -n "$HASH" > "$HASH_OUTPUT"

echo "Input:  ${METADATA_FILE}"
echo "Hash:   ${HASH}"
echo "Saved:  ${HASH_OUTPUT}"
