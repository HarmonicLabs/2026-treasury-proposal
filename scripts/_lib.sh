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

# Validate that a CIP-100/108 metadata file has a fully populated authors[]
# witness. Cardano explorers and GovTool flag a governance action as
# malformed without it, and once the anchor-data-hash is pinned on-chain it
# cannot be changed without resubmitting the action (= another 100k ADA
# deposit). Aborts the calling script with a non-zero exit on any failure.
require_metadata_authors() {
    local metadata_file="$1"

    if [[ ! -f "$metadata_file" ]]; then
        echo "Error: Metadata file not found: ${metadata_file}" >&2
        exit 1
    fi

    local errors
    errors=$(jq -r '
        def fail(msg): "ERROR: " + msg;
        [
            if (.authors | type) != "array" or (.authors | length) == 0
            then fail("authors[] is missing or empty")
            else empty end,
            (.authors // [] | to_entries[] | .key as $i | .value |
                (
                    if (.name // "" | length) == 0 or (.name | startswith("TODO"))
                    then fail("authors[\($i)].name is empty or a TODO placeholder")
                    else empty end
                ),
                (
                    if (.witness.witnessAlgorithm // "") != "ed25519"
                    then fail("authors[\($i)].witness.witnessAlgorithm must be \"ed25519\"")
                    else empty end
                ),
                (
                    if (.witness.publicKey // "" | length) == 0
                    then fail("authors[\($i)].witness.publicKey is empty (run sign-metadata.sh)")
                    else empty end
                ),
                (
                    if (.witness.signature // "" | length) == 0
                    then fail("authors[\($i)].witness.signature is empty (run sign-metadata.sh)")
                    else empty end
                )
            )
        ] | .[]
    ' "$metadata_file")

    if [[ -n "$errors" ]]; then
        echo "Metadata fails CIP-100 authors validation: ${metadata_file}" >&2
        echo "" >&2
        echo "$errors" >&2
        echo "" >&2
        echo "Fix the file and re-run. Once the anchor-data-hash is pinned on-chain" >&2
        echo "it cannot be changed without resubmitting the gov action." >&2
        exit 1
    fi
}
