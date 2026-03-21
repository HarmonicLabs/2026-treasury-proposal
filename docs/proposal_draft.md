# Harmonic Laboratories 2026 Treasury Budget 

> [!NOTE]
> The following document is a proposal to sustain the Harmonic Laboratories (HLabs) efforts in maintaining and evolving Cardano open source infrastructure.
>
> It is meant as a starting point for discussing Cardano treasury withdrawals.
>
> As such, we invite anyone interested to comment on the following document, and share feedback with us.

## Vision

Harmonic Laboratories (HLabs for short) is an R&D firm born and focused solely on the Cardano ecosystem.

Harmonic Laboratories supports and maintains a considerable portion of the TypeScript tooling for the Cardano ecosystem, which the majority of Cardano developers use, either directly, or indirectly via other libraries that depend on code written and maintained by HLabs.

The mission of HLabs is for true decentralization to become the baseline of applicationn development, not only a nice-to-have feature.

We do so by developing and maintaining core infrastructure and tooling.

## Executive Summary

Before we dive further into the details and cost breakdown, here is a high-level view of the ask, some assumptions we are making, and the general direction of this budget.

#### 2025 Retrospective

We provide a [full retrospective of our 2025 roadmap](#2025-Retrospective) in annex of this document. This includes a head-to-head comparison with the roadmap items presented last year with their corresponding deliveries. 

#### Duration & Milestones

This proposal spans over **12 months**, throughout which there will be several deliveries and demos. Amongst the key deliveries, we note:

- an upcoming hard fork maintenance;
- a relay-capable node (Gerolamo);
- a fully mature, imperative and efficient, programming language for smart contracts (pebble).

### Ecosystem benefits

Gerolamo, Pebble, and ongoing tooling maintenance each serve distinct stakeholders while collectively strengthening Cardano's infrastructure, developer experience, and long-term sustainability.

#### Who will benefit from Gerolamo?

##### TL;DR

- SPOs for relay nodes
- dApps for trust-minimized applications
- wallets for daedalus-like security

##### SPOs

Stake Pool Operators can use Gerolamo as an additional relay node alongside their existing infrastructure. Block production continues on their current setup, while Gerolamo relays add diversity and resilience to their pool.

A diverse node implementation landscape strengthens the network's resilience. By providing an alternative codebase for relays, Gerolamo reduces the risk of network-wide issues stemming from bugs in a single implementation; a critical factor for long-term network health and decentralization.

##### dApps

Decentralized applications benefit immensely from trust-minimized access to blockchain data. Currently, most dApps rely on centralized indexers or third-party APIs to query the chain state, introducing points of failure and trust assumptions that undermine the decentralization ethos.

Gerolamo enables dApps to run their own lightweight nodes; even directly in the browser; providing direct, trustless access to the Cardano ledger.

This means dApps can verify UTxO states, validate transactions, and query chain data without relying on external services. The result is a more resilient, censorship-resistant application architecture that aligns with the core principles of decentralization.

##### Light wallets

Light wallets today must trust external servers to provide accurate chain data. This creates a security trade-off: users gain convenience but sacrifice the ability to independently verify their balances and transaction history.

With Gerolamo, wallet developers can integrate a lightweight node directly into their applications, offering users Daedalus-like security guarantees without the overhead of running a full node. Users can verify their own UTxOs, validate incoming transactions, and maintain full sovereignty over their funds, all while enjoying the user experience of a light wallet.

#### Who will benefit from Pebble?

##### TL;DR

Developers who seek an alternative to functional programming without sacrificing efficiency.

The language aims to be as similar as possible to TypeScript, which is a widely adopted language used in Web2, as well as similar to languages used in other, more mature ecosystems, such as Solidity on EVM chains.

##### Onboarding Web2 developers

One of Cardano's greatest challenges is the steep learning curve for smart contract development. Aiken, the most widely adopted smart contract language on Cardano, while a great improvement compared to haskell, still requires familiarity with functional programming paradigms, concepts unfamiliar to the vast majority of developers worldwide. This barrier significantly limits the pool of talent that can contribute to Cardano's dApp ecosystem.

Pebble bridges this gap by offering a syntax and development experience familiar to TypeScript and JavaScript developers, the largest programming communities in the world. By lowering the barrier to entry, Pebble opens Cardano development to millions of developers who would otherwise be deterred by the functional programming learning curve.

##### Efficient on-chain code

Despite its imperative syntax, Pebble compiles to highly optimized UPLC (Untyped Plutus Core). Developers don't have to choose between familiarity and efficiency: Pebble delivers both. The compiler performs aggressive optimizations to minimize execution costs, ensuring that contracts written in Pebble are competitive with hand-optimized Plutus code, making them a viable choice for production applications.

##### Professional development experience

Pebble's tooling, including a full Language Server Protocol (LSP) implementation, CLI with watch mode, and integrated debugging via sourcemaps, provides a development experience on par with mature ecosystems. Developers can enjoy auto-completion, inline error reporting, go-to-definition, and all the conveniences they expect from modern IDEs. This professional-grade tooling accelerates development cycles and reduces bugs, ultimately leading to higher-quality dApps on Cardano.

#### Who will benefit from the tooling maintenance?

##### TL;DR

The entire ecosystem can have the guarantee that there will always be up-to-date, easy to use, tools for them to use, without the fear of having to redesign entire applications because of missing support.

##### Ecosystem-wide stability

The TypeScript tooling maintained by HLabs underpins a significant portion of Cardano's developer ecosystem. Libraries like `cardano-ledger-ts`, `ouroboros-miniprotocols-ts`, and `uplc` are dependencies for numerous projects—both directly and transitively through other libraries. When a hard fork introduces protocol changes, these foundational libraries must be updated promptly, or downstream projects face breaking changes and potential security vulnerabilities.

By funding ongoing maintenance, the Treasury ensures that the TypeScript ecosystem remains synchronized with protocol upgrades. Developers can trust that their applications will continue to function across hard forks without emergency rewrites or extended downtime.

##### Reducing fragmentation risk

Without dedicated maintenance, critical libraries risk abandonment, a common fate in open-source ecosystems.

Abandoned dependencies force teams to either fork and maintain code themselves (duplicating effort across the ecosystem) or migrate to alternative solutions (fragmenting the developer community). Both outcomes are costly and destabilizing.

Sustained funding for HLabs tooling maintenance eliminates this risk, providing the ecosystem with a reliable foundation upon which developers can confidently build long-term projects.

### Cardano 2030 Alignment

This proposal directly supports the [Cardano 2030 Strategic Framework](https://product.cardano.intersectmbo.org/vision/strategy-2030/), contributing to core KPIs and strategic pillars as outlined below.

#### Alignment with Core KPIs

| KPI / Strategic Priority                   | 2030 Target / Goal             | HLabs Contribution                                                              |
| :----------------------------------------- | :----------------------------- | :------------------------------------------------------------------------------ |
| **Alternative full node clients**          | ≥2 spec-conformant             | Gerolamo directly contributes as a second spec-conformant client implementation |
| **Monthly Uptime**                         | 99.98%                         | Hard-fork maintenance ensures ecosystem stability across protocol upgrades      |
| **Developer migration pathways** (A.3)     | "More developers can onboard"  | Pebble provides EVM/TS developers a familiar syntax for Cardano smart contracts |

> **Note**: The first two rows are formal Cardano 2030 KPIs. The third row corresponds to Strategic Pillar A.3 (Developer Experience → Education & migration), which is an explicit 2030 priority but not yet a numeric KPI. TVL, monthly transactions, and MAU are ecosystem-level outcomes enabled by infrastructure investments like this proposal; we track adoption indicators (below) as leading metrics that contribute to these outcomes.

#### Alignment with Strategic Pillars

**Pillar 1: Infrastructure & Research Excellence**

- **I.2 Security & Resilience → Client Diversity**: Gerolamo is explicitly aligned with the 2030 goal of "supporting additional full-node and light-client implementations" to achieve "better decentralization" and "reduce single-client risk."

**Pillar 2: Adoption & Utility**

- **A.3 Developer Experience → Open-source incentives**: This proposal directly addresses the strategic priority to "incentivize the maintenance of core Cardano SDKs, frameworks, and infrastructure in line with open-source best practices" for a "sustainable builder ecosystem."
- **A.3 Developer Experience → Education & migration**: Pebble addresses the goal to "provide materials for EVM/account-based devs moving to Cardano/UTxO" by offering familiar imperative syntax, enabling "more developers to onboard."

#### Measurable Adoption Indicators

To provide visibility into how this proposal contributes to ecosystem-level outcomes, we commit to tracking and reporting the following adoption metrics:

##### Gerolamo Adoption Targets

| Metric                           | 12-Month Target   | Measurement Method                     |
| :------------------------------- | :---------------- | :------------------------------------- |
| SPOs running Gerolamo as relay   | ≥10 pools         | Public registry + self-reporting       |
| Browser-based node integrations  | ≥3 wallets/dApps  | dApps/wallets integrations             |

##### Pebble Adoption Targets

| Metric                     | 12-Month Target         | Measurement Method                             |
| :------------------------- | :---------------------- | :--------------------------------------------- |
| Developer onboarding       | ≥20 developers          | npm downloads, GitHub stars, Discord members   |
| Documentation completeness | 100% coverage           | All language features documented with examples |
| Tutorial completion        | ≥3 e2e tutorials        | Published guides covering common patterns      |

## Budget Breakdown 

### Total Budget Ask

The total ask for 2026 is **`₳8,035,714`**, covering a USD budget of **`$2,250,000`** (or **`₳6,428,571`**) + 25% in refundable contingency (**`₳1,607,143`**).

This figure includes the costs estimated, as well as a refundable contingency, that will allow us to operate with a certain degree of independence from the volatility of the market. The contingency will be fully or partially refunded to the treasury in the event it is not used.

The full budget breakdown is given below.

For a fair valuation of the proposal, we will follow a similar process to what is used in the Amaru proposal, which we believe is setting a good standard in terms of Treasury budget proposals, and we will estimate the scopes of this proposal in _FTE_ (Full-Time Equivalent), which we will consider to equal a figure of `$225k` yearly rate.

We use a conversion rate of `0.35` ADA [`₳`] per USD [`$`].

### Complete View 

| Scope                                                     | Estimated (FTEs) | Project Total ($)  |
| :---                                                      | ---:             | ---:               |
| Gerolamo (TypeScript Cardano node)                        | 5                | `$1,125,000`       |
| Pebble (programming language + dApp development tools)    | 3.5              | `$785,500`         |
| Hard-fork maintenance                                     | 1.5              | `$337,500`         |
|                                                           |                  |                    |
| **Total**                                                 | **10 FTEs**      | `$2,250,000`       |

The estimated fixed cost includes:

#### Rationale

The total ask for the project is `10 FTEs`. 

FTEs are being valued at an annual rate of `$225k`.  

Furthermore, we are aware of our assumption/optimism bias (our forecast is subject to underestimating complexity, overlooking challenges, and undervaluing the time and cost required to deliver, as well as our biased expectation of market movements). We therefore add an extra 25% contingency buffer, learning by our past mistakes.

This leaves us with the following total: `(10 x $225k) x 1.25 = $2,812,500`

Finally, using a conversion rate of `0.35` ADA per USD, we formulate a budget ask of **`₳8,035,714`**. A [complete breakdown of this budget][detailed-scopes] is available in below.

> **NOTE** Is `0.35 ADA/USD` a fair conversion rate?
>
> Learning from our 2025 funding experience, we recognize the importance of accounting for market volatility when planning long-term deliveries. 
>
> At the time of writing, the ADA price is approximately `0.3 USD` per ADA. We propose a conversion rate of `0.35 ADA/USD`, which accounts for the current market while providing a reasonable buffer.
>
> Combined with the 25% refundable contingency, this approach aims to ensure safe and uninterrupted delivery of the projects without over-asking from the treasury.

## Budget Administration and Governance Oversight

### Smart Contract Escrow

Funds are held and released through the SundaeLabs treasury-contracts (https://github.com/SundaeSwap-finance/treasury-contracts), a proven framework with two validators:

treasury.ak: Holds all ADA withdrawn from the Cardano treasury. Everything gets locked here when the governance action is enacted.
vendor.ak: Manages milestone-based vesting for HLabs. Payment schedule, payout dates, release conditions.
Both contracts have been independently audited by TxPipe and MLabs and are in production use on mainnet.

#### Independent Oversight Board

An independent oversight board provides third-party governance:

Santiago Carmuega (TxPipe, Dolos)
Lucas Rosa (Aiken, Starstream, Midnight)
Chris Gianelloni (BlinkLabs, Dingo)

Board members don't have a stake in HLabs. They co-sign disbursements, review milestones, and can halt funding if we're not delivering.

#### Permission Scheme

The actions allowed by the escrow contract are as follows:

Disburse (periodic release): HLabs initiates + any 1 board member co-signs
Sweep early (return unused funds): HLabs + any 1 board member
Reorganize (adjust milestone schedule): HLabs only
Fund (initial vendor setup): Board majority
Pause milestone: Any 1 board member
Resume milestone: Board majority
Modify project: HLabs + board majority
Day-to-day operations need one board signature. Structural changes need the full board. And any single member can hit pause if something looks off.

#### Delegation Policy

The treasury contract enforces auto-abstain DRep delegation and no SPO delegation for all funds in escrow. Treasury funds don't influence governance votes or staking.

#### Failsafe Sweep

Funds left in the contract after expiration automatically sweep back to the Cardano treasury. Enforced at the contract level. Can't be overridden.

## Constitutionality checklist

In an effort to convince ourselves of the proposal's constitutionality, we thought relevant to include a checklist of the points we cover and for each, our interpretation of the Cardano Constitution. 

#### Purpose

- [x] This proposal is for work intended to enhance the security, decentralization and long-term sustainability of Cardano.

#### Article III.5: the process of on-chain governance

- [x] We have submitted this proposal in a standardized, legible format, which includes a URL and hash of all documented off-chain content. We believe our rationale to be detailed and sufficient. The proposal contains a title, abstract, reason for the proposal and relevant supporting materials.

#### Article IV.1: proposing budgets

- [x] This proposal accords with the provisions of this article as it is intended to cover the maintenance and future development of the Cardano Blockchain.

- [x] This proposal covers a 12-month (73 epochs) period as recommended by this provision of the Constitution.

#### Article IV.3: Net-Change Limit

- [x] Budgets needs not to be evaluated within the context of a Net-Change Limit, only withdrawals must. However, we recognize that the establishment of a new Net-Change Limit will likely be necessary in order to enact withdrawals pertaining to this budget. We will re-assess the situation in due time, and possibly split withdrawals into multiple ones should it be required.

#### Cardano 2030 Strategic Alignment

- [x] This proposal directly supports the Cardano 2030 Strategic Framework, contributing to the "Alternative full node clients" KPI (Pillar 1: Security & Resilience) and Developer Experience priorities (Pillar 2: Adoption & Utility).

- [x] Measurable adoption indicators have been defined to provide visibility into ecosystem-level KPI contributions (TVL, monthly transactions, MAU).

## Budget Detailed View

<!---------------------------------------------------------------------------------------------->
<!---------------------------------------------------------------------------------------------->
<!------------------------------------------ gerolamo ------------------------------------------>
<!---------------------------------------------------------------------------------------------->
<!---------------------------------------------------------------------------------------------->

### Gerolamo (Typescript cardano node)

[repo](https://github.com/HarmonicLabs/gerolamo)

| 🎯 Main Objective                   |
| ---                                 |
| trust-minimized data node for dApps |

Gerolamo is a TypeScript implementation of the Cardano node designed for:
- **Browser compatibility**: Serving as a base for nodes running in browsers
- **Extensibility**: Being the base for purpose-specific nodes (light nodes, UTxO-only nodes, chain indexers)

#### Full Ledger Rules Coverage

##### Goal

Implement complete ledger validation rules to enable Gerolamo to fully validate blocks and transactions according to the Cardano protocol specifications.

##### Key Results

- Full ledger state management using LMDB (or IndexedDB for browsers) for performance improvements.
- Consensus implementation (Praos) with chain selection and rollback handling
- Volatile DB for managing chain forks
- Block and transaction validation covering all eras

##### Estimated Effort

2.5 FTEs

#### Node APIs

##### Goal

Provide comprehensive APIs for dApp developers and infrastructure operators to interact with the Cardano network through Gerolamo.

##### Key Results

- UTxO RPC endpoints for efficient UTxO queries
- Local socket support for node-to-client protocols (cardano-db-sync, cardano-cli compatibility)
- Browser API for dApps to use

##### Estimated Effort

2 FTEs

#### Plutus Machine Improvements

##### Goal

Continuously improve the [plutus-machine](https://github.com/HarmonicLabs/plutus-machine) CEK interpreter for better performance and full conformance with the Plutus specification.

##### Key Results

- Performance optimizations for script evaluation
- Budget tracking and cost model accuracy improvements
- Sourcemap support for debugging

##### Estimated Effort

0.5 FTEs

### Gerolamo ━ Summary

- total resources estimated: `5 FTEs`

#### Production Readiness Criteria

Gerolamo will be considered production-ready for relay deployment when it meets the following objective criteria:

| Criterion              | Requirement                                                    | Verification Method     |
| :--------------------- | :------------------------------------------------------------- | :---------------------- |
| **Sync reliability**   | Successful sync from genesis to tip on mainnet                 | Continuous integration  |
| **Sync performance**   | Initial sync ≤48 hours on commodity hardware (4 CPU, 16GB RAM) | Benchmark suite         |
| **Peer connectivity**  | Stable connections with ≥15 peers for ≥24 hours                | Network validation      |
| **Block propagation**  | Block relay latency within 2x of Haskell node baseline         | Comparative benchmarks  |
| **Rollback handling**  | Successful recovery from rollbacks up to k=2160 blocks         | Adversarial scenarios   |

#### Value Proposition vs. Other Node Implementations

| Dimension            | Haskell Node               | Amaru                                    | Gerolamo                       | Gerolamo Benefit                                  |
| :------------------- | :------------------------- | :--------------------------------------- | :----------------------------- | :------------------------------------------------ |
| **Runtime**          | GHC runtime                | Native (Rust)                            | Bun/Node.js/Browser            | Runs anywhere JavaScript runs, including browsers |
| **Browser support**  | No                         | Limited support planned (WASM, EOY 2026) | Yes (IndexedDB + WebWorkers)   | Production-ready browser support sooner           |
| **Developer access** | Haskell expertise required | Rust expertise required                  | TypeScript/JavaScript          | Largest contributor pool (17M+ JS/TS developers)  |
| **Extensibility**    | Cardano-specific           | Rust crates ecosystem                    | npm ecosystem integration      | Seamless integration with web/dApp tooling        |
| **Use cases**        | Full block production      | Full block production                    | Relay, data node, browser node | Complementary; JS/TS native browser capability    |

> [!NOTE]
>  Gerolamo is designed as a **complementary implementation** for relay and data-node use cases, not a replacement for block-producing nodes yet. Block production so far remains on the Haskell node.
> 
> Getting to a point where the node can be considered seriously as relay, functionality wise, should get us pretty close to a point where it can also be used for block production.
> 
> however, enabling block production in a mainnet environment, would incur in a serious increase in the funds we would need to ask
> 
> for the security audit alone, the amaru and blinklabs teams are asking an addtional 500k USD, which we believe to be appropriate.
> 
> additionally, if we were to include block production between the goal of this year, we'd also need to increase the estimated effort by *at least* 1 more FTE.
> 
> should the condition allow the next year, block production will be strongly considered.
> 
> given the current environment we decided it would be best to cut those efforts in order to contain the costs.

<!---------------------------------------------------------------------------------------------->
<!---------------------------------------------------------------------------------------------->
<!------------------------------------------- pebble ------------------------------------------->
<!---------------------------------------------------------------------------------------------->
<!---------------------------------------------------------------------------------------------->

### Pebble (smart contract programming language) 

[repo](https://github.com/HarmonicLabs/pebble)

| 🎯 Main Objective                 |
| ---                               |
| production-ready language & tools |

Pebble is a simple, yet rock solid, functional language with an imperative bias, targeting UPLC (Untyped Plutus Core). It provides developers with an intuitive syntax while compiling to highly optimized on-chain code.

#### Compiler Stability

##### Goal

Achieve production-grade compiler stability with optimized code generation.

##### Key Results

- Comprehensive type system with full type inference
- Optimized UPLC code generation with minimal script sizes
- Complete error reporting with actionable messages
- Support for Plutus V4
- Documentation and tutorials for onboarding new developers

##### Estimated Effort

2 FTEs

#### Developer Tooling

##### Goal

Provide a complete development experience for Pebble developers with IDE integration, debugging tools, and build system support.

##### Key Results

- **Language Server Protocol (LSP)** implementation:
  - Syntax highlighting
  - Auto-completion
  - Go-to-definition
  - Find references
  - Inline error reporting
  - Hover documentation
- **Stable and reliable sourcemaps** for debugging compiled contracts
- **CLI improvements**:
  - Build and watch modes
  - REPL for interactive development
- **Blueprint generation** for contract metadata

##### Estimated Effort

1.5 FTEs

### Pebble ━ Summary

- total resources estimated: `3.5 FTEs`

#### Differentiation from Aiken

Pebble and Aiken serve different developer profiles and are **complementary** within the Cardano ecosystem, not competitive.

| Dimension              | Aiken                            | Pebble                                 | Implication                                           |
| :--------------------- | :------------------------------- | :------------------------------------- | :---------------------------------------------------- |
| **Paradigm**           | Functional-first (Rust-inspired) | Imperative-first (TypeScript-inspired) | Different mental models for different developers      |
| **Target audience**    | Developers comfortable with FP   | Web2/EVM developers                    | Expands total addressable developer pool              |
| **Syntax familiarity** | Rust, Gleam                      | TypeScript, JavaScript, Solidity       | Lower barrier for the 17M+ JS/TS developers globally  |
| **Learning curve**     | Requires FP fundamentals         | Familiar imperative patterns           | Faster onboarding for majority of developers          |

##### Why both matter

Cardano needs multiple on-ramps for developers:
- Developers with Rust/Haskell/FP experience gravitate toward Aiken
- Developers with JS/TS/Solidity experience will find Pebble more accessible
- Both compile to optimized UPLC; the choice is about developer preference, not runtime performance

By funding Pebble, the Treasury expands Cardano's developer funnel without fragmenting it.

<!---------------------------------------------------------------------------------------------->
<!---------------------------------------------------------------------------------------------->
<!--------------------------------------- hf maintenance --------------------------------------->
<!---------------------------------------------------------------------------------------------->
<!---------------------------------------------------------------------------------------------->

### Hard-fork maintenance

| 🎯 Main Objective             |
| ---                           |
| guarantee ecosystem stability |

#### Upcoming Intra-Era Hard Fork

##### Goal

Ensure all HLabs TypeScript libraries are updated and fully compatible with the upcoming hard fork, including Plutus V4 changes and new protocol parameters.

##### Key Results

Maintenance of the affected repositories to support new protocol features:

- **[cardano-ledger-ts](https://github.com/HarmonicLabs/cardano-ledger-ts)**: Collection of functions and classes defining the Cardano ledger data structures
- **[ouroboros-miniprotocols-ts](https://github.com/HarmonicLabs/ouroboros-miniprotocols-ts)**: TypeScript implementation of the Ouroboros networking protocol
- **[plutus-machine](https://github.com/HarmonicLabs/plutus-machine)**: CEK machine implementation for UPLC evaluation
- **[uplc](https://github.com/HarmonicLabs/uplc)**: TypeScript/JavaScript representation of UPLC

##### Estimated Effort

1.5 FTE

### Hard-Fork Maintenance ━ Summary

- total resources estimated: `1.5 FTE`

---

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