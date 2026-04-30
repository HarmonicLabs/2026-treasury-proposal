#!/usr/bin/env bash
set -euo pipefail

# upload-ipfs.sh - Upload metadata to IPFS via Pinata.
# Uploads the metadata JSON and outputs the CID and ipfs:// URL.
# Skips upload if an identical file is already pinned.
#
# Usage: scripts/upload-ipfs.sh [metadata-file]
#   metadata-file  Path to the metadata JSON (default: metadata/proposal-metadata.json)
#
# Requires PINATA_JWT in config.env or environment.

# shellcheck source=scripts/_lib.sh
source "$(dirname "$0")/_lib.sh"
require_proposal_dir

METADATA_FILE="${1:-${PROPOSAL_DIR}/metadata/proposal-metadata.json}"

echo "=== Upload to IPFS (Pinata) ==="
echo ""

# ── Validate inputs ──────────────────────────────────────────────────────────

if [[ ! -f "$METADATA_FILE" ]]; then
    echo "Error: Metadata file not found: ${METADATA_FILE}" >&2
    exit 1
fi

if [[ -z "${PINATA_JWT:-}" ]]; then
    echo "Error: PINATA_JWT is not set." >&2
    echo "Set it in config.env or export it." >&2
    exit 1
fi

# ── Check if already pinned ──────────────────────────────────────────────────

echo "Computing local CID..."
CID=$(npx --yes ipfs-only-hash "$METADATA_FILE" 2>/dev/null || true)

if [[ -n "$CID" ]]; then
    EXISTING=$(curl -s --max-time 15 \
        "https://api.pinata.cloud/data/pinList?status=pinned&hashContains=${CID}" \
        -H "Authorization: Bearer ${PINATA_JWT}" \
        | jq -r '.count // 0')

    if [[ "$EXISTING" -gt 0 ]]; then
        IPFS_URL="ipfs://${CID}"
        echo ""
        echo "File already pinned on Pinata. Skipping upload."
        echo ""
        echo "CID:      ${CID}"
        echo "IPFS URL: ${IPFS_URL}"
        echo "Gateway:  https://gateway.pinata.cloud/ipfs/${CID}"
        echo ""
        echo "Set ANCHOR_URL in ${PROPOSAL_DIR}/config.env to:"
        echo "  ANCHOR_URL=${IPFS_URL}"
        exit 0
    fi
else
    echo "Warning: Could not compute CID locally, uploading without dedup check." >&2
fi

# ── Upload ───────────────────────────────────────────────────────────────────

FILENAME=$(basename "$METADATA_FILE")

echo "Uploading: ${METADATA_FILE}"
echo ""

RESPONSE=$(curl -s --fail --max-time 60 \
    -X POST "https://api.pinata.cloud/pinning/pinFileToIPFS" \
    -H "Authorization: Bearer ${PINATA_JWT}" \
    -F "file=@${METADATA_FILE};filename=${FILENAME}" \
    -F "pinataMetadata={\"name\":\"${FILENAME}\"}")

CID=$(echo "$RESPONSE" | jq -r '.IpfsHash // empty')

if [[ -z "$CID" ]]; then
    echo "Error: Upload failed. Response:" >&2
    echo "$RESPONSE" >&2
    exit 1
fi

IPFS_URL="ipfs://${CID}"

echo "Uploaded successfully."
echo ""
echo "CID:      ${CID}"
echo "IPFS URL: ${IPFS_URL}"
echo "Gateway:  https://gateway.pinata.cloud/ipfs/${CID}"
echo ""
echo "Set ANCHOR_URL in ${PROPOSAL_DIR}/config.env to:"
echo "  ANCHOR_URL=${IPFS_URL}"
