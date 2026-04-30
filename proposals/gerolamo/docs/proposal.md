# The first node in the browser; a Cardano USP

## Abstract

Harmonic Laboratories (HLabs for short) is an R&D firm born and focused solely on the Cardano ecosystem.

Harmonic Laboratories supports and maintains a considerable portion of the TypeScript tooling for the Cardano ecosystem, which the majority of Cardano developers use, either directly, or indirectly via other libraries that depend on code written and maintained by HLabs.

The mission of HLabs is for true decentralization to become the baseline of application development, not only a nice-to-have feature.

This proposal funds [Gerolamo](https://github.com/HarmonicLabs/gerolamo), the first production-ready Cardano node that runs **in the browser**, at 5 FTE.

Cardano's eUTxO design and low-footprint protocol make it the only major blockchain where a fully-validating, in-browser node is technically realistic — not a research demo, not a stripped-down SPV client, but a real node. Shipping that node turns a latent property of the protocol into a Cardano-specific competitive advantage that no other ecosystem can replicate without redesigning their base layer.

A separate proposal funds [Pebble](https://github.com/HarmonicLabs/pebble) and ongoing TypeScript tooling maintenance at 5 FTE and is voted on independently.

### Duration & Milestones

This proposal spans over **12 months**, throughout which there will be several deliveries and demos. The key delivery is:

- a production-ready light node that runs in the browser ([Gerolamo](https://github.com/HarmonicLabs/gerolamo)).

### Total Budget Ask

The estimated USD budget is of **`$1,125,000`** (or **`₳4,500,000`**) + 15% in refundable contingency (**`₳675,000`**); for a total ask of **`5,175,000 ADA`**.

## Motivation

### Why a node in the browser is a Cardano-only USP

A "node in the browser" is something every blockchain ecosystem has talked about and almost none have shipped. The reason isn't engineering laziness — it's the base-layer design. Account-based chains with global state, large block sizes, mandatory full-state replay, or heavy proving systems simply cannot fit a validating node into a browser tab without compromising on what "validating" means.

Cardano is different by design:

- **eUTxO state stays local to the transaction.** A browser node does not need to maintain a global mutable state of the entire ledger to validate the slice it cares about; it can verify only the inputs it consumes and the outputs it produces.
- **Block sizes and bandwidth requirements are bounded and modest** compared to high-throughput L1s — well within what a browser can sustain over typical residential connections.
- **Consensus (Praos) is verifiable with light cryptographic checks** rather than requiring resource-heavy proof systems or trusted committees.
- **Plutus scripts are pure functions over a deterministic CEK machine**, which is straightforward to host in a JavaScript/WebAssembly runtime and run inside a Web Worker without blocking the main thread.

Put together, these properties don't just _allow_ an in-browser node — they make Cardano the **only** major chain where one is realistic today. Ethereum, Solana, and most account-based or high-TPS chains would each have to either cripple validation (effectively reverting to SPV/trusted-RPC) or fundamentally redesign their consensus and state model.

Gerolamo is the project that turns that latent advantage into a shipped product. As long as the node lives only in research papers and prototypes, it remains a footnote; once it ships and dApps and wallets adopt it, "trustless on-device validation" becomes something Cardano can credibly market that competitors cannot match.

### Competitive positioning vs. other ecosystems

Decentralization narratives are increasingly contested across the L1 landscape. Ethereum's roadmap has spent years on "stateless clients" and "Verkle trees" specifically to shrink the trust surface of light clients; Solana's light clients depend on RPC providers and in practice are not trustless; most "light wallets" across ecosystems silently delegate validation to centralized infrastructure.

Gerolamo, by contrast, is a real node — running consensus, validating headers, evaluating Plutus scripts — that fits inside a browser tab. That is a tangible, demonstrable advantage Cardano can put in front of:

- developers evaluating which chain to build trust-minimized apps on,
- wallet teams designing custody UX without giving up on verification,
- enterprises and regulators who increasingly ask "where does the trust actually live?",
- governance and ecosystem campaigns highlighting Cardano's commitment to decentralization in concrete, shippable terms rather than aspirational ones.

This is the kind of differentiator that compounds: every dApp or wallet that ships with an embedded Gerolamo instance is a permanent talking point that every competitor has to answer.

### Research dividend: advanced validation, trustless bridges, and L2

Engineering a node small enough to run in a browser is not just a packaging exercise. It forces real progress on a class of problems that the broader Cardano ecosystem will need anyway:

- **Compact / succinct validation.** Building Gerolamo requires rigorously distinguishing what _must_ be revalidated from what can be summarized, witnessed, or checkpointed. The same techniques (Mithril-style certificates, partial state proofs, header-chain verification with cryptographic anchors) are exactly the building blocks of trustless bridges and rollups.
- **Trustless bridges.** A bridge contract on chain B that needs to verify the state of Cardano needs the same primitive as a browser node: a cheap, succinct, non-interactive way to check Cardano's chain history. Work on Gerolamo's verification path directly produces components — and battle-tests them — that bridge implementations can reuse instead of re-deriving.
- **Layer 2 systems.** Optimistic and validity-rollup-style L2s on Cardano need an efficient, embeddable verifier of the L1's state. A light node engineered for the browser is, structurally, the same artifact: minimal trust, minimal footprint, designed to be embedded inside another runtime. Investments in Gerolamo amortize across the L2 ecosystem.
- **dApp-side verification.** As more value moves on-chain, dApps will increasingly need to verify chain state themselves rather than trust their backend. Gerolamo gives them a drop-in, audited, JavaScript-native verifier — instead of every team rolling its own.

In other words: even setting aside the marketing value of "node in the browser," the engineering required to ship Gerolamo is foundational research the Cardano ecosystem needs in order to deliver on its bridges-and-L2 roadmap. Funding Gerolamo is funding that foundation.

### Direct user benefits

Beyond the strategic case, Gerolamo unlocks concrete improvements for the three groups that interact with Cardano most directly:

#### dApps

Decentralized applications benefit immensely from trust-minimized access to blockchain data. Currently, most dApps rely on centralized indexers or third-party APIs to query the chain state, introducing points of failure and trust assumptions that undermine the decentralization ethos.

Gerolamo enables dApps to run their own lightweight nodes; even directly in the browser; providing direct, trustless access to the Cardano ledger.

This means dApps can verify UTxO states, validate transactions, and query chain data without relying on external services. The result is a more resilient, censorship-resistant application architecture that aligns with the core principles of decentralization.

#### Light wallets

Light wallets today must trust external servers to provide accurate chain data. This creates a security trade-off: users gain convenience but sacrifice the ability to independently verify their balances and transaction history.

With Gerolamo, wallet developers can integrate a lightweight node directly into their applications, offering users Daedalus-like security guarantees without the overhead of running a full node. Users can verify their own UTxOs, validate incoming transactions, and maintain full sovereignty over their funds, all while enjoying the user experience of a light wallet.

#### SPOs

Stake Pool Operators can use Gerolamo as an additional relay node alongside their existing infrastructure. Block production continues on their current setup, while Gerolamo relays add diversity and resilience to their pool.

A diverse node implementation landscape strengthens the network's resilience. By providing an alternative codebase for relays, Gerolamo reduces the risk of network-wide issues stemming from bugs in a single implementation; a critical factor for long-term network health and decentralization.

### Cardano 2030 Alignment

This proposal directly supports the [Cardano 2030 Strategic Framework](https://product.cardano.intersectmbo.org/vision/strategy-2030/), contributing to core KPIs and strategic pillars as outlined below.

#### Alignment with Core KPIs

| KPI / Strategic Priority                   | 2030 Target / Goal             | HLabs Contribution                                                              |
| :----------------------------------------- | :----------------------------- | :------------------------------------------------------------------------------ |
| **Alternative full node clients**          | ≥2 spec-conformant             | Gerolamo directly contributes as a second spec-conformant client implementation |

> **Note**: The row above is a formal Cardano 2030 KPI. TVL, monthly transactions, and MAU are ecosystem-level outcomes enabled by infrastructure investments like this proposal; we track adoption indicators (below) as leading metrics that contribute to these outcomes.

#### Alignment with Strategic Pillars

**Pillar 1: Infrastructure & Research Excellence**

- **I.2 Security & Resilience → Client Diversity**: Gerolamo is explicitly aligned with the 2030 goal of "supporting additional full-node and light-client implementations" to achieve "better decentralization" and "reduce single-client risk."

#### Measurable Adoption Indicators

To provide visibility into how this proposal contributes to ecosystem-level outcomes, we commit to tracking and reporting the following adoption metrics:

##### Gerolamo Adoption Targets

| Metric                           | 12-Month Target   | Measurement Method                     |
| :------------------------------- | :---------------- | :------------------------------------- |
| SPOs running Gerolamo as relay   | ≥10 pools         | Public registry + self-reporting       |
| Browser-based node integrations  | ≥3 wallets/dApps  | dApps/wallets integrations             |

## Rationale

### Budget Breakdown

The full budget breakdown is given below.

For a fair valuation of the proposal, we will follow a similar process to what is used in the Amaru proposal, which we believe is setting a good standard in terms of Treasury budget proposals, and we will estimate the scopes of this proposal in _FTE_ (Full-Time Equivalent), which we will consider to equal a figure of `$225k` yearly rate.

We use a conversion rate of `4` ADA [`₳`] per USD [`$`].

#### Complete View

| Scope                                                     | Estimated (FTEs) | Project Total ($)  |
| :---                                                      | ---:             | ---:               |
| Gerolamo (TypeScript Cardano node)                        | 5                | `$1,125,000`       |
|                                                           |                  |                    |
| **Total**                                                 | **5 FTEs**       | `$1,125,000`       |

#### Cost Rationale

The total ask for the project is `5 FTEs`.

FTEs are being valued at an annual rate of `$225k`.

Furthermore, we are aware of our assumption/optimism bias (our forecast is subject to underestimating complexity, overlooking challenges, and undervaluing the time and cost required to deliver, as well as our biased expectation of market movements). We therefore add an extra 15% contingency buffer, learning by our past mistakes.

This leaves us with the following total: `(5 x $225k) x 1.15 = $1,293,750`

Finally, using a conversion rate of `4` ADA per USD, we formulate a budget ask of **`₳5,175,000`**. A [complete breakdown of this budget](#budget-detailed-view) is available below.

### Milestones

This proposal spans Q2 2026 through Q1 2027, with milestones organized by quarter.

#### Q2 2026 (Apr–Jun): Foundations

- Gerolamo: improve storage and networking for browser environments

**Completion evidence:**

- Gerolamo syncs to tip on public test network

#### Q3 2026 (Jul–Sep): Core Delivery

- Gerolamo: initial server-side relay capable release

**Completion evidence:**

- Gerolamo server-side relay syncs and follows chain tip on public test network
- Gerolamo relay published as installable release

#### Q4 2026 (Oct–Nov): Integration & Browser Support

- Gerolamo: browser light node capable of syncing and serving chain data; compatibility with existing Cardano tooling

**Completion evidence:**

- Browser demo syncing and querying chain data without a backend server
- Standard Cardano tool (cardano-cli or cardano-db-sync) successfully connects to Gerolamo

#### Q1 2027 (Dec–Mar): Production Readiness

- Gerolamo: production-ready browser light node; performance validation

**Completion evidence:**

- Major browsers where Gerolamo runs as a light node (Chromium etc.)
- Gerolamo browser node reaches a "trustless" tip, eventually over multiple sessions
- Gerolamo maintains stable peer connections for ≥24 hours

### Budget Administration and Governance Oversight

#### Smart Contract Escrow

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

### Constitutionality Checklist

In an effort to convince ourselves of the proposal's constitutionality, we thought relevant to include a checklist of the points we cover and for each, our interpretation of the Cardano Constitution.

#### Purpose

- [x] This proposal is for work intended to enhance the security, decentralization and long-term sustainability of Cardano.

#### Article II, Section 6: Governance Action Standards

- [x] We have submitted this proposal in a standardized, legible format, which includes a URL and hash of all documented off-chain content. We believe our rationale to be detailed and sufficient. The proposal contains a title, abstract, justification, and relevant supporting materials.

#### Article II, Section 7: "Treasury Withdrawals" Action Standards

- [x] **Section 7.1** — This proposal specifies the purpose of the withdrawal, the 12-month delivery period, the relevant costs and expenses, and the circumstances under which the withdrawal might be refunded to the Cardano Treasury.

- [x] **Section 7.2** — A full retrospective of past funding and deliverables is available in the [2025 retrospective](https://gateway.pinata.cloud/ipfs/QmZVw82XNXNsgGmBj39R26Mx7jgzWaNjSw4A7JM9Erye9c) document.

- [x] **Section 7.5** — This proposal designates administrators (the oversight board) responsible for monitoring fund usage and ensuring deliverables are achieved.

- [x] **Section 7.6** — Treasury funds held by the administrator prior to disbursement will be kept in separate auditable accounts, delegated to the predefined `always_abstain` voting option.

#### Treasury Withdrawal Guardrails

- [x] **TREASURY-02a** — This withdrawal shall not exceed the Net Change Limit for the relevant period.

- [x] **TREASURY-03a** — This withdrawal is denominated in ada.

- [x] **TREASURY-04a** — We acknowledge this action requires greater than 50% of DRep active voting stake to be ratified.


#### Cardano 2030 Strategic Alignment

- [x] This proposal directly supports the Cardano 2030 Strategic Framework, contributing to the "Alternative full node clients" KPI (Pillar 1: Security & Resilience).

- [x] Measurable adoption indicators have been defined to provide visibility into ecosystem-level KPI contributions (TVL, monthly transactions, MAU).

### Budget Detailed View

#### Gerolamo (Typescript cardano node)

[repo](https://github.com/HarmonicLabs/gerolamo)

| Main Objective                                  |
| ---                                             |
| production-ready light node for dApps & wallets |

Gerolamo is a TypeScript implementation of the Cardano node designed for:
- **Browser compatibility**: Serving as a base for nodes running in browsers
- **Extensibility**: Being the base for purpose-specific nodes (light nodes, UTxO-only nodes, chain indexers)

##### Full Ledger Rules Coverage

###### Goal

Implement complete ledger validation rules to enable Gerolamo to fully validate blocks and transactions according to the Cardano protocol specifications.

###### Key Results

- Full ledger state management using LMDB (or IndexedDB for browsers) for performance improvements.
- Consensus implementation (Praos) with chain selection and rollback handling
- Volatile DB for managing chain forks
- Block and transaction validation covering all eras

###### Estimated Effort

2.5 FTEs

##### Node APIs

###### Goal

Provide comprehensive APIs for dApp developers and infrastructure operators to interact with the Cardano network through Gerolamo.

###### Key Results

- UTxO RPC endpoints for efficient UTxO queries
- Local socket support for node-to-client protocols (cardano-db-sync, cardano-cli compatibility)
- Browser API for dApps to use

###### Estimated Effort

2 FTEs

##### Plutus Machine Improvements

###### Goal

Continuously improve the [plutus-machine](https://github.com/HarmonicLabs/plutus-machine) CEK interpreter for better performance and full conformance with the Plutus specification.

###### Key Results

- Performance optimizations for script evaluation
- Budget tracking and cost model accuracy improvements
- Sourcemap support for debugging

###### Estimated Effort

0.5 FTEs

##### Gerolamo Summary

- total resources estimated: `5 FTEs`

##### Production Readiness Criteria

Gerolamo will be considered production-ready as a browser light node when it meets the following objective criteria:

| Criterion              | Requirement                                                    | Verification Method     |
| :--------------------- | :------------------------------------------------------------- | :---------------------- |
| **Sync reliability**   | Successful sync from genesis to tip on mainnet                 | Continuous integration  |
| **Sync performance**   | Initial sync ≤48 hours on commodity hardware (4 CPU, 16GB RAM) | Benchmark suite         |
| **Peer connectivity**  | Stable connections with ≥15 peers for ≥24 hours                | Network validation      |
| **Block propagation**  | Block relay latency within 2x of Haskell node baseline         | Comparative benchmarks  |
| **Rollback handling**  | Successful recovery from rollbacks up to k=2160 blocks         | Adversarial scenarios   |

##### Value Proposition vs. Other Node Implementations

| Dimension            | Haskell Node               | Amaru                                    | Gerolamo                       | Gerolamo Benefit                                  |
| :------------------- | :------------------------- | :--------------------------------------- | :----------------------------- | :------------------------------------------------ |
| **Runtime**          | GHC runtime                | Native (Rust)                            | Bun/Node.js/Browser            | Runs anywhere JavaScript runs, including browsers |
| **Browser support**  | No                         | Limited support planned (WASM, EOY 2026) | Yes (IndexedDB + WebWorkers)   | Production-ready browser support sooner           |
| **Developer access** | Haskell expertise required | Rust expertise required                  | TypeScript/JavaScript          | Largest contributor pool (17M+ JS/TS developers)  |
| **Extensibility**    | Cardano-specific           | Rust crates ecosystem                    | npm ecosystem integration      | Seamless integration with web/dApp tooling        |
| **Use cases**        | Full block production      | Full block production                    | Browser light node, data node, relay | Complementary; JS/TS native browser capability    |

> [!NOTE]
>  Gerolamo is designed as a **complementary implementation** focused on browser light node and data-node use cases, not a replacement for block-producing nodes yet. Block production so far remains on the Haskell node.
>
> Getting to a point where the node can be considered seriously as a production-ready light node, functionality wise, should get us pretty close to a point where it can also be used for block production.
>
> however, enabling block production in a mainnet environment, would incur in a serious increase in the funds we would need to ask
>
> for the security audit alone, the amaru and blinklabs teams are asking an additional 500k USD, which we believe to be appropriate.
>
> additionally, if we were to include block production between the goal of this year, we'd also need to increase the estimated effort by *at least* 1 more FTE.
>
> should the condition allow the next year, block production will be strongly considered.
>
> given the current environment we decided it would be best to cut those efforts in order to contain the costs.
