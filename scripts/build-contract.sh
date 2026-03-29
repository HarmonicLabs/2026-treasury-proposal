#!/usr/bin/env bash
set -euo pipefail

# build-contract.sh - Build the treasury contract with oversight members from config.env.
#
# This script:
#   1. Derives the Hlabs key hash from keys/payment.vkey
#   2. Queries on-chain UTxOs to pick a seed for the oneshot mint
#   3. Generates contracts/treasury-contracts/lib/proposal.ak with all real values
#   4. Compiles and extracts CBOR params via aiken check traces
#   5. Applies params to the blueprint and extracts the final plutus script
#
# Usage: NETWORK=preprod scripts/build-contract.sh
#   or:  make build-contract

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CONTRACT_DIR="${REPO_ROOT}/contracts/treasury-contracts"

# ── Source configuration ─────────────────────────────────────────────────────

if [[ -f "${REPO_ROOT}/config.env" ]]; then
    set -a
    # shellcheck source=/dev/null
    source "${REPO_ROOT}/config.env"
    set +a
fi

# ── Network flag ─────────────────────────────────────────────────────────────

case "${NETWORK:-preprod}" in
    mainnet) NETWORK_MAGIC=(--mainnet) ;;
    preview) NETWORK_MAGIC=(--testnet-magic 2) ;;
    preprod) NETWORK_MAGIC=(--testnet-magic 1) ;;
    *)       NETWORK_MAGIC=(--testnet-magic 1) ;;
esac

# ── Validate prerequisites ───────────────────────────────────────────────────

MISSING=0
for cmd in aiken cardano-cli jq python3; do
    if ! command -v "$cmd" &>/dev/null; then
        echo "Error: $cmd not found in PATH." >&2
        MISSING=$((MISSING + 1))
    fi
done

"${REPO_ROOT}/scripts/ensure-aiken.sh"

for var in PAYMENT_ADDRESS OVERSIGHT_SANTIAGO_CARMUEGA OVERSIGHT_CHRIS_GIANELLONI OVERSIGHT_LUCAS_ROSA; do
    if [[ -z "${!var:-}" ]]; then
        echo "Error: ${var} is not set in config.env." >&2
        MISSING=$((MISSING + 1))
    fi
done

if [[ ! -f "${REPO_ROOT}/keys/payment.vkey" ]]; then
    echo "Error: keys/payment.vkey not found." >&2
    MISSING=$((MISSING + 1))
fi

[[ $MISSING -gt 0 ]] && exit 1

# ── Derive Hlabs key hash ────────────────────────────────────────────────────

HLABS_KEY_HASH=$(cardano-cli conway address key-hash \
    --payment-verification-key-file "${REPO_ROOT}/keys/payment.vkey")

echo "Hlabs key hash: ${HLABS_KEY_HASH}"

# ── Timestamps (from config.env, converted to POSIX milliseconds) ────────────

date_to_ms() {
    local input="$1"
    local name="$2"
    local ms
    ms=$(node -e "const d = new Date('${input}'); if (isNaN(d)) { process.exit(1); } console.log(d.valueOf())" 2>/dev/null)
    if [[ -z "$ms" ]]; then
        echo "Error: Invalid date for ${name}: '${input}'" >&2
        echo "Must be a valid input to JavaScript's new Date() constructor." >&2
        exit 1
    fi
    echo "$ms"
}

TREASURY_EXPIRATION_INPUT="${TREASURY_EXPIRATION:-2030-01-01T00:00:00Z}"
PAYOUT_UPPERBOUND_INPUT="${PAYOUT_UPPERBOUND:-2030-02-01T00:00:00Z}"
VENDOR_EXPIRATION_INPUT="${VENDOR_EXPIRATION:-2030-03-04T00:00:00Z}"

TREASURY_EXPIRATION=$(date_to_ms "$TREASURY_EXPIRATION_INPUT" "TREASURY_EXPIRATION")
PAYOUT_UPPERBOUND=$(date_to_ms "$PAYOUT_UPPERBOUND_INPUT" "PAYOUT_UPPERBOUND")
VENDOR_EXPIRATION=$(date_to_ms "$VENDOR_EXPIRATION_INPUT" "VENDOR_EXPIRATION")

echo "Treasury expiration: ${TREASURY_EXPIRATION_INPUT} → ${TREASURY_EXPIRATION}"
echo "Payout upperbound:   ${PAYOUT_UPPERBOUND_INPUT} → ${PAYOUT_UPPERBOUND}"
echo "Vendor expiration:   ${VENDOR_EXPIRATION_INPUT} → ${VENDOR_EXPIRATION}"

# ── Query UTxOs and pick seed ─────────────────────────────────────────────────

echo ""
echo "Querying UTxOs at ${PAYMENT_ADDRESS}..."
UTXO_JSON=$(cardano-cli conway query utxo \
    --address "${PAYMENT_ADDRESS}" \
    "${NETWORK_MAGIC[@]}" \
    --out-file /dev/stdout)

# Pick the first UTxO with enough ADA (>5 ADA)
SEED=$(echo "$UTXO_JSON" | jq -r '
    to_entries[]
    | select(.value.value.lovelace > 5000000)
    | .key
' | head -1)

if [[ -z "$SEED" ]]; then
    echo "Error: No suitable UTxO found at ${PAYMENT_ADDRESS}." >&2
    echo "Fund the address with at least 5 ADA." >&2
    exit 1
fi

SEED_TX=$(echo "$SEED" | cut -d'#' -f1)
SEED_IX=$(echo "$SEED" | cut -d'#' -f2)

echo "Seed UTxO: ${SEED_TX}#${SEED_IX}"

# ── Generate proposal.ak ─────────────────────────────────────────────────────

echo ""
echo "Generating lib/proposal.ak..."

# Registry token placeholder — will be replaced after oneshot policy is derived
REGISTRY_PLACEHOLDER="0000000000000000000000000000000000000000000000000000000000"

cat > "${CONTRACT_DIR}/lib/proposal.ak" << AIKEN
use aiken/cbor
use aiken/primitive/bytearray
use cardano/transaction.{OutputReference}
use sundae/multisig.{AllOf, AnyOf, AtLeast, MultisigScript, Signature}
use types.{
  TreasuryConfiguration, TreasuryPermissions, VendorConfiguration,
  VendorPermissions,
}

// Seed UTxO
fn seed_utxo() -> OutputReference {
  OutputReference {
    transaction_id: #"${SEED_TX}",
    output_index: ${SEED_IX},
  }
}

// Proposer / Vendor entity (Hlabs - Michele Nuzzi)
fn hlabs() -> MultisigScript {
  Signature {
    key_hash: #"${HLABS_KEY_HASH}",
  }
}

// Oversight board entities

fn santiago_carmuega() -> MultisigScript {
  Signature {
    key_hash: #"${OVERSIGHT_SANTIAGO_CARMUEGA}",
  }
}

fn chris_gianelloni() -> MultisigScript {
  Signature {
    key_hash: #"${OVERSIGHT_CHRIS_GIANELLONI}",
  }
}

fn lucas_rosa() -> MultisigScript {
  Signature {
    key_hash: #"${OVERSIGHT_LUCAS_ROSA}",
  }
}

// Groups

fn oversight_board() -> List<MultisigScript> {
  [santiago_carmuega(), chris_gianelloni(), lucas_rosa()]
}

// Treasury Permissions

fn reorganize() -> MultisigScript {
  hlabs()
}

fn sweep_treasury() -> MultisigScript {
  AllOf {
    scripts: [hlabs(), AnyOf { scripts: oversight_board() }],
  }
}

fn fund() -> MultisigScript {
  AtLeast { required: 2, scripts: oversight_board() }
}

fn disburse() -> MultisigScript {
  AllOf {
    scripts: [hlabs(), AnyOf { scripts: oversight_board() }],
  }
}

// Vendor Permissions

fn pause() -> MultisigScript {
  AnyOf { scripts: oversight_board() }
}

fn resume() -> MultisigScript {
  AtLeast { required: 2, scripts: oversight_board() }
}

fn modify() -> MultisigScript {
  AllOf {
    scripts: [hlabs(), AtLeast { required: 2, scripts: oversight_board() }],
  }
}

// Configuration

pub fn registry_token() {
  #"${REGISTRY_PLACEHOLDER}"
}

pub fn treasury_expiration() {
  ${TREASURY_EXPIRATION}
}

pub fn payout_upperbound() {
  ${PAYOUT_UPPERBOUND}
}

pub fn vendor_expiration() {
  ${VENDOR_EXPIRATION}
}

pub fn treasury_configuration() -> TreasuryConfiguration {
  TreasuryConfiguration {
    registry_token: registry_token(),
    permissions: TreasuryPermissions {
      reorganize: reorganize(),
      sweep: sweep_treasury(),
      fund: fund(),
      disburse: disburse(),
    },
    expiration: treasury_expiration(),
    payout_upperbound: payout_upperbound(),
  }
}

pub fn vendor_configuration() -> VendorConfiguration {
  VendorConfiguration {
    registry_token: registry_token(),
    permissions: VendorPermissions {
      pause: pause(),
      resume: resume(),
      modify: modify(),
    },
    expiration: vendor_expiration(),
  }
}

// Display tests — trace CBOR hex for extraction

test display_seed_utxo() {
  trace bytearray.to_hex(cbor.serialise(seed_utxo()))
  True
}

test display_treasury_config() {
  trace bytearray.to_hex(cbor.serialise(treasury_configuration()))
  True
}

test display_vendor_config() {
  trace bytearray.to_hex(cbor.serialise(vendor_configuration()))
  True
}
AIKEN

echo "Generated proposal.ak with placeholder registry token."

# ── Phase 1: Build and derive registry token from oneshot policy ─────────────

cd "${CONTRACT_DIR}"

echo ""
echo "Building contracts (phase 1)..."
aiken build 2>&1

# Extract seed UTxO CBOR from aiken check
SEED_UTXO_CBOR=$(aiken check 2>/dev/null | python3 -c "
import json, sys
data = json.load(sys.stdin)
for module in data.get('modules', []):
    if module.get('name') == 'proposal':
        for test in module.get('tests', []):
            if test.get('title') == 'display_seed_utxo':
                print(test['traces'][0])
                sys.exit(0)
sys.exit(1)
")

echo "Seed UTxO CBOR: ${SEED_UTXO_CBOR}"

# Apply seed UTxO to oneshot and extract registry policy ID
aiken blueprint apply -v "oneshot" "${SEED_UTXO_CBOR}" 2>/dev/null > tmp
mv tmp plutus.json
REGISTRY_TOKEN=$(aiken blueprint policy -v oneshot 2>/dev/null)

echo "Registry token (oneshot policy ID): ${REGISTRY_TOKEN}"

# ── Phase 2: Regenerate proposal.ak with real registry token ─────────────────

echo ""
echo "Regenerating proposal.ak with real registry token..."

# Replace placeholder with real registry token
sed -i "s/${REGISTRY_PLACEHOLDER}/${REGISTRY_TOKEN}/" "${CONTRACT_DIR}/lib/proposal.ak"

# Rebuild with real registry token
echo "Building contracts (phase 2)..."
aiken build 2>&1

# Extract treasury and vendor CBOR from aiken check
CBOR_OUTPUT=$(aiken check 2>/dev/null | python3 -c "
import json, sys
data = json.load(sys.stdin)
for module in data.get('modules', []):
    if module.get('name') == 'proposal':
        result = {}
        for test in module.get('tests', []):
            title = test.get('title', '')
            traces = test.get('traces', [])
            if traces:
                result[title] = traces[0]
        print(result.get('display_seed_utxo', ''))
        print(result.get('display_treasury_config', ''))
        print(result.get('display_vendor_config', ''))
        sys.exit(0)
sys.exit(1)
")

SEED_UTXO_CBOR=$(echo "$CBOR_OUTPUT" | sed -n '1p')
TREASURY_CBOR=$(echo "$CBOR_OUTPUT" | sed -n '2p')
VENDOR_CBOR=$(echo "$CBOR_OUTPUT" | sed -n '3p')

echo "Treasury config CBOR length: ${#TREASURY_CBOR}"
echo "Vendor config CBOR length:   ${#VENDOR_CBOR}"

# ── Phase 3: Apply all params to blueprint ────────────────────────────────────

echo ""
echo "Applying parameters to blueprint..."

# Start fresh
aiken build 2>&1

# Apply seed UTxO to oneshot
aiken blueprint apply -v "oneshot" "${SEED_UTXO_CBOR}" 2>/dev/null > tmp
mv tmp plutus.json

# Apply treasury config
aiken blueprint apply -v "treasury" "${TREASURY_CBOR}" 2>/dev/null > tmp
mv tmp plutus.json

# Apply vendor config
aiken blueprint apply -v "vendor" "${VENDOR_CBOR}" 2>/dev/null > tmp
mv tmp plutus.json

# Extract script hashes
REGISTRY_POLICY_ID=$(aiken blueprint policy -v oneshot 2>/dev/null)
TREASURY_SCRIPT_HASH=$(aiken blueprint policy -v treasury 2>/dev/null)
VENDOR_SCRIPT_HASH=$(aiken blueprint policy -v vendor 2>/dev/null)

# ── Phase 4: Extract compiled treasury validator ──────────────────────────────

echo ""
echo "Extracting treasury contract to scripts/treasury-contract.plutus..."

jq '{
  type: "PlutusScriptV3",
  description: "Treasury Contract",
  cborHex: (.validators[] | select(.title == "treasury.treasury.else") | .compiledCode)
}' plutus.json > "${REPO_ROOT}/scripts/treasury-contract.plutus"

# Extract compiled script CBOR for metadata.json
TREASURY_COMPILED=$(jq -r '.validators[] | select(.title == "treasury.treasury.else") | .compiledCode' plutus.json)
VENDOR_COMPILED=$(jq -r '.validators[] | select(.title == "vendor.vendor.else") | .compiledCode' plutus.json)

# Restore clean blueprint
aiken build 2>&1 > /dev/null

# ── Phase 5: Generate offchain metadata.json ─────────────────────────────────

METADATA_JSON="${REPO_ROOT}/contracts/treasury-contracts/offchain/metadata.json"

echo ""
echo "Generating offchain metadata.json..."

# Determine network ID (0 = testnet, 1 = mainnet)
case "${NETWORK:-preprod}" in
    mainnet) NETWORK_ID=1 ;;
    *)       NETWORK_ID=0 ;;
esac

# Preserve label/description/comment from existing metadata if present
EXISTING_LABEL=""
EXISTING_DESCRIPTION=""
EXISTING_COMMENT="null"
if [[ -f "$METADATA_JSON" ]]; then
    FIRST_INSTANCE=$(jq -r 'keys[0] // empty' "$METADATA_JSON")
    if [[ -n "$FIRST_INSTANCE" ]]; then
        EXISTING_LABEL=$(jq -r --arg k "$FIRST_INSTANCE" '.[$k].metadata.body.label // empty' "$METADATA_JSON")
        EXISTING_DESCRIPTION=$(jq -r --arg k "$FIRST_INSTANCE" '.[$k].metadata.body.description // empty' "$METADATA_JSON")
        EXISTING_COMMENT=$(jq --arg k "$FIRST_INSTANCE" '.[$k].metadata.comment // null' "$METADATA_JSON")
    fi
fi

LABEL="${EXISTING_LABEL:-Hlabs Treasury}"
DESCRIPTION="${EXISTING_DESCRIPTION:-Hlabs treasury proposal}"

jq -n \
    --arg registry "$REGISTRY_POLICY_ID" \
    --arg hlabs "$HLABS_KEY_HASH" \
    --arg santiago "$OVERSIGHT_SANTIAGO_CARMUEGA" \
    --arg chris "$OVERSIGHT_CHRIS_GIANELLONI" \
    --arg lucas "$OVERSIGHT_LUCAS_ROSA" \
    --arg treasury_exp "$TREASURY_EXPIRATION" \
    --arg payout_ub "$PAYOUT_UPPERBOUND" \
    --arg vendor_exp "$VENDOR_EXPIRATION" \
    --arg seed_tx "$SEED_TX" \
    --arg seed_ix "$SEED_IX" \
    --arg label "$LABEL" \
    --arg description "$DESCRIPTION" \
    --argjson comment "$EXISTING_COMMENT" \
    --arg treasury_cbor "$TREASURY_COMPILED" \
    --arg vendor_cbor "$VENDOR_COMPILED" \
    --argjson network "$NETWORK_ID" \
    '
{
  ($registry): {
    "metadata": {
      "@context": "https://raw.githubusercontent.com/SundaeSwap-finance/treasury-contracts/refs/heads/main/offchain/src/metadata/context.jsonld",
      "hashAlgorithm": "blake2b-256",
      "body": {
        "event": "publish",
        "expiration": $treasury_exp,
        "payoutUpperbound": $payout_ub,
        "vendorExpiration": $vendor_exp,
        "label": $label,
        "description": $description,
        "permissions": {
          "reorganize": {
            "label": "Hlabs",
            "signature": { "keyHash": $hlabs }
          },
          "sweep": {
            "allOf": {
              "scripts": [
                { "label": "Hlabs", "signature": { "keyHash": $hlabs } },
                { "label": "Any oversight member", "anyOf": {
                    "scripts": [
                      { "label": "Santiago Carmuega", "signature": { "keyHash": $santiago } },
                      { "label": "Chris Gianelloni", "signature": { "keyHash": $chris } },
                      { "label": "Lucas Rosa", "signature": { "keyHash": $lucas } }
                    ]
                  }
                }
              ]
            }
          },
          "fund": {
            "label": "Oversight majority",
            "atLeast": {
              "required": "2",
              "scripts": [
                { "label": "Santiago Carmuega", "signature": { "keyHash": $santiago } },
                { "label": "Chris Gianelloni", "signature": { "keyHash": $chris } },
                { "label": "Lucas Rosa", "signature": { "keyHash": $lucas } }
              ]
            }
          },
          "disburse": {
            "allOf": {
              "scripts": [
                { "label": "Hlabs", "signature": { "keyHash": $hlabs } },
                { "label": "Any oversight member", "anyOf": {
                    "scripts": [
                      { "label": "Santiago Carmuega", "signature": { "keyHash": $santiago } },
                      { "label": "Chris Gianelloni", "signature": { "keyHash": $chris } },
                      { "label": "Lucas Rosa", "signature": { "keyHash": $lucas } }
                    ]
                  }
                }
              ]
            }
          },
          "pause": {
            "label": "Any oversight member",
            "anyOf": {
              "scripts": [
                { "label": "Santiago Carmuega", "signature": { "keyHash": $santiago } },
                { "label": "Chris Gianelloni", "signature": { "keyHash": $chris } },
                { "label": "Lucas Rosa", "signature": { "keyHash": $lucas } }
              ]
            }
          },
          "resume": {
            "label": "Oversight majority",
            "atLeast": {
              "required": "2",
              "scripts": [
                { "label": "Santiago Carmuega", "signature": { "keyHash": $santiago } },
                { "label": "Chris Gianelloni", "signature": { "keyHash": $chris } },
                { "label": "Lucas Rosa", "signature": { "keyHash": $lucas } }
              ]
            }
          },
          "modify": {
            "allOf": {
              "scripts": [
                { "label": "Hlabs", "signature": { "keyHash": $hlabs } },
                { "label": "Oversight majority", "atLeast": {
                    "required": "2",
                    "scripts": [
                      { "label": "Santiago Carmuega", "signature": { "keyHash": $santiago } },
                      { "label": "Chris Gianelloni", "signature": { "keyHash": $chris } },
                      { "label": "Lucas Rosa", "signature": { "keyHash": $lucas } }
                    ]
                  }
                }
              ]
            }
          }
        },
        "seedUtxo": {
          "transaction_id": $seed_tx,
          "output_index": $seed_ix
        }
      },
      "instance": $registry,
      "txAuthor": $hlabs,
      "comment": $comment
    },
    "scripts": {
      "treasuryScript": {
        "config": {
          "registry_token": $registry,
          "permissions": {
            "reorganize": { "Signature": { "key_hash": $hlabs } },
            "sweep": { "AllOf": { "scripts": [
              { "Signature": { "key_hash": $hlabs } },
              { "AnyOf": { "scripts": [
                { "Signature": { "key_hash": $santiago } },
                { "Signature": { "key_hash": $chris } },
                { "Signature": { "key_hash": $lucas } }
              ] } }
            ] } },
            "fund": { "AtLeast": { "required": "2", "scripts": [
              { "Signature": { "key_hash": $santiago } },
              { "Signature": { "key_hash": $chris } },
              { "Signature": { "key_hash": $lucas } }
            ] } },
            "disburse": { "AllOf": { "scripts": [
              { "Signature": { "key_hash": $hlabs } },
              { "AnyOf": { "scripts": [
                { "Signature": { "key_hash": $santiago } },
                { "Signature": { "key_hash": $chris } },
                { "Signature": { "key_hash": $lucas } }
              ] } }
            ] } }
          },
          "expiration": $treasury_exp,
          "payout_upperbound": $payout_ub
        },
        "script": $treasury_cbor,
        "network": $network
      },
      "vendorScript": {
        "config": {
          "registry_token": $registry,
          "permissions": {
            "pause": { "AnyOf": { "scripts": [
              { "Signature": { "key_hash": $santiago } },
              { "Signature": { "key_hash": $chris } },
              { "Signature": { "key_hash": $lucas } }
            ] } },
            "resume": { "AtLeast": { "required": "2", "scripts": [
              { "Signature": { "key_hash": $santiago } },
              { "Signature": { "key_hash": $chris } },
              { "Signature": { "key_hash": $lucas } }
            ] } },
            "modify": { "AllOf": { "scripts": [
              { "Signature": { "key_hash": $hlabs } },
              { "AtLeast": { "required": "2", "scripts": [
                { "Signature": { "key_hash": $santiago } },
                { "Signature": { "key_hash": $chris } },
                { "Signature": { "key_hash": $lucas } }
              ] } }
            ] } }
          },
          "expiration": $vendor_exp
        },
        "script": $vendor_cbor,
        "network": $network
      }
    }
  }
}
' > "$METADATA_JSON"

echo "Generated: ${METADATA_JSON}"

# ── Summary ───────────────────────────────────────────────────────────────────

echo ""
echo "============================================================"
echo "  Contract build complete"
echo "============================================================"
echo ""
echo "  Hlabs key hash             = ${HLABS_KEY_HASH}"
echo "  Registry Policy ID         = ${REGISTRY_POLICY_ID}"
echo "  Treasury Contract          = ${TREASURY_SCRIPT_HASH}"
echo "  Vendor Contract            = ${VENDOR_SCRIPT_HASH}"
echo ""
echo "  Seed UTxO                  = ${SEED_TX}#${SEED_IX}"
echo "  Treasury expiration        = ${TREASURY_EXPIRATION}"
echo "  Payout upperbound          = ${PAYOUT_UPPERBOUND}"
echo "  Vendor expiration          = ${VENDOR_EXPIRATION}"
echo ""
echo "  Output: scripts/treasury-contract.plutus"
echo "          contracts/treasury-contracts/offchain/metadata.json"
echo "============================================================"
