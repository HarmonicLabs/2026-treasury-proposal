# Harmonic Labs 2026 Treasury Proposals

Two independent Cardano Treasury Withdrawal governance actions to fund HLabs open source development:

- **Pebble + Tooling Maintenance** — 5 FTE, 5,175,000 ADA — see [proposals/pebble-tooling/docs/proposal.md](proposals/pebble-tooling/docs/proposal.md).
- **Gerolamo Light Node** — 5 FTE, 5,175,000 ADA — see [proposals/gerolamo/docs/proposal.md](proposals/gerolamo/docs/proposal.md).

Each proposal has its own metadata, anchor, and on-chain governance action. They share the same SundaeSwap treasury contract, oversight board (Santiago Carmuega, Lucas Rosa, Chris Gianelloni), and signing infrastructure.

## Prerequisites

- `cardano-cli` (Conway-era, v8.x+)
- `cardano-node` (preprod testnet and mainnet access)
- `cardano-hw-cli` (for hardware wallet signing)
- `jq` >= 1.5
- `basenc` (GNU coreutils) >= 9.1
- `make`

## Repository Structure

```
Makefile, scripts/, contracts/, keys/   shared infrastructure
config.shared.env                       shared values (PINATA_JWT, oversight,
                                        HW signing files, contract dates, etc.)
proposals/
  pebble-tooling/
    config.env                          per-proposal: TRANSFER_AMOUNT, ANCHOR_URL
    docs/proposal.md                    proposal narrative
    metadata/proposal-metadata.json     CIP-108 metadata (generated)
    mainnet-logs/                       on-chain submission logs
    tx.{raw,signed}, *.action, ...      generated tx artifacts (gitignored)
  gerolamo/
    (same layout)
  _archive-2026-combined/               artifacts from the prior combined proposal
```

## Quick Start

Every proposal-specific target requires `PROPOSAL=pebble-tooling` or `PROPOSAL=gerolamo`.

```bash
make help                                          # Show all available targets
make check-prereqs                                 # Verify tools are installed
make metadata          PROPOSAL=pebble-tooling     # Generate CIP-108 metadata
make hash              PROPOSAL=pebble-tooling     # Hash metadata with blake2b-256
make submit-testnet    PROPOSAL=pebble-tooling     # Full preprod submission workflow
make test-lifecycle    PROPOSAL=pebble-tooling     # Automated preprod lifecycle test
```

Targets without a proposal scope (run once per network):

```bash
make check-prereqs
make build-contract
make register-stake
make register-receiving-stake
make delegate-always-abstain
make fetch-guardrails
```

## Step-by-step Proposal Submission

For each proposal (`PROPOSAL=pebble-tooling` or `PROPOSAL=gerolamo`):

1. `make build-contract` *(once)*
2. Submit publish txs using the contract CLI *(once)*
3. Update `TREASURY_SCRIPT_REF_UTXO` in `config.shared.env` with the UTxO from step 2 *(once)*
4. `make register-stake` *(once)*
5. `make register-receiving-stake` *(once)*
6. `make fetch-guardrails` *(once)*
7. `make metadata        PROPOSAL=<name>`
8. `make hash            PROPOSAL=<name>`
9. `make sign-metadata   PROPOSAL=<name> && make upload-ipfs PROPOSAL=<name>` — then update `ANCHOR_URL` in `proposals/<name>/config.env`
10. `make fund-proposal  PROPOSAL=<name>`
11. `make submit-testnet PROPOSAL=<name>` *(or `make submit-mainnet PROPOSAL=<name>`)*

## Configuration

```bash
cp config.shared.env.example config.shared.env
# Edit config.shared.env with your keys, PINATA_JWT, node socket, etc.

# Per-proposal config files already exist at:
#   proposals/pebble-tooling/config.env
#   proposals/gerolamo/config.env
# Each holds only TRANSFER_AMOUNT and ANCHOR_URL — fill in ANCHOR_URL after IPFS upload.
```

## Smart Contracts

Both proposals withdraw to the same audited [SundaeSwap treasury-contracts](https://github.com/SundaeSwap-finance/treasury-contracts) (`treasury.ak` + `vendor.ak`) with the same independent oversight board. See [contracts/README.md](contracts/README.md) for the permission scheme.

## Reporting

Monthly lightweight updates and quarterly detailed reports are generated per proposal:

```bash
make report PROPOSAL=pebble-tooling                                # Monthly
PROPOSAL_DIR=proposals/pebble-tooling scripts/generate-report.sh --quarterly  # Quarterly
```

## License

Apache 2.0
