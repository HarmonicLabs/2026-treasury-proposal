# The first node in the browser; a Cardano USP

## Abstract

Harmonic Laboratories (HLabs for short) is an R&D firm born and focused solely on the Cardano ecosystem.

Harmonic Laboratories supports and maintains a considerable portion of the TypeScript tooling for the Cardano ecosystem, which the majority of Cardano developers use, either directly, or indirectly via other libraries that depend on code written and maintained by HLabs.

The mission of HLabs is for true decentralization to become the baseline of application development, not only a nice-to-have feature.

This proposal funds [Gerolamo](https://github.com/HarmonicLabs/gerolamo), the first production-ready Cardano node that runs **in the browser**, at 5 FTE.

Cardano's eUTxO design and low-footprint protocol make it the only major blockchain where a fully-validating, in-browser node is technically realistic. This is not a research demo or a stripped-down SPV client; it is a real, fully-validating node. Shipping it turns a latent property of the protocol into a Cardano-specific competitive advantage that no other ecosystem can replicate without redesigning their base layer.

A separate proposal funds [Pebble](https://github.com/HarmonicLabs/pebble) and ongoing TypeScript tooling maintenance at 5 FTE and is voted on independently.

### Duration & Milestones

This proposal spans over **12 months**, throughout which there will be several deliveries and demos. The key delivery is:

- a production-ready light node that runs in the browser ([Gerolamo](https://github.com/HarmonicLabs/gerolamo)).

### Total Budget Ask

The estimated USD budget is of **`$1,125,000`** (or **`₳4,500,000`**) + 15% in refundable contingency (**`₳675,000`**); for a total ask of **`5,175,000 ADA`**.

## Motivation

### Why a node in the browser is a Cardano-only USP

Distribution of nodes is something every blockchain ecosystem has talked about and almost none have shipped. The reason is the base-layer design of those chains. Account-based chains with global state, large block sizes, mandatory full-state replay, or heavy proving systems simply cannot fit a validating node on low resources environments such as a brower tab without compromising on what "validating" means.

Cardano is different by design:

- **eUTxO state stays local to the transaction.** A browser node does not need to maintain a global mutable state of the entire ledger to validate the slice it cares about; it can verify only the inputs it consumes and the outputs it produces.
- **Block sizes and bandwidth requirements are bounded and modest** compared to high-throughput L1s, well within what a browser can sustain over typical residential connections.
- **Consensus (Praos) is verifiable on light resources**
- **Plutus scripts are pure functions over a deterministic CEK machine**, which is straightforward to host in a JavaScript/WebAssembly runtime and run inside a Web Worker without blocking the main thread.

Together these properties make Cardano the **only** major chain where an in-browser validating node is realistic today. Ethereum, Solana, and most account-based or high-TPS chains would each have to either cripple validation (effectively reverting to SPV/trusted-RPC) or fundamentally redesign their consensus and state model.

Gerolamo is the project that turns that latent advantage into a shipped product: "trustless on-device validation" becomes something Cardano can credibly market that competitors cannot match.

### Competitive positioning vs. other ecosystems

Decentralization narratives are increasingly contested across the L1 landscape. Ethereum's roadmap has spent years on "stateless clients" and "Verkle trees" specifically to shrink the trust surface of light clients; Solana's light clients depend on RPC providers and in practice are not trustless; most "light wallets" across ecosystems silently delegate validation to centralized infrastructure.

Gerolamo, by contrast, is a real node that runs consensus, validates headers and blocks, and evaluates Plutus scripts, all inside a browser tab. That is a tangible, demonstrable advantage Cardano can put in front of:

- developers evaluating which chain to build trust-minimized apps on,
- wallet teams designing custody UX without giving up on verification,
- enterprises and regulators who increasingly ask "where does the trust actually live?",
- governance and ecosystem campaigns highlighting Cardano's commitment to decentralization in concrete, shippable terms rather than aspirational ones.

This is the kind of differentiator that compounds: every dApp or wallet that ships with an embedded Gerolamo instance is a permanent talking point that every competitor has to answer.

### Research dividend: advanced validation, trustless bridges, and L2

Engineering a node small enough to run in a browser is more than a packaging exercise; it forces real progress on a class of problems the broader Cardano ecosystem will need anyway:

- **Compact / succinct validation.** Building Gerolamo requires rigorously distinguishing what _must_ be revalidated from what can be summarized, witnessed, or checkpointed. The same techniques (Mithril-style certificates, partial state proofs, header-chain verification with cryptographic anchors) are exactly the building blocks of trustless bridges and rollups.
- **Forcing function for future consensus work (Leios and beyond).** Maintaining a real, in-browser validating node creates a hard constraint that any future consensus protocol upgrade (Leios being the most immediate example) must remain verifiable on light resources. Without an artifact like Gerolamo on the table, "is this still tractable for a light client?" is an easy concern to defer; with it, the question is forced upfront. The verification primitives that fall out of that exercise (succinct certificates, cheap header validation, embeddable verifiers) are then directly reusable in comparable efforts such as trustless bridges and L2 verifiers, which need exactly the same property.
- **Trustless bridges.** A bridge contract on chain B that needs to verify the state of Cardano needs the same primitive as a browser node: a cheap, succinct, non-interactive way to check Cardano's chain history. Work on Gerolamo's verification path produces and battle-tests exactly the components a bridge implementation would otherwise have to re-derive from scratch.
- **Layer 2 systems.** Optimistic and validity-rollup-style L2s on Cardano need an efficient, embeddable verifier of the L1's state. A light node engineered for the browser is, structurally, the same artifact: minimal trust, minimal footprint, designed to be embedded inside another runtime. Investments in Gerolamo amortize across the L2 ecosystem.
- **dApp-side verification.** As more value moves on-chain, dApps will increasingly need to verify chain state themselves rather than trust their backend. Gerolamo gives them a drop-in, audited, JavaScript-native verifier instead of every team rolling its own.

Even setting aside the marketing value of "node in the browser," the engineering required to ship Gerolamo is foundational research the Cardano ecosystem needs in order to deliver on its bridges-and-L2 roadmap. Funding Gerolamo is funding that foundation.

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

For a fair valuation of the proposal, we will follow a similar process to what is used in the Amaru proposal, which we believe is setting a good standard in terms of Treasury budget proposals, and we will estimate the scopes of this proposal in _FTE_ (Full-Time Equivalent).

Let it be stated that the FTE figure reported below **DOES NOT** directly translate to the gross salary of a developer, instead it represents the gross income of a company who has to sustain various operational overheads (eg. taxes, complementary personnel, independent audits, etc.) before paying the gross salary of the developer.

Therefore, we will consider 1 FTE to equal a figure of `$225k` yearly rate.

We use a conversion rate of 0.25 `ADA/USD`.

#### Complete View

| Scope                                                     | Estimated (FTEs) | Project Total ($)  |
| :---                                                      | ---:             | ---:               |
| Gerolamo (TypeScript Cardano node)                        | 5                | `$1,125,000`       |
|                                                           |                  |                    |
| **Total**                                                 | **5 FTEs**       | `$1,125,000`       |

#### Cost Rationale

The total ask for the project is `5 FTEs`.

FTEs are being valued at an annual rate of `$225k`.

We are aware of our assumption/optimism bias: our forecast is subject to underestimating complexity, overlooking challenges, and undervaluing the time and cost required to deliver, as well as our biased expectation of market movements. We therefore add a 15% contingency buffer, learning from past mistakes.

This leaves us with the following total: `(5 x $225k) x 1.15 = $1,293,750`

Finally, using a conversion rate of `4` ADA per USD, we formulate a budget ask of **`₳5,175,000`**. A [complete breakdown of this budget](#budget-detailed-view) is available below.

### Milestones

This proposal spans an initial kickoff plus Q2 2026 through Q1 2027, organized into a kickoff milestone (Milestone 0) and four quarterly engineering milestones (Milestones 1–4). Each milestone unlocks a fixed share of the total `₳5,175,000` ask from the `vendor.ak` escrow, and disbursement requires the independent oversight committee to verify the deliverables and acceptance criteria below before co-signing.

Disbursement schedule. The total ask of **₳5,175,000** is composed of a base of **₳4,500,000** (5 FTE × $225,000 at $0.25/ADA) plus a refundable contingency reserve of **₳675,000** (15% of base). The kickoff milestone draws from the base only; the four engineering milestones split the remaining base evenly and share the entire contingency reserve evenly:

- **Milestone 0 (kickoff): ₳450,000** = 10% of base, no contingency disbursed at kickoff
- **Milestones 1–4 (engineering quarters), each ₳1,181,250** = ₳1,012,500 base (22.5% of base) + ₳168,750 contingency (25% of the contingency reserve)

Acceptance criteria are written to be objective and inspectable from a public artifact (a tagged release, a committed sync log, a public demo URL, a successful preprod transaction) rather than self-reported.

#### Milestone 0 (kickoff, on-chain enactment): Project Initialization & Governance Setup

**Deliverables**

- Treasury withdrawal executed on-chain and the requested 5,175,000 ADA escrowed in the SundaeSwap `treasury.ak` contract.
- `vendor.ak` vesting contract deployed with the M0–M4 milestone schedule and published payout addresses.
- Public kickoff announcement on HLabs channels (blog, X/Twitter, Discord) summarizing scope, oversight committee, and milestone schedule.
- A public proposal-tracking page (in the Gerolamo repo or HLabs governance repo) listing the milestone schedule, current status of each milestone, and links to all deliverables.
- Initial asynchronous oversight committee review with Santiago Carmuega, Lucas Rosa, and Chris Gianelloni, with the review summary published. (Committee reviews are conducted asynchronously throughout the proposal: there are no live meetings.)
- Governance / contribution README file added to the Gerolamo repo, documenting reporting cadence and the oversight-committee co-signature flow for disbursements.

**Acceptance criteria** (oversight committee verifies)

- The treasury withdrawal transaction is confirmed on-chain at the SundaeSwap treasury contract address.
- The `vendor.ak` deployment is observable on-chain with the M0–M4 schedule encoded.
- The public kickoff post exists at a reachable URL.
- The public proposal-tracking page exists at a reachable URL and lists the milestone schedule.
- A summary of the initial (asynchronous) oversight-committee review is published in the HLabs governance repo.

**Disbursement on completion**

- Base milestone payment: **₳450,000** (10% of the ₳4,500,000 base)
- Contingency portion: **₳0** (no contingency disbursed in this milestone)
- Total released: **₳450,000**

**Dependencies & risks**

- *Governance action timing.* M0 begins when the treasury withdrawal action is enacted on-chain, which is gated by the Cardano governance process and the voting / ratification window. M0's wall-clock duration after enactment is targeted at **≤30 days**.
- *Oversight committee reviews are asynchronous by design.* All committee reviews (including the initial kickoff review and every subsequent milestone sign-off) are conducted asynchronously rather than as live meetings, so member availability does not gate the 30-day window. Each review produces a written summary signed by the participating members.

#### Milestone 1 (Q2 2026, Apr–Jun): Storage, Networking & Preprod Sync Foundations

**Deliverables**

- Gerolamo storage layer working in both server (LMDB) and browser (IndexedDB) environments, with parity tests showing the same ledger state is produced across both backends on the same chain prefix.
- Networking layer (Ouroboros mini-protocols over Web Workers / WebSockets) sufficient to maintain peer connections in both environments.
- A first publicly tagged Gerolamo release on https://github.com/HarmonicLabs/gerolamo with the storage + networking foundations in place.
- Sync against a public preprod node from genesis to a recent tip, with the run logged and committed to the repo.

**Acceptance criteria** (oversight committee verifies)

- A new tagged release exists on the Gerolamo repo, dated within the milestone window.
- A committed sync log shows Gerolamo reaching preprod tip on commodity hardware (≥4 CPU, ≥8 GB RAM). Wall-clock duration is informational rather than gating for this milestone.
- The storage parity test (server vs. browser backend producing the same ledger state) is part of CI and green on the release commit.

**Disbursement on completion**

- Base milestone payment: **₳1,012,500** (22.5% of the ₳4,500,000 base)
- Contingency portion: **₳168,750** (25% of the ₳675,000 contingency reserve)
- Total released: **₳1,181,250**

**Dependencies & risks**

- *Plutus V4 hard fork timing.* Sync must work across the hard fork boundary; if the hard fork lands inside this milestone window, sync compatibility is rolled forward into Milestone 2's acceptance.
- *Preprod stability.* If preprod is unavailable for an extended period, the sync log can be reproduced against another public testnet (preview), and the milestone is satisfied by reaching tip on *any* public Cardano testnet.

#### Milestone 2 (Q3 2026, Jul–Sep): Server-Side Relay Release

**Deliverables**

- Gerolamo server-side relay release (installable via npm and as a standalone Bun/Node binary), able to follow chain tip on a public testnet for an extended run.
- UTxO RPC endpoints with a documented schema, sufficient for an external client (e.g. a wallet, an indexer prototype) to query chain state.
- Local socket support compatible with at least one node-to-client consumer (e.g. `cardano-cli query tip` succeeds against Gerolamo's socket).
- Public release notes describing how to run Gerolamo as a relay, including a quickstart for SPOs evaluating it alongside their Haskell node.

**Acceptance criteria** (oversight committee verifies)

- A new tagged Gerolamo release is publicly available within the milestone window.
- A committed run log shows Gerolamo following preprod chain tip for **≥6 hours** without crash or stall (intentionally a low bar; longer-duration testing is covered in Milestone 4).
- A reproducible quickstart in the Gerolamo README demonstrates `cardano-cli query tip` (or equivalent node-to-client query) succeeding against a Gerolamo socket.

**Disbursement on completion**

- Base milestone payment: **₳1,012,500** (22.5% of the ₳4,500,000 base)
- Contingency portion: **₳168,750** (25% of the ₳675,000 contingency reserve)
- Total released: **₳1,181,250**

**Dependencies & risks**

- *Node-to-client protocol surface is wide.* Full compatibility with every `cardano-cli` query is not in scope; the milestone is satisfied by `query tip` (or equivalent) plus the UTxO RPC. Broader compatibility is a Milestone 3/4 concern.

#### Milestone 3 (Q4 2026, Oct–Dec): Browser Light Node Demo

**Deliverables**

- Gerolamo running as a light node in a modern Chromium-based browser, syncing and serving chain data from inside a tab, with no backend server required for the verification path.
- A publicly hosted browser demo URL that loads Gerolamo in the browser and walks the user through a sync + UTxO query flow against a public testnet.
- Plutus script evaluation working in the browser (CEK machine in WebAssembly / JS) for at least the script subset needed to validate typical dApp transactions.
- Continued routine fixes / releases of the server-side relay against any in-window protocol changes.

**Acceptance criteria** (oversight committee verifies)

- The browser demo URL is publicly reachable and loads Gerolamo in a current Chromium release without backend dependency for the verification path; the oversight committee verifies by opening the URL.
- The browser demo successfully queries at least one UTxO on a public testnet during a live walkthrough (a recorded screencast committed to the repo is sufficient).
- Plutus script evaluation in the browser is demonstrated for ≥1 example contract, with a committed example and a reproducible run.

**Disbursement on completion**

- Base milestone payment: **₳1,012,500** (22.5% of the ₳4,500,000 base)
- Contingency portion: **₳168,750** (25% of the ₳675,000 contingency reserve)
- Total released: **₳1,181,250**

**Dependencies & risks**

- *Cross-browser compatibility.* This milestone targets Chromium engines (Chrome, Edge, Brave, Arc). Firefox and Safari support is part of Milestone 4. Mobile browsers are explicitly out of scope for this proposal.
- *Browser API churn.* WebAssembly / IndexedDB / Web Worker APIs are stable, but if a major Chromium release introduces a regression, the milestone is satisfied by demonstrating against the previous stable Chromium release.

#### Milestone 4 (Q1 2027, Jan–Mar): Stability, Wider Browser Reach & Documentation

**Deliverables**

- Stability hardening: the Gerolamo browser node reaches "tip" against a public testnet across multiple sessions, and the server-side relay maintains stable peer connections for an extended run.
- Browser support extended beyond Chromium-only: Gerolamo runs in **at least one additional major browser engine** (Firefox or WebKit / Safari).
- Production-readiness documentation: deployment guide for SPOs running Gerolamo as a relay, integration guide for wallet / dApp developers embedding Gerolamo in the browser, and a developer-facing API reference for the UTxO RPC and node-to-client surfaces.
- Public hand-off / "what's next" report describing the state of Gerolamo at proposal end and the work that remains for full block-production readiness (which is explicitly out of scope for this proposal).

**Acceptance criteria** (oversight committee verifies)

- A committed run log shows the server-side relay maintaining ≥15 stable peer connections for **≥24 hours** on preprod or in a mainnet relay role, measured via peer-list snapshots committed at the start and end of the run.
- A committed run log shows the browser node reaching a public testnet tip across **≥3 separate browser sessions** (start fresh, reach tip, close, repeat).
- The browser demo is verified working in **at least one non-Chromium engine** (Firefox or Safari), with a screencast committed to the repo.
- The deployment, integration, and API docs are published in the Gerolamo repo and discoverable from the README.

**Disbursement on completion**

- Base milestone payment: **₳1,012,500** (22.5% of the ₳4,500,000 base)
- Contingency portion: **₳168,750** (25% of the ₳675,000 contingency reserve)
- Total released: **₳1,181,250**

**Dependencies & risks**

- *Mainnet sync wall-clock time* (the 48-hour figure in the Production Readiness Criteria table) is a measurement commitment, not a milestone-acceptance criterion; funds release on the inspection criteria above, not on hitting a specific sync wall-clock that depends on hardware HLabs cannot pin for the oversight committee's environment.
- *Block production is explicitly out of scope* for this proposal and is not gated on this milestone. The hand-off report makes the boundary explicit so the next funding cycle can pick it up cleanly.

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

### Reporting

Progress on this proposal is reported publicly through the [HarmonicLabs/2026-treasury-proposal](https://github.com/HarmonicLabs/2026-treasury-proposal) repository, which is the same repository hosting this proposal document and metadata. The structure mirrors the precedent set by the BlinkLabs Dingo treasury proposal.

#### Monthly Lightweight Updates

At the end of each month during the funding period, HLabs publishes a status update covering:

- what shipped (key PRs, releases, features),
- progress against the active milestone,
- risks or blockers identified,
- the plan for the following month.

Updates are committed to the [`docs/reports/`](https://github.com/HarmonicLabs/2026-treasury-proposal/tree/main/docs/reports) tree of the repository and announced on HLabs community channels (X/Twitter, Discord).

#### Quarterly Detailed Reports

Each quarter, ahead of the corresponding milestone disbursement request, HLabs publishes a full report covering:

- progress against each milestone deliverable and acceptance criterion,
- a financial summary (received, spent by category, remaining),
- variance analysis for any budget deviations,
- updated risk register,
- the plan for the following quarter.

The quarterly report is committed to [`docs/reports/`](https://github.com/HarmonicLabs/2026-treasury-proposal/tree/main/docs/reports) and is the artifact the independent oversight committee reviews before co-signing the next disbursement.

#### Public Transaction Journal

Every on-chain transaction tied to this proposal (initial treasury withdrawal, milestone disbursements, vendor reorganizations, sweeps) is recorded in a public transaction journal at [`journal/`](https://github.com/HarmonicLabs/2026-treasury-proposal/tree/main/journal) in the repository. Each entry records the transaction hash, action type, amount, signers, justification, and on-chain metadata hash, so any observer can independently verify the activity against the chain.

### Constitutionality Checklist

In an effort to convince ourselves of the proposal's constitutionality, we thought relevant to include a checklist of the points we cover and for each, our interpretation of the Cardano Constitution.

#### Purpose

- [x] This proposal is for work intended to enhance the security, decentralization and long-term sustainability of Cardano.

#### Article II, Section 6: Governance Action Standards

- [x] We have submitted this proposal in a standardized, legible format, which includes a URL and hash of all documented off-chain content. We believe our rationale to be detailed and sufficient. The proposal contains a title, abstract, justification, and relevant supporting materials.

#### Article II, Section 7: "Treasury Withdrawals" Action Standards

- [x] **Section 7.1**: This proposal specifies the purpose of the withdrawal, the 12-month delivery period, the relevant costs and expenses, and the circumstances under which the withdrawal might be refunded to the Cardano Treasury.

- [x] **Section 7.2**: A full retrospective of past funding and deliverables is available in the [2025 retrospective](https://gateway.pinata.cloud/ipfs/QmZVw82XNXNsgGmBj39R26Mx7jgzWaNjSw4A7JM9Erye9c) document.

- [x] **Section 7.4**: Funds for **periodic** independent audits of deliverables are included in this ask, accounted for as part of the operational overheads built into the FTE figure (see [Budget Breakdown](#budget-breakdown), where the FTE rate is explicitly defined to cover "various operational overheads (eg. taxes, complementary personnel, independent audits, etc.)" rather than only developer salary). Verification of milestone delivery is performed by the independent oversight committee, and no disbursement of escrowed funds occurs without the committee's review and co-signature. Each milestone is independently audited before payment is released. **Oversight metrics on the use of ada** are implemented through (i) the public on-chain auditability of the SundaeSwap treasury contract, which exposes every disbursement on-chain, (ii) the independent oversight committee's published review of each milestone, and (iii) the monthly progress updates, quarterly financial reports, and public transaction journal published throughout the funding period in the [HarmonicLabs/2026-treasury-proposal](https://github.com/HarmonicLabs/2026-treasury-proposal) repository (see the [Reporting](#reporting) section above for the full structure).

- [x] **Section 7.5**: This proposal designates administrators (the oversight board) responsible for monitoring fund usage and ensuring deliverables are achieved.

- [x] **Section 7.6**: Treasury funds held by the administrator prior to disbursement will be kept in separate auditable accounts, delegated to the predefined `always_abstain` voting option.

#### Treasury Withdrawal Guardrails

- [x] **TREASURY-02a**: This withdrawal shall not exceed the Net Change Limit for the relevant period.

- [x] **TREASURY-03a**: This withdrawal is denominated in ada.

- [x] **TREASURY-04a**: We acknowledge this action requires greater than 50% of DRep active voting stake to be ratified.


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

Provide a full set of APIs for dApp developers and infrastructure operators to interact with the Cardano network through Gerolamo.

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
| **Extensibility**    | Cardano-specific           | Rust crates ecosystem                    | npm ecosystem integration      | Direct integration with web/dApp tooling          |
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
