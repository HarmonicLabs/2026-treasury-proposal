#!/usr/bin/env bash
set -euo pipefail

# ensure-aiken.sh - Ensure the correct aiken compiler version is installed.
# Reads the required version from contracts/treasury-contracts/aiken.toml
# and installs it via aikup if needed.
#
# Usage: scripts/ensure-aiken.sh
#   or:  make ensure-aiken

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CONTRACT_DIR="${REPO_ROOT}/contracts/treasury-contracts"

if [[ ! -f "${CONTRACT_DIR}/aiken.toml" ]]; then
    echo "Error: ${CONTRACT_DIR}/aiken.toml not found." >&2
    exit 1
fi

REQUIRED_AIKEN_VERSION=$(grep -oP '^compiler\s*=\s*"v\K[0-9]+\.[0-9]+\.[0-9]+' "${CONTRACT_DIR}/aiken.toml")

if [[ -z "$REQUIRED_AIKEN_VERSION" ]]; then
    echo "Error: Could not parse compiler version from aiken.toml." >&2
    exit 1
fi

if ! command -v aiken &>/dev/null; then
    echo "aiken not found. Installing v${REQUIRED_AIKEN_VERSION}..." >&2
    aikup install "v${REQUIRED_AIKEN_VERSION}"
else
    AIKEN_VERSION=$(aiken --version 2>&1 | grep -oP 'v\K[0-9]+\.[0-9]+\.[0-9]+')
    if [[ "$AIKEN_VERSION" == "$REQUIRED_AIKEN_VERSION" ]]; then
        echo "aiken v${AIKEN_VERSION} ✓"
        exit 0
    fi
    echo "aiken v${REQUIRED_AIKEN_VERSION} required (found v${AIKEN_VERSION}). Installing..." >&2
    aikup install "v${REQUIRED_AIKEN_VERSION}"
fi

# Verify
AIKEN_VERSION=$(aiken --version 2>&1 | grep -oP 'v\K[0-9]+\.[0-9]+\.[0-9]+')
if [[ "$AIKEN_VERSION" != "$REQUIRED_AIKEN_VERSION" ]]; then
    echo "Error: Failed to install aiken v${REQUIRED_AIKEN_VERSION}." >&2
    exit 1
fi

echo "aiken v${AIKEN_VERSION} ✓"
