#!/usr/bin/env bash
set -euo pipefail

# journal-entry.sh - Interactive script to create a transparency journal entry.
# Creates a dated markdown file in journal/ recording on-chain transactions
# per the SundaeSwap metadata standard.

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
JOURNAL_DIR="${REPO_ROOT}/journal"

# ── Helpers ──────────────────────────────────────────────────────────────────

prompt() {
    local var_name="$1" prompt_text="$2" default="${3:-}"
    if [[ -n "$default" ]]; then
        read -rp "${prompt_text} [${default}]: " value
        eval "${var_name}=\"${value:-$default}\""
    else
        while true; do
            read -rp "${prompt_text}: " value
            if [[ -n "$value" ]]; then
                eval "${var_name}=\"${value}\""
                return
            fi
            echo "  Value is required." >&2
        done
    fi
}

validate_tx_hash() {
    local hash="$1"
    if [[ ! "$hash" =~ ^[0-9a-fA-F]{64}$ ]]; then
        echo "Error: Transaction hash must be exactly 64 hexadecimal characters." >&2
        echo "       Got: ${hash}" >&2
        return 1
    fi
}

select_action() {
    echo "Select action type:"
    echo "  1) disbursement"
    echo "  2) milestone-claim"
    echo "  3) sweep-early"
    echo "  4) reorganize"
    echo "  5) fund"
    echo "  6) pause"
    echo "  7) resume"
    echo "  8) modify-project"
    echo "  9) other"
    while true; do
        read -rp "Choice [1-9]: " choice
        case "$choice" in
            1) ACTION="disbursement"; return ;;
            2) ACTION="milestone-claim"; return ;;
            3) ACTION="sweep-early"; return ;;
            4) ACTION="reorganize"; return ;;
            5) ACTION="fund"; return ;;
            6) ACTION="pause"; return ;;
            7) ACTION="resume"; return ;;
            8) ACTION="modify-project"; return ;;
            9) prompt ACTION "Describe the action"; return ;;
            *) echo "  Please enter a number between 1 and 9." >&2 ;;
        esac
    done
}

# ── Collect information ─────────────────────────────────────────────────────

echo "=== Treasury Journal Entry ==="
echo ""

# Date
TODAY="$(date +%Y-%m-%d)"
prompt ENTRY_DATE "Transaction date (YYYY-MM-DD)" "$TODAY"

# Transaction hash (with validation)
while true; do
    prompt TX_HASH "Transaction hash (64 hex chars)"
    if validate_tx_hash "$TX_HASH"; then
        break
    fi
done

# Action type
select_action

# Amount
prompt AMOUNT "Amount in ADA (use 0 for non-financial actions)"

# Signers
prompt SIGNERS "Signers (comma-separated names or roles)"

# Justification
prompt JUSTIFICATION "Justification (why was this transaction made)"

# Metadata hash (optional)
read -rp "Metadata hash (leave blank if none): " METADATA_HASH
METADATA_HASH="${METADATA_HASH:-N/A}"

# ── Build the filename ──────────────────────────────────────────────────────

# Slugify the action for the filename
SLUG="$(echo "$ACTION" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | tr -cd '[:alnum:]-')"
FILENAME="${ENTRY_DATE}-${SLUG}.md"
FILEPATH="${JOURNAL_DIR}/${FILENAME}"

if [[ -f "$FILEPATH" ]]; then
    echo ""
    echo "Warning: ${FILENAME} already exists." >&2
    read -rp "Overwrite? [y/N]: " confirm
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        echo "Aborted." >&2
        exit 1
    fi
fi

# ── Write the entry ─────────────────────────────────────────────────────────

cat > "$FILEPATH" <<EOF
# Journal Entry: ${ACTION}

| Field | Value |
|-------|-------|
| **Date** | ${ENTRY_DATE} |
| **Transaction Hash** | \`${TX_HASH}\` |
| **Action** | ${ACTION} |
| **Amount (ADA)** | ${AMOUNT} |
| **Signers** | ${SIGNERS} |
| **Justification** | ${JUSTIFICATION} |
| **Metadata Hash** | \`${METADATA_HASH}\` |

## Notes

<!-- Add any additional context, links to explorer, or supporting information -->
EOF

echo ""
echo "Journal entry created: ${FILEPATH}"
echo "Review and commit when ready."
