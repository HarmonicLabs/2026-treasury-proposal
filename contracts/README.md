# Smart Contract Configuration

## Contracts

Uses [SundaeSwap treasury-contracts](https://github.com/SundaeSwap-finance/treasury-contracts) (audited by TxPipe and MLabs, deployed on mainnet).

- **treasury.ak** - Holds funds withdrawn from the Cardano treasury
- **vendor.ak** - Manages milestone-based vesting for Blink Labs as sole vendor

## Oversight Board

- **Pi Lanningham** (SundaeSwap)
- **Santiago Carmuega** (TxPipe)
- **Lucas Rosa** (Aiken, Midnight)

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

## Built-in Safeguards

- Funds cannot be delegated to SPOs (constitutional requirement)
- Auto-abstain DRep delegation enforced by contract
- All unclaimed funds sweep back to Cardano treasury after expiration
- Malformed datum protection on vendor contract

## Prerequisites

- aiken >= v1.1.17
- cardano-cli >= 10.4.0.0
- jq >= 1.5
- basenc (GNU coreutils) >= 9.1

## Setup

See `treasury-contracts/README.md` for full usage instructions.
