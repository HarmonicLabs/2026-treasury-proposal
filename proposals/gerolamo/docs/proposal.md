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

The estimated USD budget is of **`$1,000,000`** (or **`₳4,000,000`**) + 15% in refundable contingency (**`₳600,000`**); for a total ask of **`4,600,000 ADA`**.

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

Gerolamo, by contrast, is a real node that runs consensus, validates headers and blocks, and evaluates Plutus scripts, all inside a browser extension on the user's machine. That is a tangible, demonstrable advantage Cardano can put in front of:

- developers evaluating which chain to build trust-minimized apps on,
- wallet teams designing custody UX without giving up on verification,
- enterprises and regulators who increasingly ask "where does the trust actually live?",
- governance and ecosystem campaigns highlighting Cardano's commitment to decentralization in concrete, shippable terms rather than aspirational ones.

This is the kind of differentiator that compounds: Gerolamo ships as a browser extension that users install once, and every dApp or wallet that wires up to it inherits trust-minimized chain access for free. Each new integration is a permanent talking point that every competitor has to answer.

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

Gerolamo lets dApps query a fully-validating light node hosted by a browser extension the user installs once, providing direct, trustless access to the Cardano ledger without any backend dependency.

This means dApps can verify UTxO states, validate transactions, and query chain data without relying on external services. The result is a more resilient, censorship-resistant application architecture that aligns with the core principles of decentralization.

#### Light wallets

Light wallets today must trust external servers to provide accurate chain data. This creates a security trade-off: users gain convenience but sacrifice the ability to independently verify their balances and transaction history.

With Gerolamo, wallet developers can integrate a lightweight node directly into their applications, offering users Daedalus-like security guarantees without the overhead of running a full node. Users can verify their own UTxOs, validate incoming transactions, and maintain full sovereignty over their funds, all while enjoying the user experience of a light wallet.

#### Client diversity at the light-node tier

Cardano's resilience benefits from having multiple, independently-developed client implementations. Gerolamo contributes a TypeScript-native, browser-targeted light node to that landscape, reducing the risk that a bug or assumption in any single client cascades through the wallets and dApps that depend on it.

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
| Browser-based node integrations  | ≥3 wallets/dApps  | dApps/wallets integrations             |

### Treasury Risk Minimization Statement

This proposal has been intentionally designed to minimize treasury exposure during the current treasury-constrained environment.

In particular, the scope:

- deliberately excludes block production infrastructure and other SPO-oriented functionalities, focusing on apps and users first;
- deliberately excludes additional FTE expansion beyond the minimum team required for delivery;
- deliberately excludes non-essential operational overhead.
- minimizes the cost of a single FTE without compromising feasibility.

The proposal focuses exclusively on the minimum viable scope necessary to deliver:
a production-ready browser-based Cardano light node (Gerolamo).

This approach reflects a deliberate effort to balance innovation, ecosystem value, and responsible treasury stewardship.

## Rationale

### Budget Breakdown

The full budget breakdown is given below.

For a fair valuation of the proposal, we will follow a similar process to what is used in the Amaru proposal, which we believe is setting a good standard in terms of Treasury budget proposals, and we will estimate the scopes of this proposal in _FTE_ (Full-Time Equivalent).

Let it be stated that the FTE figure reported below **DOES NOT** directly translate to the gross salary of a developer, instead it represents the gross income of a company who has to sustain various operational overheads (eg. taxes, complementary personnel, independent audits, etc.) before paying the gross salary of the developer.

Therefore, we will consider 1 FTE to equal a figure of `$200k` yearly rate.

We use a conversion rate of 0.25 `ADA/USD`.

#### Complete View

| Scope                                 | Estimated (FTEs) | Project Total ($)  |
| :---                                  | ---:             | ---:               |
| Gerolamo (TypeScript Cardano node)    | 5                | `$1,000,000`       |
|                                       |                  |                    |
| **Total**                             | **5 FTEs**       | `$1,000,000`       |

#### Cost Rationale

The total ask for the project is `5 FTEs`.

FTEs are being valued at an annual rate of `$200k`.

We are aware of our assumption/optimism bias: our forecast is subject to underestimating complexity, overlooking challenges, and undervaluing the time and cost required to deliver, as well as our biased expectation of market movements. We therefore add a 15% contingency buffer, learning from past mistakes.

This leaves us with the following total: `(5 x $200k) x 1.15 = $1,150,000`

Finally, using a conversion rate of `0.25 ADA/USD`, we formulate a budget ask of **`₳4,600,000`**. A [complete breakdown of this budget](#budget-detailed-view) is available below.

### Milestones

This proposal spans an initial kickoff plus Q2 2026 through Q1 2027, organized into a kickoff milestone (Milestone 0) and four quarterly engineering milestones (Milestones 1–4). Each milestone unlocks a fixed share of the total `₳4,600,000` ask from the `vendor.ak` escrow, and disbursement requires the independent oversight committee to verify the deliverables and acceptance criteria below before co-signing.

Disbursement schedule. The total ask of **₳4,600,000** is composed of a base of **₳4,000,000** (5 FTE × $200,000 at $0.25/ADA) plus a refundable contingency reserve of **₳600,000** (15% of base). The kickoff milestone draws from the base only; the four engineering milestones split the remaining base evenly and share the entire contingency reserve evenly:

- **Milestone 0 (kickoff): ₳400,000** = 10% of base, no contingency disbursed at kickoff
- **Milestones 1–4 (engineering quarters), each ₳1,050,000** = ₳900,000 base (22.5% of base) + ₳150,000 contingency (25% of the contingency reserve)

Acceptance criteria are written to be objective and inspectable from a public artifact (a tagged release, a committed sync log, a public demo URL, a successful preprod transaction) rather than self-reported.

#### Milestone 0 (kickoff, on-chain enactment): Project Initialization & Governance Setup

Milestone 0 is the kickoff milestone and carries no engineering deliverables. It is triggered by the on-chain enactment of the treasury withdrawal and the deployment of the SundaeSwap `treasury.ak` / `vendor.ak` escrow with the M0–M4 schedule encoded.

**Disbursement on completion**

- Base milestone payment: **₳400,000** (10% of the ₳4,000,000 base)
- Contingency portion: **₳0** (no contingency disbursed in this milestone)
- Total released: **₳400,000**

#### Milestone 1 (Q2 2026, Apr–Jun): Browser Storage, Networking & Preprod Sync Foundations

**Deliverables**

- Gerolamo storage layer working in the browser environment (IndexedDB), capable of holding the working ledger state needed for light-node verification.
- Networking layer (Ouroboros mini-protocols over Web Workers / WebSockets + proxy) sufficient to maintain peer connections from the browser.
- A first publicly tagged Gerolamo release on https://github.com/HarmonicLabs/gerolamo with the browser-side storage + networking foundations in place.
- Sync against a public preprod node up to a recent tip from a browser context, with the run logged and committed to the repo.

**Acceptance criteria** (oversight committee verifies)

- A new tagged release exists on the Gerolamo repo.
- A committed sync log shows Gerolamo reaching preprod tip from a browser environment on commodity hardware. Wall-clock duration is informational rather than gating for this milestone.
- The browser storage layer (IndexedDB) is exercised in CI and green on the release commit.

**Disbursement on completion**

- Base milestone payment: **₳900,000** (22.5% of the ₳4,000,000 base)
- Contingency portion: **₳150,000** (25% of the ₳600,000 contingency reserve)
- Total released: **₳1,050,000**

#### Milestone 2 (Q3 2026, Jul–Sep): Public Extension Release & Simple Query API

**Deliverables**

- The Gerolamo browser extension published to a public extension store (Chrome Web Store and/or equivalent) so end users can install it directly without unpacked-extension developer flows.
- A documented messaging API exposing the **simple, non-indexed query surface** of the extension, complex queries left for milestone 3, in the spirit of how CIP-30 wallet connectors expose a `window.cardano.*` surface, but backed by the extension's own validating node rather than a remote provider:
  - tip / point queries
  - UTxO lookup by output reference (`tx_hash#index`)
  - transaction submission
- A minimal demo dApp page that, with the Gerolamo extension installed, exercises the simple-query API against a public testnet with no backend.

**Acceptance criteria** (oversight committee verifies)

- The Gerolamo extension is publicly listed on a major browser extension store, verifiable by the oversight committee via the store URL and a successful install on a clean profile.
- The simple-query messaging API is documented in the repo and reachable via the published extension.
- The example dApp page is committed to the repo with a reproducible README walkthrough demonstrating the tip, block, UTxO-by-output-reference, and transaction-submission flows via the extension against a public testnet.

**Disbursement on completion**

- Base milestone payment: **₳900,000** (22.5% of the ₳4,000,000 base)
- Contingency portion: **₳150,000** (25% of the ₳600,000 contingency reserve)
- Total released: **₳1,050,000**

#### Milestone 3 (Q4 2026, Oct–Dec): Indexed Query API (UTxOs by Address & Asset)

**Deliverables**

- Extension internals extended with the per-address and per-asset UTxO indexes needed to serve indexed lookups efficiently from the extension's local storage, kept consistent across rollbacks.
- Messaging API extended with the **indexed query surface**:
  - UTxOs by address
  - UTxOs by asset (policy ID, optionally with asset name)
  - paginated variants of the above for results that exceed messaging-channel-friendly sizes
- The demo dApp page extended to exercise the new indexed queries, and the API reference updated to cover the new endpoints.

**Acceptance criteria** (oversight committee verifies)

- A new tagged extension release within the milestone window, published to the same public store, surfaces the indexed query API.
- The repo includes test fixtures showing the indexed queries returning correct results against a known testnet state, including correct behaviour across a rollback.
- The demo dApp's README walkthrough covers a UTxO-by-address and a UTxO-by-asset query end-to-end against a public testnet.

**Disbursement on completion**

- Base milestone payment: **₳900,000** (22.5% of the ₳4,000,000 base)
- Contingency portion: **₳150,000** (25% of the ₳600,000 contingency reserve)
- Total released: **₳1,050,000**

#### Milestone 4 (Q1 2027, Jan–Mar): Stability, Wider Browser Reach & Documentation

**Deliverables**

- Stability hardening: the Gerolamo extension reaches "tip" against a public testnet across multiple browser sessions and maintains a stable peer set for an extended run while the extension is active.
- Production-readiness documentation: integration guide for wallet / dApp developers consuming the Gerolamo extension's messaging API, and a developer-facing API reference for the messaging surface.
- Public hand-off / "what's next" report describing the state of Gerolamo at proposal end and the work that remains beyond a browser-extension light node (which is explicitly out of scope for this proposal).

**Acceptance criteria** (oversight committee verifies)

- A committed run log shows the extension maintaining ≥15 stable peer connections for **≥24 hours** against a public testnet, measured via peer-list snapshots committed at the start and end of the run.
- A committed run log shows the extension reaching a public testnet tip across **≥3 separate browser sessions** (start fresh, reach tip, close, repeat).
- The extension is verified working in **at least one non-Chromium engine** (Firefox or Safari), with a screencast committed to the repo.
- The integration and API docs are published in the Gerolamo repo and discoverable from the README.

**Disbursement on completion**

- Base milestone payment: **₳900,000** (22.5% of the ₳4,000,000 base)
- Contingency portion: **₳150,000** (25% of the ₳600,000 contingency reserve)
- Total released: **₳1,050,000**

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

Gerolamo is a TypeScript implementation of the Cardano node, scoped under this proposal exclusively to the **browser-extension light-node** use case: a fully-validating client packaged as a browser extension that the user installs once, then exposes a messaging API to dApp pages so they can obtain on-device verification of chain state without a trusted backend.

##### Full Ledger Rules Coverage

###### Goal

Implement complete ledger validation rules to enable Gerolamo to fully validate blocks and transactions according to the Cardano protocol specifications.

###### Key Results

- Full ledger state management using IndexedDB in the browser, with the in-memory representation tuned for light-node working set sizes.
- Consensus implementation (Praos) with chain selection and rollback handling
- Volatile DB for managing chain forks
- Block and transaction validation covering all eras

###### Estimated Effort

2.5 FTEs

##### Node APIs

###### Goal

Provide a full set of APIs for dApp developers and infrastructure operators to interact with the Cardano network through Gerolamo.

###### Key Results

- UTxO query API surface exposed by the Gerolamo browser extension to dApp pages
- Messaging API (in the spirit of CIP-30 wallet connectors) for dApps to obtain trust-minimized, on-device verification answers from the user's installed Gerolamo extension

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
| **Sync reliability**   | Successful sync from genesis to tip on mainnet from a browser context | Continuous integration  |
| **Sync performance**   | Initial sync within a duration acceptable for a browser light client on commodity hardware | Benchmark suite         |
| **Peer connectivity**  | Stable connections with ≥15 peers for ≥8 hours from the browser      | Network validation      |
| **Rollback handling**  | Successful recovery from every-day size rollbacks | Adversarial scenarios   |

##### Value Proposition vs. Other Node Implementations

| Dimension            | Haskell Node               | Amaru                                    | Gerolamo                       | Gerolamo Benefit                                  |
| :------------------- | :------------------------- | :--------------------------------------- | :----------------------------- | :------------------------------------------------ |
| **Runtime**          | GHC runtime                | Native (Rust)                            | Browser (JavaScript / WebAssembly) | Runs in any modern browser, no backend required for verification |
| **Browser support**  | No                         | Limited support planned (WASM, EOY 2026) | Yes (IndexedDB + WebWorkers)   | Production-ready browser support sooner           |
| **Developer access** | Haskell expertise required | Rust expertise required                  | TypeScript/JavaScript          | Largest contributor pool (17M+ JS/TS developers)  |
| **Extensibility**    | Cardano-specific           | Rust crates ecosystem                    | npm ecosystem integration      | Direct integration with web/dApp tooling          |
| **Use cases**        | Full block production      | Full block production                    | Browser light node             | Trust-minimized on-device verification for wallets and dApps |

> [!NOTE]
>  Gerolamo is designed as a **complementary implementation** focused exclusively on the browser light-node use case under this proposal. Server-side relay roles, block production, and other full-node use cases are explicitly out of scope here and remain on the Haskell node (and other implementations such as Amaru) for the duration of this funding period.
>
> for the security audit alone, the amaru and blinklabs teams are asking an additional 500k USD, which we believe to be appropriate.
>
> additionally, if we were to include block production between the goal of this year, we'd also need to increase the estimated effort by *at least* 1 more FTE.
>
> should the condition allow the next year, block production will be strongly considered.
>
> given the current environment we decided it would be best to cut those efforts in order to contain the costs.
