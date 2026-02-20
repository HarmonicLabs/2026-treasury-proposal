# Blink Labs Treasury Proposal: Dingo Development

Cardano Treasury Withdrawal governance action proposal to fund [Dingo](https://github.com/blinklabs-io/dingo) development.

## Overview

This repository contains everything needed to create, test, and submit a Cardano Treasury Withdrawal governance action for Blink Labs to fund 12 months of Dingo node development, including Dijkstra hard fork readiness, Leios protocol implementation, and mainnet production readiness.

## Prerequisites

- `cardano-cli` (Conway-era, v8.x+)
- `cardano-node` (preview testnet and mainnet access)
- `jq` >= 1.5
- `basenc` (GNU coreutils) >= 9.1
- `make`

## Quick Start

```bash
make help              # Show all available targets
make check-prereqs     # Verify tools are installed
make metadata          # Generate CIP-108 metadata
make hash              # Hash metadata with blake2b-256
make submit-testnet    # Full testnet submission workflow
make test-lifecycle    # Automated testnet lifecycle test
```

## Repository Structure

```
metadata/          CIP-108 proposal metadata JSON (self-contained)
docs/              Proposal narrative, budget, milestones
docs/reports/      Progress report templates
scripts/           Makefile-driven automation scripts
journal/           On-chain transaction transparency journal
contracts/         SundaeSwap treasury contract configuration
```

## Proposal

The full proposal narrative is in [docs/proposal.md](docs/proposal.md). The CIP-108 metadata JSON at [metadata/proposal-metadata.json](metadata/proposal-metadata.json) contains the complete proposal in the format required for on-chain submission.

## Smart Contracts

Uses audited [SundaeSwap treasury-contracts](https://github.com/SundaeSwap-finance/treasury-contracts) (treasury.ak + vendor.ak) with an independent oversight board for fund management. See [contracts/README.md](contracts/README.md) for the permission scheme.

## Testnet Workflow

```bash
# 1. Configure
cp config.env.example config.env
# Edit config.env with your keys and addresses

# 2. Test on preview
make test-lifecycle

# 3. Or step by step
make metadata
make hash
make governance-action NETWORK=preview
make build-tx NETWORK=preview
make sign-tx NETWORK=preview
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
