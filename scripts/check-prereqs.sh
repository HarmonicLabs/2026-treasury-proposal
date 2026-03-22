#!/usr/bin/env bash
set -euo pipefail

# check-prereqs.sh - Verify all required tools are installed and functional.
# Usage: scripts/check-prereqs.sh

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

MISSING=0

# ── Helper ───────────────────────────────────────────────────────────────────

check_tool() {
    local name="$1"
    shift
    if command -v "$name" >/dev/null 2>&1; then
        local version
        version=$("$@" 2>&1 | head -1) || version="(version unknown)"
        echo "  [OK]  ${name}: ${version}"
    else
        echo "  [MISSING]  ${name} is not installed or not in PATH." >&2
        MISSING=$((MISSING + 1))
    fi
}

# ── Checks ───────────────────────────────────────────────────────────────────

echo "=== Prerequisite Check ==="
echo ""

# cardano-cli
check_tool cardano-cli cardano-cli --version

# Verify Conway governance capability
if command -v cardano-cli >/dev/null 2>&1; then
    if cardano-cli conway governance action create-treasury-withdrawal --help >/dev/null 2>&1; then
        echo "  [OK]  cardano-cli Conway governance support confirmed"
    else
        echo "  [FAIL]  cardano-cli lacks Conway governance support." >&2
        echo "          'conway governance action create-treasury-withdrawal --help' failed." >&2
        echo "          Ensure cardano-cli v8.x+ with Conway era support." >&2
        MISSING=$((MISSING + 1))
    fi
fi

# jq
check_tool jq jq --version

# basenc (GNU coreutils)
check_tool basenc basenc --version

# cardano-hw-cli (optional, for hardware wallet signing)
if command -v cardano-hw-cli >/dev/null 2>&1; then
    check_tool cardano-hw-cli cardano-hw-cli version
else
    echo "  [SKIP]  cardano-hw-cli not installed (optional, needed for hardware wallet signing)"
fi

# make
check_tool make make --version

echo ""

# ── Result ───────────────────────────────────────────────────────────────────

if [[ "$MISSING" -gt 0 ]]; then
    echo "FAIL: ${MISSING} prerequisite(s) missing or non-functional." >&2
    exit 1
fi

echo "All prerequisites satisfied."
