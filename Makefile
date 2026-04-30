# Harmonic Labs Treasury Proposals - Makefile
# Usage: make [target] [PROPOSAL=pebble-tooling|gerolamo] [NETWORK=preprod|preview|mainnet]

NETWORK       ?= preprod
PROPOSAL      ?=
PROPOSAL_DIR  := $(if $(PROPOSAL),proposals/$(PROPOSAL),)
METADATA_FILE ?= $(if $(PROPOSAL_DIR),$(PROPOSAL_DIR)/metadata/proposal-metadata.json,)

export PROPOSAL_DIR

.PHONY: help check-prereqs generate-test-keys metadata register-stake register-receiving-stake delegate-always-abstain fetch-guardrails sign-metadata upload-ipfs hash \
        governance-action fund-proposal build-tx sign-tx submit-testnet submit-mainnet test-lifecycle report journal-entry ensure-aiken build-contract clean require-proposal

help: ## Show all available targets
	@grep -E '^[a-zA-Z_-]+:.*##' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*##"}; {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}'
	@echo ""
	@echo "Proposal-specific targets require PROPOSAL=pebble-tooling or PROPOSAL=gerolamo."

require-proposal:
	@if [ -z "$(PROPOSAL)" ]; then \
		echo "ERROR: PROPOSAL is required. Use PROPOSAL=pebble-tooling or PROPOSAL=gerolamo"; \
		exit 1; \
	fi
	@if [ ! -d "$(PROPOSAL_DIR)" ]; then \
		echo "ERROR: $(PROPOSAL_DIR) does not exist"; \
		exit 1; \
	fi

check-prereqs: ## Run prerequisite checks
	scripts/check-prereqs.sh

generate-test-keys: ## Generate a fresh wallet for preprod testnet
	NETWORK=$(NETWORK) scripts/generate-test-keys.sh

metadata: require-proposal ## Generate proposal metadata (requires PROPOSAL=)
	NETWORK=$(NETWORK) scripts/generate-metadata.sh

register-stake: ## Register the stake key on-chain (required once)
	NETWORK=$(NETWORK) scripts/register-stake.sh

register-receiving-stake: ## Register the receiving script stake credential on-chain (required once)
	NETWORK=$(NETWORK) scripts/register-receiving-stake.sh

delegate-always-abstain: ## Delegate treasury stake credential to always_abstain DRep
	NETWORK=$(NETWORK) scripts/delegate-always-abstain.sh

fetch-guardrails: ## Fetch the on-chain guardrails script
	NETWORK=$(NETWORK) scripts/fetch-guardrails.sh

sign-metadata: require-proposal ## Sign metadata with ed25519 (CIP-100 author witness; requires PROPOSAL=)
	scripts/sign-metadata.sh $(METADATA_FILE)

upload-ipfs: require-proposal ## Upload metadata to IPFS via Pinata (requires PROPOSAL=)
	scripts/upload-ipfs.sh $(METADATA_FILE)

hash: require-proposal ## Hash the proposal metadata JSON (requires PROPOSAL=)
	scripts/hash-metadata.sh $(METADATA_FILE)

governance-action: require-proposal hash ## Create the governance action (requires PROPOSAL=)
	NETWORK=$(NETWORK) scripts/create-governance-action.sh

fund-proposal: require-proposal ## Fund the proposal signing address from HW wallet (requires PROPOSAL=)
	NETWORK=$(NETWORK) scripts/fund-proposal.sh

build-tx: require-proposal governance-action ## Build the transaction (requires PROPOSAL=)
	NETWORK=$(NETWORK) scripts/build-tx.sh

sign-tx: require-proposal build-tx ## Sign the transaction (requires PROPOSAL=)
	NETWORK=$(NETWORK) scripts/sign-tx.sh

submit-testnet: NETWORK = preprod
submit-testnet: require-proposal sign-tx ## Submit transaction to preprod testnet (requires PROPOSAL=)
	NETWORK=$(NETWORK) scripts/submit-tx.sh

submit-mainnet: NETWORK = mainnet
submit-mainnet: require-proposal sign-tx ## Submit transaction to mainnet (with confirmation; requires PROPOSAL=)
	NETWORK=$(NETWORK) scripts/submit-tx.sh --confirm

ensure-aiken: ## Ensure the correct aiken compiler version is installed
	scripts/ensure-aiken.sh

build-contract: ## Build treasury contract with oversight members
	NETWORK=$(NETWORK) scripts/build-contract.sh

test-lifecycle: require-proposal ## Run the full test lifecycle (requires PROPOSAL=)
	NETWORK=$(NETWORK) METADATA_FILE=$(METADATA_FILE) scripts/test-lifecycle.sh

report: require-proposal ## Generate a status report (requires PROPOSAL=)
	scripts/generate-report.sh

journal-entry: ## Create a new journal entry
	scripts/journal-entry.sh

clean: ## Remove generated transaction and action files (across all proposals)
	rm -f proposals/*/*.action proposals/*/*.raw proposals/*/*.signed proposals/*/tx.* \
	      proposals/*/stake-reg.* proposals/*/receiving-stake-reg.* \
	      proposals/*/fund-proposal.* proposals/*/vote-deleg.* \
	      proposals/*/metadata/metadata-hash.txt
	rm -f keys/stake-reg.cert keys/receiving-stake-reg.cert keys/treasury-vote-deleg.cert
	rm -f scripts/guardrails.plutus
