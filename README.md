# Harmonic Labs 2026 Treasury Proposal

Cardano Treasury Withdrawal governance action proposal to fund HLabs open source development, 
including: [Gerolamo](https://github.com/HarmonicLabs/gerolamo), [Pebble](https://github.com/HarmonicLabs/pebble) as well as 2026 Hard Fork(s) maintainance.

[Initial draft of the proposal](https://hackmd.io/@HarmonicLabs/HLabs2026Budget)

## Overview

This repository contains everything needed to create, test, and submit a Cardano Treasury Withdrawal governance action for Harmonic Labs to fund open source development, including Gerolamo, Pebble, and 2026 Hard Fork(s) maintenance.

## Prerequisites

- `cardano-cli` (Conway-era, v8.x+)
- `cardano-node` (preprod testnet and mainnet access)
- `cardano-hw-cli` (for hardware wallet signing)
- `jq` >= 1.5
- `basenc` (GNU coreutils) >= 9.1
- `make`

## Quick Start

if you are using an hardware wallet, you can generate the necessary files as shown in the [`cardano-hw-cli` docs](https://github.com/vacuumlabs/cardano-hw-cli/blob/develop/docs/transaction-example.md#verification-payment-key-and-hardware-wallet-signing-file)

```bash
make help              # Show all available targets
make check-prereqs     # Verify tools are installed
make metadata          # Generate CIP-108 metadata
make hash              # Hash metadata with blake2b-256
make submit-testnet    # Full testnet submission workflow
make test-lifecycle    # Automated testnet lifecycle test
```

## step-by-step Proposal submission

1. `make build-contract`
2. Submit publish txs using the contract CLI
3. Update `TREASURY_SCRIPT_REF_UTXO` in config.env with the UTxO from step 2
4. `make register-stake`
5. `make register-receiving-stake`
6. `make fetch-guardrails`
7. `make metadata`
8. `make hash`
9. `make sign-metadata && make upload-ipfs` — then update `ANCHOR_URL` in config.env
10. `make fund-proposal`
11. `make submit-testnet`


## Repository Structure

```
metadata/          CIP-108 proposal metadata JSON (self-contained)
docs/              Proposal narrative and translations (es, ja)
docs/reports/      Progress report templates
scripts/           Makefile-driven automation scripts
journal/           On-chain transaction transparency journal
contracts/         SundaeSwap treasury contract configuration
gap-analysis/      Gap analysis documents
```

## Proposal

The full proposal narrative is in [docs/proposal.md](docs/proposal.md). Translations are available in [Spanish](docs/proposal.es.md) and [Japanese](docs/proposal.ja.md). The CIP-108 metadata JSON at [metadata/proposal-metadata.json](metadata/proposal-metadata.json) contains the complete proposal in the format required for on-chain submission.

## Smart Contracts

Uses audited [SundaeSwap treasury-contracts](https://github.com/SundaeSwap-finance/treasury-contracts) (treasury.ak + vendor.ak) with an independent oversight board for fund management. See [contracts/README.md](contracts/README.md) for the permission scheme.

## Testnet Workflow

```bash
# 1. Configure
cp config.env.example config.env
# Edit config.env with your keys and addresses

# 2. Test on preprod
make test-lifecycle

# 3. Or step by step
make metadata
make hash
make governance-action NETWORK=preprod
make build-tx NETWORK=preprod
make sign-tx NETWORK=preprod
make submit-testnet
```

## Reporting

Monthly lightweight updates and quarterly detailed reports are generated via:

```bash
make report              # Monthly report
scripts/generate-report.sh --quarterly  # Quarterly report with financials
```

## License

Apache 2.0
