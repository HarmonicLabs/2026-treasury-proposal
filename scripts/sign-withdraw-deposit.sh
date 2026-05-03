#!/usr/bin/env bash
set -euo pipefail

# sign-withdraw-deposit.sh - Sign the withdraw-deposit transaction.
# Requires two witnesses:
#   1. Payment witness  - covers the fee and receives change.
#   2. Stake witness    - authorises pulling the rewards account balance
#                         (deposit-return stake key).
# Both can be HW or file-based, matching the precedence used elsewhere
# (see register-stake.sh).
#
# Usage: NETWORK=preprod scripts/sign-withdraw-deposit.sh

# shellcheck source=scripts/_lib.sh
source "$(dirname "$0")/_lib.sh"
require_proposal_dir

# ── Network flag ─────────────────────────────────────────────────────────────

case "${NETWORK:-preprod}" in
    mainnet) NETWORK_FLAG=(--mainnet) ;;
    preview) NETWORK_FLAG=(--testnet-magic 2) ;;
    *)       NETWORK_FLAG=(--testnet-magic 1) ;;
esac

# ── Validate prerequisites ──────────────────────────────────────────────────

TX_RAW="${PROPOSAL_DIR}/withdraw-deposit.raw"
if [[ ! -f "$TX_RAW" ]]; then
    echo "Error: Transaction body not found: ${TX_RAW}" >&2
    echo "Run 'make withdraw-deposit-build' first." >&2
    exit 1
fi

if [[ -z "${DEPOSIT_RETURN_STAKE_VKEY:-}" ]]; then
    echo "Error: DEPOSIT_RETURN_STAKE_VKEY is not set." >&2
    exit 1
fi

resolve_path() {
    local p="$1"
    if [[ "$p" != /* ]]; then echo "${REPO_ROOT}/${p}"; else echo "$p"; fi
}

STAKE_VKEY=$(resolve_path "$DEPOSIT_RETURN_STAKE_VKEY")
if [[ ! -f "$STAKE_VKEY" ]]; then
    echo "Error: Stake verification key not found: ${STAKE_VKEY}" >&2
    exit 1
fi

# Determine signing mode: hardware wallet or file-based.
USE_HW=false
if [[ -n "${PAYMENT_HW_SIGNING_FILE:-}" ]]; then
    USE_HW=true
    PAY_HW_PATH=$(resolve_path "$PAYMENT_HW_SIGNING_FILE")
    if [[ ! -f "$PAY_HW_PATH" ]]; then
        echo "Error: Payment hardware signing file not found: ${PAY_HW_PATH}" >&2
        exit 1
    fi

    STAKE_HW_PATH="${DEPOSIT_RETURN_STAKE_HW_SIGNING_FILE:-}"
    if [[ -z "$STAKE_HW_PATH" ]]; then
        echo "Error: DEPOSIT_RETURN_STAKE_HW_SIGNING_FILE is not set." >&2
        echo "Required for hardware-wallet signing of the stake witness." >&2
        exit 1
    fi
    STAKE_HW_PATH=$(resolve_path "$STAKE_HW_PATH")
    if [[ ! -f "$STAKE_HW_PATH" ]]; then
        echo "Error: Stake hardware signing file not found: ${STAKE_HW_PATH}" >&2
        exit 1
    fi
elif [[ -n "${PAYMENT_SKEY:-}" ]]; then
    PAY_SKEY=$(resolve_path "$PAYMENT_SKEY")
    if [[ ! -f "$PAY_SKEY" ]]; then
        echo "Error: Payment signing key not found: ${PAY_SKEY}" >&2
        exit 1
    fi

    STAKE_SKEY="${STAKE_VKEY%.vkey}.skey"
    if [[ ! -f "$STAKE_SKEY" ]]; then
        echo "Error: Stake signing key not found: ${STAKE_SKEY}" >&2
        exit 1
    fi
else
    echo "Error: Neither PAYMENT_HW_SIGNING_FILE nor PAYMENT_SKEY is set." >&2
    exit 1
fi

# ── Sign transaction ─────────────────────────────────────────────────────────

TX_SIGNED="${PROPOSAL_DIR}/withdraw-deposit.signed"

echo "=== Sign Withdraw-Deposit Transaction ==="
echo ""
echo "Network:  ${NETWORK_FLAG[*]}"
echo "Input:    ${TX_RAW}"

if [[ "$USE_HW" == true ]]; then
    echo "Mode:     hardware wallet"
    echo "Pay HW:   ${PAY_HW_PATH}"
    echo "Stake HW: ${STAKE_HW_PATH}"
    echo ""

    cardano-hw-cli transaction transform \
        --tx-file "$TX_RAW" \
        --out-file "$TX_RAW"

    PAY_WITNESS="${TX_RAW}.pay.witness"
    STAKE_WITNESS="${TX_RAW}.stake.witness"

    cardano-hw-cli transaction witness \
        "${NETWORK_FLAG[@]}" \
        --tx-file "$TX_RAW" \
        --hw-signing-file "$PAY_HW_PATH" \
        --out-file "$PAY_WITNESS"

    cardano-hw-cli transaction witness \
        "${NETWORK_FLAG[@]}" \
        --tx-file "$TX_RAW" \
        --hw-signing-file "$STAKE_HW_PATH" \
        --out-file "$STAKE_WITNESS"

    cardano-cli conway transaction assemble \
        --tx-body-file "$TX_RAW" \
        --witness-file "$PAY_WITNESS" \
        --witness-file "$STAKE_WITNESS" \
        --out-file "$TX_SIGNED"

    rm -f "$PAY_WITNESS" "$STAKE_WITNESS"
else
    echo "Mode:     file-based keys"
    echo "Pay key:  ${PAY_SKEY}"
    echo "Stake:    ${STAKE_SKEY}"
    echo ""

    cardano-cli conway transaction sign \
        "${NETWORK_FLAG[@]}" \
        --tx-body-file "$TX_RAW" \
        --signing-key-file "$PAY_SKEY" \
        --signing-key-file "$STAKE_SKEY" \
        --out-file "$TX_SIGNED"
fi

echo "Transaction signed: ${TX_SIGNED}"
