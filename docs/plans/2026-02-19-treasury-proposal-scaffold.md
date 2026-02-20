# Treasury Proposal Repository Scaffold - Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Build the complete infrastructure for Blink Labs' Cardano Treasury Withdrawal governance action proposal, from git init through submission-ready automation.

**Architecture:** Makefile-driven workflow with shell scripts for each operation (metadata generation, governance action creation, transaction building, testnet lifecycle testing, transparency journaling). SundaeSwap treasury-contracts as a git submodule for the escrow layer. Proposal narrative follows a PRAGMA template hybrid. Gap analysis docs are internal working documents summarized into the comprehensive CIP-108 metadata.

**Tech Stack:** bash, cardano-cli (Conway-era), jq, basenc, Make, Aiken (for contract reference), IPFS via Blockfrost

---

### Task 1: Git Init + Project Scaffolding

**Files:**
- Create: `.gitignore`
- Create: `LICENSE`
- Create: `README.md`
- Create: directories for `metadata/`, `gap-analysis/`, `scripts/`, `docs/`, `journal/`, `contracts/`, `keys/`

**Step 1: Initialize the git repository**

```bash
cd /home/wolf31o2/Repos/blink/treasury-proposal
git init
```

**Step 2: Create .gitignore**

```gitignore
# Key material - NEVER commit
keys/
*.skey
*.vkey

# Build artifacts
*.action
*.raw
*.signed
tx.*

# OS
.DS_Store
*.swp

# Editor
.vscode/
.idea/
```

**Step 3: Create LICENSE (Apache 2.0)**

Use standard Apache 2.0 license text with `Copyright 2026 Blink Labs Software`.

**Step 4: Create README.md**

```markdown
# Blink Labs Treasury Proposal: Dingo Development

Cardano Treasury Withdrawal governance action proposal to fund [Dingo](https://github.com/blinklabs-io/dingo) development.

## Overview

This repository contains the proposal narrative, gap analysis, CIP-108 metadata, smart contract configuration, and automation scripts for Blink Labs' treasury withdrawal request.

## Prerequisites

- `cardano-cli` (Conway-era, v8.x+)
- `cardano-node` (preview testnet and mainnet access)
- `jq` >= 1.5
- `basenc` (GNU coreutils) >= 9.1
- `make`

## Quick Start

```bash
make help          # Show all available targets
make metadata      # Generate CIP-108 metadata
make hash          # Hash metadata with blake2b-256
```

## License

Apache 2.0
```

**Step 5: Create directory structure**

```bash
mkdir -p metadata gap-analysis scripts docs journal contracts keys
touch metadata/.gitkeep gap-analysis/.gitkeep scripts/.gitkeep journal/.gitkeep contracts/.gitkeep
```

**Step 6: Commit**

```bash
git add .
git commit -m "chore: initialize treasury proposal repository scaffold"
```

---

### Task 2: Makefile with All Targets

**Files:**
- Create: `Makefile`

**Step 1: Create Makefile with configuration variables**

The Makefile should define:
- `NETWORK` defaulting to `preview` (overridable: `make submit-testnet NETWORK=preprod`)
- `CARDANO_CLI` defaulting to `cardano-cli`
- Testnet magic values: preview=2, preprod=1
- Network flag logic: if `NETWORK=mainnet` use `--mainnet`, else `--testnet-magic $(MAGIC)`

**Step 2: Add all targets**

```makefile
.PHONY: help metadata hash governance-action build-tx sign-tx submit-testnet submit-mainnet test-lifecycle report journal-entry check-prereqs clean

# Configuration
NETWORK ?= preview
CARDANO_CLI ?= cardano-cli
METADATA_FILE := metadata/proposal-metadata.json
ACTION_FILE := treasury-withdrawal.action
TX_RAW := tx.raw
TX_SIGNED := tx.signed

PREVIEW_MAGIC := 2
PREPROD_MAGIC := 1

ifeq ($(NETWORK),mainnet)
  NETWORK_FLAG := --mainnet
else ifeq ($(NETWORK),preprod)
  NETWORK_FLAG := --testnet-magic $(PREPROD_MAGIC)
else
  NETWORK_FLAG := --testnet-magic $(PREVIEW_MAGIC)
endif

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

check-prereqs: ## Verify required tools are installed
	@scripts/check-prereqs.sh

metadata: ## Generate CIP-108 metadata JSON from proposal docs
	@scripts/generate-metadata.sh

hash: ## Hash metadata with blake2b-256
	@scripts/hash-metadata.sh $(METADATA_FILE)

governance-action: hash ## Create the treasury withdrawal governance action
	@scripts/create-governance-action.sh $(NETWORK_FLAG)

build-tx: governance-action ## Build the submission transaction
	@scripts/build-tx.sh $(NETWORK_FLAG)

sign-tx: build-tx ## Sign the transaction
	@scripts/sign-tx.sh $(NETWORK_FLAG)

submit-testnet: NETWORK=preview
submit-testnet: sign-tx ## Submit to preview testnet
	@scripts/submit-tx.sh $(NETWORK_FLAG)

submit-mainnet: NETWORK=mainnet
submit-mainnet: sign-tx ## Submit to mainnet (requires confirmation)
	@scripts/submit-tx.sh $(NETWORK_FLAG) --confirm

test-lifecycle: ## Run automated testnet governance action lifecycle test
	@scripts/test-lifecycle.sh

report: ## Generate progress report
	@scripts/generate-report.sh

journal-entry: ## Add a transparency journal entry
	@scripts/journal-entry.sh

clean: ## Remove build artifacts
	rm -f $(ACTION_FILE) $(TX_RAW) $(TX_SIGNED)
```

**Step 3: Commit**

```bash
git add Makefile
git commit -m "build: add Makefile with all governance action targets"
```

---

### Task 3: Prerequisite Check Script

**Files:**
- Create: `scripts/check-prereqs.sh`

**Step 1: Write the script**

Check for: `cardano-cli` (and verify Conway support), `jq`, `basenc`, `make`. Print versions. Exit non-zero if any missing. Verify `cardano-cli` supports `conway governance action create-treasury-withdrawal`.

**Step 2: Make executable and commit**

```bash
chmod +x scripts/check-prereqs.sh
git add scripts/check-prereqs.sh
git commit -m "build: add prerequisite check script"
```

---

### Task 4: Metadata Generation Scripts

**Files:**
- Create: `scripts/generate-metadata.sh`
- Create: `scripts/hash-metadata.sh`

**Step 1: Write generate-metadata.sh**

This script assembles the CIP-108 JSON from the proposal docs. For now, create a template-based approach that reads from `docs/proposal.md` (or a structured source) and produces `metadata/proposal-metadata.json` with the full CIP-108 `@context`, `hashAlgorithm`, and `body` fields (title, abstract, motivation, rationale, references).

The metadata is **comprehensive and self-contained** - the entire proposal content goes into the JSON fields.

**Step 2: Write hash-metadata.sh**

```bash
#!/usr/bin/env bash
set -euo pipefail

METADATA_FILE="${1:-metadata/proposal-metadata.json}"

if [ ! -f "$METADATA_FILE" ]; then
    echo "Error: Metadata file not found: $METADATA_FILE" >&2
    exit 1
fi

HASH=$(cardano-cli hash anchor-data --file-text "$METADATA_FILE")
echo "Metadata hash (blake2b-256): $HASH"
echo "$HASH" > metadata/metadata-hash.txt
echo "Hash written to metadata/metadata-hash.txt"
```

**Step 3: Make executable and commit**

```bash
chmod +x scripts/generate-metadata.sh scripts/hash-metadata.sh
git add scripts/
git commit -m "build: add metadata generation and hashing scripts"
```

---

### Task 5: Governance Action Creation Scripts

**Files:**
- Create: `scripts/create-governance-action.sh`
- Create: `scripts/build-tx.sh`
- Create: `scripts/sign-tx.sh`
- Create: `scripts/submit-tx.sh`

**Step 1: Write create-governance-action.sh**

Reads configuration from environment or a `config.env` file:
- `GOVERNANCE_ACTION_DEPOSIT` (default: 100000000000 = 100k ADA)
- `DEPOSIT_RETURN_STAKE_VKEY` (path to key file)
- `ANCHOR_URL` (IPFS URL of metadata)
- `RECEIVING_STAKE_VKEY` (path to key file)
- `TRANSFER_AMOUNT` (lovelace)

Sources `config.env` if it exists. Reads hash from `metadata/metadata-hash.txt`. Runs `cardano-cli conway governance action create-treasury-withdrawal` with all parameters. Network flag passed as argument.

**Step 2: Write build-tx.sh**

Queries for available UTxOs, builds the transaction with `--proposal-file`, outputs `tx.raw`.

**Step 3: Write sign-tx.sh**

Signs `tx.raw` with the payment signing key, outputs `tx.signed`.

**Step 4: Write submit-tx.sh**

Submits `tx.signed`. If `--confirm` flag is passed (mainnet), prompt for confirmation before submitting. Print the transaction hash on success.

**Step 5: Create config.env.example**

```bash
# Treasury Proposal Configuration
# Copy to config.env and fill in values. NEVER commit config.env.

GOVERNANCE_ACTION_DEPOSIT=100000000000
DEPOSIT_RETURN_STAKE_VKEY=keys/deposit-return-stake.vkey
ANCHOR_URL=
RECEIVING_STAKE_VKEY=keys/receiving-stake.vkey
TRANSFER_AMOUNT=
PAYMENT_SKEY=keys/payment.skey
PAYMENT_ADDRESS=
CARDANO_NODE_SOCKET_PATH=
```

Add `config.env` to `.gitignore`.

**Step 6: Make all executable and commit**

```bash
chmod +x scripts/create-governance-action.sh scripts/build-tx.sh scripts/sign-tx.sh scripts/submit-tx.sh
git add scripts/ config.env.example .gitignore
git commit -m "build: add governance action creation, signing, and submission scripts"
```

---

### Task 6: Testnet Lifecycle Automation

**Files:**
- Create: `scripts/test-lifecycle.sh`

**Step 1: Write the lifecycle test script**

This is an automated test that exercises the full governance action lifecycle on preview network:
1. Verify we're on testnet (refuse to run on mainnet)
2. Generate metadata and hash it
3. Create the governance action
4. Build, sign, and submit the transaction
5. Wait for transaction confirmation
6. Query the governance state to verify the action appears
7. Print the governance action ID
8. Report success/failure

The script should be idempotent and safe to re-run. It should use test-specific configuration (test keys, test amounts).

**Step 2: Make executable and commit**

```bash
chmod +x scripts/test-lifecycle.sh
git add scripts/test-lifecycle.sh
git commit -m "test: add automated testnet governance action lifecycle test"
```

---

### Task 7: Transparency Journal Structure

**Files:**
- Create: `journal/README.md`
- Create: `scripts/journal-entry.sh`
- Create: `journal/.gitkeep` (remove, replaced by README)

**Step 1: Create journal README**

```markdown
# Treasury Transaction Journal

Public transparency journal tracking all transactions related to this treasury proposal.
Each entry records a transaction with its hash, purpose, amount, and on-chain metadata reference.

## Entry Format

Each entry is a dated markdown file following SundaeSwap's metadata standard:

- `YYYY-MM-DD-description.md`

## Fields

- **Date**: Transaction date
- **Transaction Hash**: On-chain transaction ID
- **Action**: What was done (disbursement, milestone claim, sweep, etc.)
- **Amount**: ADA amount involved
- **Signers**: Who signed the transaction
- **Justification**: Why this transaction was made
- **Metadata Hash**: On-chain metadata reference
```

**Step 2: Write journal-entry.sh**

Interactive script that prompts for: date, tx hash, action type, amount, signers, justification. Creates a formatted markdown file in `journal/`. Optionally creates on-chain metadata per the SundaeSwap standard.

**Step 3: Commit**

```bash
chmod +x scripts/journal-entry.sh
git add journal/ scripts/journal-entry.sh
git commit -m "docs: add transparency journal structure and entry script"
```

---

### Task 8: SundaeSwap Contract Configuration

**Files:**
- Create: `contracts/README.md`
- Modify: `.gitmodules` (add submodule)

**Step 1: Add SundaeSwap treasury-contracts as a git submodule**

```bash
cd /home/wolf31o2/Repos/blink/treasury-proposal
git submodule add https://github.com/SundaeSwap-finance/treasury-contracts.git contracts/treasury-contracts
```

**Step 2: Create contracts/README.md**

```markdown
# Smart Contract Configuration

This directory contains the configuration for the SundaeSwap treasury contracts
used to manage funds from the treasury withdrawal.

## Contracts Used

- **treasury.ak** - Holds funds withdrawn from the Cardano treasury
- **vendor.ak** - Manages milestone-based vesting for Blink Labs as sole vendor

Both contracts are audited by TxPipe and MLabs.
Source: https://github.com/SundaeSwap-finance/treasury-contracts

## Configuration

The contracts are parameterized with:
- **Registry token**: One-shot NFT for cross-contract references
- **Treasury expiration**: End date after which funds sweep back to Cardano treasury
- **Vendor maximum payout date**: Latest date for milestone payouts
- **Permissions**: Oversight board signature requirements per action

## Permission Scheme

| Action | Required Signatures |
|--------|-------------------|
| Disburse | Blink Labs + any 1 oversight board member |
| Sweep Early | Blink Labs + any 1 oversight board member |
| Reorganize | Blink Labs only |
| Fund (setup vendor) | Oversight board majority |
| Pause milestone | Any 1 oversight board member |
| Resume milestone | Oversight board majority |
| Modify project | Blink Labs + oversight board majority |

## Setup

See the treasury-contracts submodule README for full setup instructions.
Requires: aiken >= v1.1.17, cardano-cli >= 10.4.0.0
```

**Step 3: Commit**

```bash
git add .gitmodules contracts/
git commit -m "build: add SundaeSwap treasury-contracts as submodule with config docs"
```

---

### Task 9: Gap Analysis - Dingo

**Files:**
- Create: `gap-analysis/dingo.md`

**Step 1: Read the Dingo CLAUDE.md for current state**

Read `../dingo/CLAUDE.md` to understand current capabilities.

**Step 2: Write the Dingo gap analysis**

Structure:
- **Current State**: What Dingo can do today (reference CLAUDE.md: block production, VRF/KES, Plutus validation, conformance tests 314/314, mempool, storage backends, event bus, etc.)
- **Gaps for Mainnet Block Production**: Full consensus completeness, epoch transitions, hard fork combinator, genesis bootstrap
- **Gaps for Dijkstra**: Protocol changes needed, estimated effort
- **Gaps for Leios**: Architecture changes, IOG collaboration status, estimated effort
- **Gaps for Operational Hardening**: Mainnet-scale storage (known risk), crash recovery, memory management, long-running stability
- **Gaps for Feature Parity**: Missing N2C mini-protocols, LocalStateQuery, UTxO HD, Mithril, P2P
- **Gaps for Ecosystem Integration**: SPO tooling, db-sync compat, API surface
- **Effort Estimates**: Per-gap area, in engineer-months
- **Dependencies**: gOuroboros changes needed, Plutigo changes needed

This is an internal working document. Be honest and specific about gaps. Reference specific code paths and PRs where relevant.

**Step 3: Commit**

```bash
git add gap-analysis/dingo.md
git commit -m "docs: add Dingo gap analysis for treasury proposal"
```

---

### Task 10: Gap Analysis - gOuroboros

**Files:**
- Create: `gap-analysis/gouroboros.md`

**Step 1: Read the gOuroboros CLAUDE.md for current state**

Read `../gouroboros/CLAUDE.md` to understand current capabilities.

**Step 2: Write the gOuroboros gap analysis**

Structure:
- **Current State**: 2200+ tests, 314/314 ledger rules, full era support Byron through Conway, VRF/KES crypto, consensus primitives, CBOR handling
- **Gaps Required by Dingo**: What Dingo needs from gOuroboros that's missing or incomplete
- **Gaps for Dijkstra**: New protocol parameters, potential new mini-protocols, ledger rule changes
- **Gaps for Leios**: New mini-protocols for input-endorsement, transaction parallelism
- **Performance Gaps**: Any performance issues at mainnet scale
- **Effort Estimates**: In engineer-months, Dingo-enabling work only

**Step 3: Commit**

```bash
git add gap-analysis/gouroboros.md
git commit -m "docs: add gOuroboros gap analysis for treasury proposal"
```

---

### Task 11: Gap Analysis - Plutigo

**Files:**
- Create: `gap-analysis/plutigo.md`

**Step 1: Read Plutigo's current state**

Check `../plutigo/` for README, CLAUDE.md, or go.mod to understand current capabilities.

**Step 2: Write the Plutigo gap analysis**

Structure:
- **Current State**: UPLC evaluation, V1/V2/V3 support, pass rate
- **Gaps for Correctness**: V4/Dijkstra Plutus changes, new builtins, cost model updates
- **Gaps for Performance**: Mainnet-scale transaction validation speed, memory usage during evaluation
- **Effort Estimates**: In engineer-months

**Step 3: Commit**

```bash
git add gap-analysis/plutigo.md
git commit -m "docs: add Plutigo gap analysis for treasury proposal"
```

---

### Task 12: Gap Analysis - Ecosystem (Summary)

**Files:**
- Create: `gap-analysis/ecosystem.md`

**Step 1: Write ecosystem gap summary**

Brief document covering the non-core ecosystem projects that matter for SPO adoption:
- **Bursa**: What SPOs/developers would need
- **Adder**: Indexing story for Dingo
- **cardano-node-api**: N2C API surface parity
- **nview**: Monitoring for Dingo operators

This is framed as "ecosystem value-add" not core deliverables. Brief assessment per project, no deep analysis.

**Step 2: Commit**

```bash
git add gap-analysis/ecosystem.md
git commit -m "docs: add ecosystem gap analysis summary"
```

---

### Task 13: Proposal Narrative Draft

**Files:**
- Create: `docs/proposal.md`

**Step 1: Write the proposal following the hybrid PRAGMA/custom structure**

Sections (from CLAUDE.md):

1. **Abstract** - One paragraph: what the proposal is, how it benefits Cardano
2. **Motivation: Who We Are** - Blink Labs team, shipped products (gOuroboros, Adder, Dingo, Snek, nview, TxSubmit, Docker infrastructure), key personnel, Catalyst Fund 12 history, PRAGMA membership (but no Amaru funds received)
3. **Motivation: Why Dingo** - Node diversity = resilience, Go ecosystem accessibility, scalability through Leios, ecosystem sustainability through open source. Frame what the ecosystem LOSES without funding (data node only, no block production, no SPO story)
4. **Rationale: Executive Summary of Costs** - 4 FTE x 12 months at market rate, ~$500k security audit, contingency buffer (~40%), total ADA amount (placeholder until finalized). Table format per PRAGMA template
5. **Rationale: Administration of the Budget** - SundaeSwap treasury+vendor contracts, Blink Labs as single vendor, oversight board (PRAGMA-adjacent independent), permission scheme, auto-abstain delegation, failsafe sweep. Reference Amaru treasury repo as precedent
6. **Rationale: Reporting** - Monthly lightweight updates, quarterly detailed reports with financials, public GitHub journal per SundaeSwap metadata standard, proof-of-work demos
7. **Rationale: Constitutionality Checklist** - Per-article self-assessment following PRAGMA mnemos template format. Include the fallback NCL clause as optional language
8. **Scope of Work** - Organized by quarter with specific deliverables:
   - Q1: Consensus completeness, operational hardening kickoff
   - Q2: Dijkstra hard fork readiness, Plutigo V4
   - Q3: Leios prototype, mainnet-scale testing, security audit start
   - Q4: Mainnet readiness, audit completion, ecosystem integration
9. **Conclusion** - Long-term value, risk acknowledgment, what success looks like

Use `$PLACEHOLDER` for all dollar/ADA amounts that haven't been finalized.

**Step 2: Commit**

```bash
git add docs/proposal.md
git commit -m "docs: add treasury proposal narrative draft"
```

---

### Task 14: CIP-108 Metadata JSON Template

**Files:**
- Create: `metadata/proposal-metadata.json`

**Step 1: Create the CIP-108 JSON**

Build the full JSON structure with `@context`, `hashAlgorithm`, and `body` fields. The `body` fields (title, abstract, motivation, rationale) should be populated from `docs/proposal.md` content. For now, use the draft content with `$PLACEHOLDER` markers for amounts.

The `references` array should include:
- GitHub repo URL
- Dingo GitHub URL
- gOuroboros GitHub URL
- PRAGMA Maintainer Committee Framework IPFS link
- SundaeSwap treasury-contracts GitHub URL
- Audit reports (when available)

**Step 2: Commit**

```bash
git add metadata/proposal-metadata.json
git commit -m "docs: add CIP-108 proposal metadata JSON template"
```

---

### Task 15: Report Generation Script

**Files:**
- Create: `scripts/generate-report.sh`
- Create: `docs/reports/` directory
- Create: `docs/reports/TEMPLATE.md`

**Step 1: Create report template**

```markdown
# Progress Report - [Month Year]

**Period:** [Start Date] - [End Date]
**Report Type:** [Monthly/Quarterly]

## Summary

[Brief overview of progress this period]

## Milestones

| Milestone | Status | Notes |
|-----------|--------|-------|
| Q1: Consensus completeness | [On track/At risk/Complete] | |
| Q2: Dijkstra readiness | [Not started/On track/At risk/Complete] | |
| Q3: Leios prototype | [Not started/On track/At risk/Complete] | |
| Q4: Mainnet readiness | [Not started/On track/At risk/Complete] | |

## Deliverables This Period

- [List of specific deliverables completed]

## Financial Summary (Quarterly Only)

| Category | Budgeted | Spent | Remaining |
|----------|----------|-------|-----------|
| Engineering | | | |
| Security Audit | | | |
| Infrastructure | | | |
| Contingency | | | |

## Upcoming Work

- [List of planned work for next period]

## Risks & Issues

- [Any new risks or issues identified]
```

**Step 2: Write generate-report.sh**

Script that copies the template, fills in the date, and opens it for editing. For quarterly reports, includes the financial summary section.

**Step 3: Commit**

```bash
chmod +x scripts/generate-report.sh
git add docs/reports/ scripts/generate-report.sh
git commit -m "docs: add progress report template and generation script"
```

---

### Task 16: Final Assembly and Verification

**Files:**
- Modify: `README.md` (update with complete information)
- Modify: `.gitignore` (verify complete)

**Step 1: Update README.md with full project documentation**

Add sections for: project structure overview, how to configure, how to test on preview, links to reference repos, team info, license.

**Step 2: Verify .gitignore covers all sensitive files**

Ensure: `keys/`, `*.skey`, `*.vkey`, `config.env`, build artifacts, OS files.

**Step 3: Run make check-prereqs to verify the tooling works**

```bash
make check-prereqs
```

**Step 4: Run make help to verify all targets display**

```bash
make help
```

**Step 5: Final commit**

```bash
git add -A
git commit -m "chore: finalize repository scaffold and documentation"
```

---

## Task Dependency Graph

```
Task 1 (scaffold) ─┬─> Task 2 (Makefile) ──> Task 3 (prereqs) ──> Task 4 (metadata scripts)
                    │                                                       │
                    │                                                       v
                    │                                               Task 5 (governance scripts)
                    │                                                       │
                    │                                                       v
                    │                                               Task 6 (testnet lifecycle)
                    │
                    ├─> Task 7 (journal) ──────────────────────────────────────┐
                    │                                                          │
                    ├─> Task 8 (contracts submodule)                           │
                    │                                                          │
                    ├─> Task 9 (gap: dingo) ───┐                               │
                    ├─> Task 10 (gap: gouroboros)├──> Task 12 (gap: ecosystem)  │
                    ├─> Task 11 (gap: plutigo) ─┘           │                  │
                    │                                       v                  │
                    │                               Task 13 (proposal draft)   │
                    │                                       │                  │
                    │                                       v                  │
                    │                               Task 14 (CIP-108 JSON) ────┤
                    │                                                          │
                    ├─> Task 15 (reports) ─────────────────────────────────────┤
                    │                                                          │
                    └──────────────────────────────────────────────────────────> Task 16 (final)
```

**Parallelizable groups:**
- Tasks 2, 7, 8, 9, 10, 11, 15 can all start after Task 1
- Tasks 3-6 are sequential (Makefile chain)
- Tasks 9-11 (gap analyses) are independent and parallelizable
- Task 13 depends on gap analyses completing
- Task 14 depends on Task 13
- Task 16 depends on everything
