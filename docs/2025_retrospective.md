# 2025 Retrospective

## Overview

In 2025, Harmonic Laboratories received its first Cardano Treasury funding through the Intersect Treasury Contracts for the **Gerolamo** project (EC-0014-25). The project aimed to create a Cardano data node that can run in the browser, implemented entirely in TypeScript.

Despite the funding being supposed to cover for 73 epoch, the deployment of the contract on-chain was effective as late as mid august, therefore covering a period from **August 12, 2025 to March 30, 2026**.

The total funding for the project was **₳578,571 ADA**; due to various miscommunications with the managing party during the proposal submission phase, the conversion rate was of about `0.7 ADA/USD`; the sharp drop in price of the asset we are being paid in since then, currently below `0.3 ADA/USD`, caused the valuation of the project to be significantly underpaid.

Harmonic Laboratories is extremely proud to say we keep delivering on our word despite the extremely harsh conditions.

## Roadmap Comparison

| Planned | Status | Notes |
| :--- | :---: | :--- |
| Ouroboros mini-protocols | ✅ | Handshake, ChainSync, BlockFetch working |
| Multi-era chain sync | ✅ | eras between Shelley and Conway supported |
| Block/header parsing | ✅ | Using `@harmoniclabs/cardano-ledger-ts` |
| Header validation | ✅ | VRF verification and era type checking |
| Transaction submission | ✅ | `/txsubmit` endpoint relaying to peers |
| Block validation | ✅ | Block application with ledger state updates |
| Rollback handling | ✅ | Chain rollback support implemented |
| full storage | ✅ | Volatile + immutable chunks, WAL concurrency |
| HTTP Block API | ✅ | `/block/{slot}` endpoint serving CBOR hex |
| P2P peer management | 🟡 | The node is already capable of handling multiple peers, dynamic peer selection is next |
| Mempool management | ✅ | A multi-thread aware mempool was implemented |
| Mithril integration | 🟡 | In progress - initial support is already integrated and we keep improving on it |
| Browser compatibility | 🟡 | In progress - various design decisions have been made to facilitate the integration of a browser-capable node |

## Key Achievements

### Block Validation & Application
Full block validation pipeline implemented, including header verification and block body application to the ledger state. The node now validates incoming blocks against protocol rules before applying them to the local chain state, ensuring data integrity.

### Header Validation with VRF Verification
Complete header validation logic with cryptographic VRF (Verifiable Random Function) verification. This ensures that block producers are correctly elected according to their stake and that headers are authentic.

### Rollback Handling
Robust chain rollback support allowing the node to handle chain reorganizations gracefully. When the network experiences a fork, Gerolamo can roll back to a common ancestor and re-sync along the winning chain.

### Storage Architecture
Dual-layer storage system with volatile and immutable chunks:
- **Volatile storage**: Recent blocks kept in fast-access storage for potential rollbacks
- **Immutable chunks**: Older, finalized blocks archived in compressed chunks
- **WAL concurrency**: Write-Ahead Logging for safe concurrent database access

### HTTP APIs
RESTful endpoints for external integrations:
- `/block/{slot|hash}` - Retrieve blocks by slot number or hash (CBOR hex)
- `/utxo/{txhash:index}` - Query specific UTxOs
- `/txsubmit` - Submit transactions to the network

### Multi-Era Support
Full parsing and validation support for all Cardano eras from Shelley through Conway, using `@harmoniclabs/cardano-ledger-ts` for type-safe block and transaction handling.

### Terminal UI & Logging
Interactive TUI displaying sync progress, peer connections, and node status. Structured JSONL logging with configurable levels (debug/info/warn/error) for production monitoring.

## Challenges & Learnings

- **Browser Compatibility**: Ensuring the node can run in browser environments required careful consideration of various, abstracted, storage backends and worker thread architecture.

- **Multi-era Support**: Supporting all Cardano eras from Shelley to Conway added significant complexity but is essential for a complete node implementation.

- **Milestone Pacing**: The aggressive milestone schedule required intense development sprints, particularly evident in the January 2026 commits preparing for closeout.

- **Funding Devaluation**: Due to the sharp drop in ADA price from ~`0.7 ADA/USD` at proposal submission to ~`0.3 ADA/USD` currently, the effective funding received is less than half of the originally anticipated USD value. Despite this, we continued to deliver on all commitments.

**Treasury Contract**: [EC-0014-25](https://treasury.sundae.fi/instances/9e65e4ed7d6fd86fc4827d2b45da6d2c601fb920e8bfd794b8ecc619/project/EC-0014-25)