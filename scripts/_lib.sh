#!/usr/bin/env bash
# _lib.sh - Shared bootstrap for proposal scripts.
# Sourced from other scripts to resolve REPO_ROOT, PROPOSAL_DIR, and load config.
#
# Inputs (env):
#   PROPOSAL_DIR  Path to the proposal subfolder (relative or absolute).
#                 If unset, scripts that need proposal-specific paths must error.
#
# Outputs (env):
#   REPO_ROOT     Absolute path to the repo root.
#   PROPOSAL_DIR  Absolute path to the proposal subfolder, or empty if unset.
#   Plus all variables exported by config.shared.env and ${PROPOSAL_DIR}/config.env.

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if [[ -n "${PROPOSAL_DIR:-}" && "$PROPOSAL_DIR" != /* ]]; then
    PROPOSAL_DIR="${REPO_ROOT}/${PROPOSAL_DIR}"
fi
PROPOSAL_DIR="${PROPOSAL_DIR:-}"

# Load shared config first so per-proposal values can override.
if [[ -f "${REPO_ROOT}/config.shared.env" ]]; then
    set -a
    # shellcheck source=/dev/null
    source "${REPO_ROOT}/config.shared.env"
    set +a
fi

if [[ -n "$PROPOSAL_DIR" && -f "${PROPOSAL_DIR}/config.env" ]]; then
    set -a
    # shellcheck source=/dev/null
    source "${PROPOSAL_DIR}/config.env"
    set +a
elif [[ -f "${REPO_ROOT}/config.env" ]]; then
    set -a
    # shellcheck source=/dev/null
    source "${REPO_ROOT}/config.env"
    set +a
fi

require_proposal_dir() {
    if [[ -z "$PROPOSAL_DIR" ]]; then
        echo "Error: PROPOSAL_DIR is not set." >&2
        echo "Run via the Makefile with PROPOSAL=pebble-tooling (or =gerolamo)," >&2
        echo "or export PROPOSAL_DIR=proposals/<name> before invoking this script." >&2
        exit 1
    fi
    if [[ ! -d "$PROPOSAL_DIR" ]]; then
        echo "Error: PROPOSAL_DIR does not exist: ${PROPOSAL_DIR}" >&2
        exit 1
    fi
}
