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
```

## Repository Structure

```
metadata/          CIP-108 proposal metadata JSON
gap-analysis/      Internal per-project gap analysis
scripts/           Shell scripts called by Makefile
docs/              Proposal narrative, budget, milestones
journal/           On-chain transaction transparency journal
contracts/         SundaeSwap treasury contract configuration
keys/              Key files (gitignored)
```

## Smart Contracts

Uses audited [SundaeSwap treasury-contracts](https://github.com/SundaeSwap-finance/treasury-contracts) (treasury.ak + vendor.ak) with an independent oversight board for fund management.

## License

Apache 2.0
