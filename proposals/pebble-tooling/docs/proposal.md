# Pebble & Ecosystem maintenance: TypeScript core of Cardano

## Abstract

Harmonic Laboratories (HLabs for short) is an R&D firm born and focused solely on the Cardano ecosystem.

Harmonic Laboratories supports and maintains a considerable portion of the TypeScript tooling for the Cardano ecosystem, which the majority of Cardano developers use, either directly, or indirectly via other libraries that depend on code written and maintained by HLabs.

The mission of HLabs is for true decentralization to become the baseline of application development, not only a nice-to-have feature.

This proposal funds two complementary engineering tracks:

- **[Pebble](https://github.com/HarmonicLabs/pebble)**: the first production-ready imperative smart-contract language on Cardano. Pebble brings to UPLC a programming paradigm Aiken structurally cannot deliver, ships a TypeScript-shaped surface syntax that the largest developer community on earth already uses, and (per HLabs' published benchmarks) produces on-chain code that strictly outperforms Aiken and is competitive with Plutarch, while remaining dramatically more readable than either.
- **Tooling maintenance**: keeping HLabs' TypeScript stack (`cardano-ledger-ts`, `ouroboros-miniprotocols-ts`, `plutus-machine`, `uplc`, etc.) synchronized with protocol upgrades. This stack is not optional infrastructure: it is what production projects across the ecosystem already depend on, including [Mesh](https://meshjs.dev/), [Lucid Evolution](https://github.com/Anastasia-Labs/lucid-evolution), and L2 systems like [Midgard](https://github.com/Anastasia-Labs/midgard). When HLabs ships a hard-fork update, the rest of the TypeScript ecosystem ships with it; when HLabs lags, every downstream project lags.

A separate proposal funds the [Gerolamo light node](https://github.com/HarmonicLabs/gerolamo) at 5 FTE and is voted on independently.

### Duration & Milestones

This proposal spans over **12 months**, throughout which there will be several deliveries and demos. Amongst the key deliveries, we note:

- maintenance for an upcoming hard fork;
- a production-ready, imperative and efficient, programming language for smart contracts ([Pebble](https://github.com/HarmonicLabs/pebble)).

### Total Budget Ask

The estimated USD budget is of **`$1,000,000`** (or **`₳4,000,000`**) + 15% in refundable contingency (**`₳600,000`**); for a total ask of **`4,600,000 ADA`**.

## Motivation

### Why Pebble is a strict upgrade over the existing options

Cardano already has two reasonable smart-contract languages: **Aiken** (functional, ergonomic, the current default) and **Plutarch** (low-level, high-performance, but notoriously hostile to write). Pebble does not aim to be a third entry alongside them; it aims to introduce an alternative that considers the dimensions that actually matter to developers shipping production contracts.

#### A paradigm Aiken structurally cannot deliver

Aiken is functional-first by design. That is a deliberate choice, but it is also a ceiling: naturally imperative algorithms (accumulators with mutable state, early-exit control flow, stepwise transformations of complex records, fold-with-side-effect patterns) have to be encoded into a functional shape. Experienced FP developers do this fluently. The vast majority of working developers do not.

Pebble adds the missing paradigm. It is imperative-first with strong static typing and full type inference, compiling to the same UPLC target. This is not "Aiken with different keywords"; it is a different cognitive model: write the algorithm the way you would write it in TypeScript, Rust, Go, or Solidity, and let the compiler optimize.

This gap will not close inside Aiken. Retrofitting a real imperative paradigm onto a functional core would mean rewriting Aiken into a different language. Pebble simply ships that language.

#### Performance: strictly better than Aiken, comparable to Plutarch

The tradeoff developers have lived with so far has been "use Aiken and accept overhead, or use Plutarch and accept the cost in development time and bug surface." Pebble's published benchmarks (per IOG's independent [UPLC-CAPE](https://intersectmbo.github.io/UPLC-CAPE/)) show that it:

- produces on-chain UPLC that **strictly outperforms equivalent Aiken contracts** in both CPU and memory budget, with smaller script sizes;
- comes within range (if not better) of **hand-tuned Plutarch** on the same workloads;
- does so without asking the developer to think about UPLC primitives, scopes, or builtin selection (the compiler handles that).

The implication is that Pebble eliminates the "performance vs. ergonomics" tradeoff that has defined Cardano smart-contract development to date. There is no remaining argument of the form "yes Pebble is more pleasant, but you have to give up efficiency": the benchmarks show the opposite.

#### The largest developer community on earth, by self-report

The Cardano Foundation's annual developer surveys consistently show **TypeScript / JavaScript as the most-used language among Cardano developers**, by a wide margin, ahead of every functional language combined. This mirrors the global picture: Stack Overflow's developer surveys have ranked JavaScript and TypeScript at or near the top for over a decade, with a working population in the tens of millions.

Pebble's surface syntax is deliberately TypeScript-shaped: the same expression forms, the same type annotations, the same control structures. A working TypeScript developer does not learn "a new language" to write Pebble; they learn a constrained dialect of one they already use every day.

This is the largest single onboarding lever Cardano has available to it for smart-contract development, and Aiken cannot pull it: Aiken's syntax is closer to Rust/Gleam, which is a different audience entirely.

#### A direct on-ramp for Solidity developers

Solidity is, for all its differences from TypeScript, also imperative, statically typed, and C-family in shape. The mental model translates cleanly to Pebble: contracts as procedures, locals as mutable bindings, control flow as explicit branches and loops. Pebble's documentation will lean into this, guiding EVM developers through the eUTxO model in a language whose surface they already recognize.

For an ecosystem competing for developer migration, this matters. The friction in moving from Solidity to Aiken is two simultaneous shifts: the eUTxO model **and** functional programming. With Pebble, the eUTxO shift is the only barrier, and that is a markedly smaller one.

### Why Pebble and Aiken can coexist (and Cardano benefits from both)

This proposal is not a case for replacing Aiken. Aiken is well-supported, well-loved by FP-fluent teams, and has a healthy contributor base. The Cardano ecosystem benefits from having a polished functional option for the developers who want one.

What Cardano does not currently have is a polished imperative option, and that gap is what gates a whole class of developers from contributing. Pebble fills it. The result is two compilers, both targeting UPLC and optimizing the same bytecode, offering different on-ramps for different mental models without either subtracting from the other.

### Tooling maintenance: foundational, in production, non-optional

The second half of this proposal is the unglamorous but load-bearing work: keeping HLabs' TypeScript stack alive across protocol upgrades.

The libraries in question are not internal HLabs concerns; they are dependencies of the wider TypeScript ecosystem on Cardano:

- **[Mesh](https://meshjs.dev/)**, the most widely-used dApp SDK on Cardano, pulls on HLabs primitives transitively for ledger types, CBOR, and protocol semantics.
- **[Lucid Evolution](https://github.com/Anastasia-Labs/lucid-evolution)**, the active fork of Lucid maintained by Anastasia Labs and depended on by a large fraction of production wallets and dApps, depends on the same stack.
- **[Midgard](https://github.com/Anastasia-Labs/midgard)**, Anastasia Labs' Layer 2, runs on top of these libraries in production. When HLabs ships, Midgard ships; when HLabs lags, Midgard lags.
- Numerous wallet integrations, indexers, and dApp backends pull `cardano-ledger-ts`, `ouroboros-miniprotocols-ts`, `plutus-machine`, and `uplc` directly or transitively.

This is the situation a hard fork creates: the moment the protocol changes, every one of those projects has a hard dependency on whoever maintains the foundation. If that maintenance is reliably funded, the ecosystem ships in lockstep with the protocol. If it is not, the ecosystem fragments: projects fork the libraries, freeze on old versions, or migrate, none of which serves Cardano.

Funding tooling maintenance through this proposal is not "nice to have alongside Pebble"; it is the predictable, unglamorous payment that keeps the production TypeScript ecosystem on Cardano coherent through the next protocol upgrade. Skipping it does not save money: it pushes the cost to dozens of downstream teams who each have to absorb it independently and inconsistently.

### Direct user benefits

Beyond the strategic case, this proposal unlocks concrete improvements for the people who build on Cardano daily:

#### For developers writing new contracts

- An imperative, TypeScript-shaped language with full LSP support, autocompletion, go-to-definition, inline diagnostics, and a working watch-mode CLI, giving a development experience comparable to mature Web2 ecosystems.
- Performance characteristics that previously required dropping down to Plutarch.
- Straightforward onboarding for the TypeScript and Solidity developer populations, the two largest pools of working programmers globally.

#### For projects already shipping on Cardano

- A maintained, hard-fork-ready TypeScript foundation under Mesh, Lucid Evolution, Midgard, and the long tail of dApps that depend on them, without any of those teams having to fund the maintenance themselves.
- Continuity across protocol upgrades, so applications keep working without emergency rewrites or extended downtime.

#### For the ecosystem as a whole

- A second well-supported smart-contract paradigm targeting UPLC, broadening the developer funnel without fragmenting the runtime.
- Reduced concentration risk: critical libraries no longer depending on a single team's discretionary capacity to keep up with the protocol.

### Cardano 2030 Alignment

This proposal directly supports the [Cardano 2030 Strategic Framework](https://product.cardano.intersectmbo.org/vision/strategy-2030/), contributing to core KPIs and strategic pillars as outlined below.

#### Alignment with Core KPIs

| KPI / Strategic Priority                   | 2030 Target / Goal             | HLabs Contribution                                                              |
| :----------------------------------------- | :----------------------------- | :------------------------------------------------------------------------------ |
| **Monthly Uptime**                         | 99.98%                         | Hard-fork maintenance ensures ecosystem stability across protocol upgrades      |
| **Developer migration pathways** (A.3)     | "More developers can onboard"  | Pebble provides EVM/TS developers a familiar syntax for Cardano smart contracts |

> **Note**: The first row is a formal Cardano 2030 KPI. The second row corresponds to Strategic Pillar A.3 (Developer Experience → Education & migration), which is an explicit 2030 priority but not yet a numeric KPI. TVL, monthly transactions, and MAU are ecosystem-level outcomes enabled by infrastructure investments like this proposal; we track adoption indicators (below) as leading metrics that contribute to these outcomes.

#### Alignment with Strategic Pillars

**Pillar 2: Adoption & Utility**

- **A.3 Developer Experience → Open-source incentives**: This proposal directly addresses the strategic priority to "incentivize the maintenance of core Cardano SDKs, frameworks, and infrastructure in line with open-source best practices" for a "sustainable builder ecosystem."
- **A.3 Developer Experience → Education & migration**: Pebble addresses the goal to "provide materials for EVM/account-based devs moving to Cardano/UTxO" by offering familiar imperative syntax, enabling "more developers to onboard."

#### Measurable Adoption Indicators

To provide visibility into how this proposal contributes to ecosystem-level outcomes, we commit to tracking and reporting the following adoption metrics:

##### Pebble Adoption Targets

| Metric                     | 12-Month Target         | Measurement Method                             |
| :------------------------- | :---------------------- | :--------------------------------------------- |
| Developer onboarding       | ≥20 developers          | npm downloads, GitHub stars, Discord members   |
| Documentation completeness | 100% coverage           | All language features documented with examples |
| Tutorial completion        | ≥3 e2e tutorials        | Published guides covering common patterns      |

## Rationale

### Budget Breakdown

The full budget breakdown is given below.

For a fair valuation of the proposal, we will follow a similar process to what is used in the Amaru proposal, which we believe is setting a good standard in terms of Treasury budget proposals, and we will estimate the scopes of this proposal in _FTE_ (Full-Time Equivalent).

Let it be stated that the FTE figure reported below **DOES NOT** directly translate to the gross salary of a developer, instead it represents the gross income of a company who has to sustain various operational overheads (eg. taxes, complementary personnel, independent audits, etc.) before paying the gross salary of the developer.

Therefore, we will consider 1 FTE to equal a figure of `$200k` yearly rate.

We use a conversion rate of 0.25 `ADA/USD`.

#### Complete View

| Scope                                                     | Estimated (FTEs) | Project Total ($)  |
| :---                                                      | ---:             | ---:               |
| Pebble (programming language + dApp development tools)    | 3.5              | `$700,000`         |
| Hard-fork & tooling maintenance                           | 1.5              | `$300,000`         |
|                                                           |                  |                    |
| **Total**                                                 | **5 FTEs**       | `$1,000,000`       |

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
- **Milestones 1–4 (engineering quarters), each ₳1,050,000 total** = ₳900,000 base (22.5% of base) + ₳150,000 contingency (25% of the contingency reserve)
- **Milestone 1 is split into two independently-payable sub-milestones**: **1.A (Pebble)** at 80% of M1 = ₳840,000 (₳720,000 base + ₳120,000 contingency) and **1.B (hard-fork maintenance)** at 20% of M1 = ₳210,000 (₳180,000 base + ₳30,000 contingency). 1.A and 1.B can be co-signed and paid independently as each sub-milestone's deliverables are accepted.

Acceptance criteria are written to be objective and inspectable from a public artifact (a tagged release, a UPLC-CAPE submission, a published benchmark report, a committed test log) rather than self-reported.

#### Milestone 0 (kickoff, on-chain enactment): Project Initialization & Governance Setup

**Deliverables**

- Treasury withdrawal executed on-chain and the requested 4,600,000 ADA escrowed in the SundaeSwap `treasury.ak` contract.
- `vendor.ak` vesting contract deployed with the M0–M4 milestone schedule and published payout addresses.
- Public kickoff announcement on HLabs channels (blog, X/Twitter, Discord) summarizing scope, oversight committee, and milestone schedule.
- A public proposal-tracking page (in the Pebble repo or HLabs governance repo) listing the milestone schedule, current status of each milestone, and links to all deliverables.
- Initial asynchronous oversight committee review with Santiago Carmuega, Lucas Rosa, and Chris Gianelloni, with the review summary published. (Committee reviews are conducted asynchronously throughout the proposal: there are no live meetings.)
- Governance / contribution README file added to the four maintained library repos and the Pebble repo, documenting reporting cadence and the oversight-committee co-signature flow for disbursements.

**Acceptance criteria** (oversight committee verifies)

- The treasury withdrawal transaction is confirmed on-chain at the SundaeSwap treasury contract address.
- The `vendor.ak` deployment is observable on-chain with the M0–M4 schedule encoded.
- The public kickoff post exists at a reachable URL.
- The public proposal-tracking page exists at a reachable URL and lists the milestone schedule.
- A summary of the initial (asynchronous) oversight-committee review is published in the HLabs governance repo.

**Disbursement on completion**

- Base milestone payment: **₳400,000** (10% of the ₳4,000,000 base)
- Contingency portion: **₳0** (no contingency disbursed in this milestone)
- Total released: **₳400,000**

#### Milestone 1.A (Q2 2026, Apr–Jun): Pebble Type System

**Deliverables**

- Pebble release with the type system finalized (full inference, sum types, generics, namespaces, etc.).
- ≥3 example Pebble contracts of meaningful complexity, committed to the Pebble repo and compiling end-to-end to on-chain UPLC.

**Acceptance criteria** (oversight committee verifies)

- Pebble has a new version with the specified features released on npm
- The ≥3 example contracts compile to UPLC and execute successfully on a current preview/preprod node (a committed log or link to a successful tx is sufficient). Plutus V4 codegen support is not part of M1.A; it is delivered in Milestone 2.

**Disbursement on completion**

- Base milestone payment: **₳720,000** (80% of M1 base; 18% of the ₳4,000,000 base)
- Contingency portion: **₳120,000** (80% of M1 contingency; 20% of the ₳600,000 contingency reserve)
- Total released: **₳840,000**

#### Milestone 1.B (Q2 2026, Apr–Jun): Hard Fork Readiness

**Deliverables**

- New tagged releases of the relevant maintained libraries, each carrying support for the upcoming intra-era hard fork (Plutus V4 + revised cost model + new protocol parameters).

**Acceptance criteria** (oversight committee verifies)

- Each of the four libraries has a new public release on its GitHub repo, dated within the milestone window.
- Each library's existing test suite passes against a Plutus V4 testnet snapshot (CI green on the release commit).

**Disbursement on completion**

- Base milestone payment: **₳180,000** (20% of M1 base; 4.5% of the ₳4,000,000 base)
- Contingency portion: **₳30,000** (20% of M1 contingency; 5% of the ₳600,000 contingency reserve)
- Total released: **₳210,000**

#### Milestone 2 (Q3 2026, Jul–Sep): Pebble Language Completeness & Public Benchmarks

**Deliverables**

- Pebble release with the missing language features the community has identified as blockers for production use: namespaces / module system, a built-in test framework, and an expanded standard library covering common dApp patterns (lists, maps, value arithmetic, common datum/redeemer shapes).
- **Plutus V4 codegen support in the Pebble compiler**, so Pebble contracts can target the post-hard-fork Plutus version end-to-end (compilation, execution on a Plutus V4 preview/preprod node).
- **Pebble submissions to UPLC-CAPE for the remaining benchmark scenarios it does not currently cover.** As of this proposal's drafting, Pebble has entries in the fixed-algorithm naive recursion benchmarks; this milestone extends Pebble's coverage to the open-optimization Fibonacci and Factorial benchmarks plus at least one of the three real-world contracts (Two-Party Escrow, Linear Vesting, HTLC).
- A short public benchmark write-up (blog post / repo README section) showing Pebble's UPLC-CAPE position vs. the other compilers in the suite.

**Acceptance criteria** (oversight committee verifies)

- A new tagged Pebble release exists with the test framework, standard library additions, and Plutus V4 codegen (visible in release notes).
- A Pebble contract compiled with the V4 codegen executes successfully on a Plutus V4 preview/preprod node (committed log or tx link).
- Pebble appears in **at least one new UPLC-CAPE category** beyond Fibonacci/Factorial naive recursion at https://intersectmbo.github.io/UPLC-CAPE/, verifiable by the oversight committee opening the live report.
- The public benchmark write-up is published and linked from the Pebble README.

**Disbursement on completion**

- Base milestone payment: **₳900,000** (22.5% of the ₳4,000,000 base)
- Contingency portion: **₳150,000** (25% of the ₳600,000 contingency reserve)
- Total released: **₳1,050,000**

#### Milestone 3 (Q4 2026, Oct–Dec): Developer Tooling & IDE Experience

**Deliverables**

- Pebble REPL for interactive development.
- Sourcemap support sufficient for the LSP to surface error locations in the original Pebble source.
- integration of sourcemaps in hlabs maintained tools like buildooor, for improved developer experience.
- Continued routine maintenance of the four libraries against any in-window protocol parameter updates.

**Acceptance criteria** (oversight committee verifies)

- The Pebble CLI `pebble repl` (or equivalent) commands work on a freshly cloned example project, reproducible from a public README walkthrough.
- Buildooor support for sourcemaps

**Disbursement on completion**

- Base milestone payment: **₳900,000** (22.5% of the ₳4,000,000 base)
- Contingency portion: **₳150,000** (25% of the ₳600,000 contingency reserve)
- Total released: **₳1,050,000**

#### Milestone 4 (Q1 2027, Jan–Mar): Documentation, Tutorials & Adoption Push

**Deliverables**

- Complete reference documentation for the Pebble language: comprehensive language feature documented with at least one runnable example.
- ≥3 end-to-end tutorials covering common dApp patterns (an escrow, a vesting schedule, a token / NFT minting policy, or equivalent), with each tutorial compiling, deploying to preprod, and walking the reader through on-chain interaction.
- Onboarding guide aimed specifically at TypeScript developers and Solidity developers transitioning to Cardano / eUTxO.

**Acceptance criteria** (oversight committee verifies)

- The Pebble documentation site covers what specified above.
- The ≥3 end-to-end tutorials are published.

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

- [x] This proposal directly supports the Cardano 2030 Strategic Framework, contributing to Developer Experience priorities (Pillar 2: Adoption & Utility).

- [x] Measurable adoption indicators have been defined to provide visibility into ecosystem-level KPI contributions (TVL, monthly transactions, MAU).

### Budget Detailed View

#### Pebble (smart contract programming language)

[repo](https://github.com/HarmonicLabs/pebble)

| Main Objective                    |
| ---                               |
| production-ready language & tools |

Pebble is a simple, yet rock solid, functional language with an imperative bias, targeting UPLC (Untyped Plutus Core). It provides developers with an intuitive syntax while compiling to highly optimized on-chain code.

##### Compiler Stability

###### Goal

Achieve production-grade compiler stability with optimized code generation.

###### Key Results

- Full type system with complete type inference
- Optimized UPLC code generation with small script sizes
- Error reporting with actionable messages
- Support for Plutus V4
- Key language features: namespaces, built-in test support, full standard library
- Documentation and tutorials for onboarding new developers

###### Estimated Effort

2 FTEs

##### Developer Tooling

###### Goal

Provide a complete development experience for Pebble developers with IDE integration, debugging tools, and build system support.

###### Key Results

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

###### Estimated Effort

1.5 FTEs

##### Pebble Summary

- total resources estimated: `3.5 FTEs`

##### Differentiation from Aiken

Pebble and Aiken serve different developer profiles and are **complementary** within the Cardano ecosystem, not competitive.

| Dimension              | Aiken                            | Pebble                                 | Implication                                           |
| :--------------------- | :------------------------------- | :------------------------------------- | :---------------------------------------------------- |
| **Paradigm**           | Functional-first (Rust-inspired) | Imperative-first (TypeScript-inspired) | Different mental models for different developers      |
| **Target audience**    | Developers comfortable with FP   | Web2/EVM developers                    | Expands total addressable developer pool              |
| **Syntax familiarity** | Rust, Gleam                      | TypeScript, JavaScript, Solidity       | Lower barrier for the 17M+ JS/TS developers globally  |
| **Learning curve**     | Requires FP fundamentals         | Familiar imperative patterns           | Faster onboarding for majority of developers          |

###### Why both matter

Cardano needs multiple on-ramps for developers:
- Developers with Rust/Haskell/FP experience gravitate toward Aiken
- Developers with JS/TS/Solidity experience will find Pebble more accessible
- Both compile to optimized UPLC; the choice is about developer preference, not runtime performance

By funding Pebble, the Treasury expands Cardano's developer funnel without fragmenting it.

#### Hard-fork & tooling maintenance

| Main Objective                |
| ---                           |
| guarantee ecosystem stability |

##### Upcoming Intra-Era Hard Fork

###### Goal

Ensure all HLabs TypeScript libraries are updated and fully compatible with the upcoming hard fork, including Plutus V4 changes and new protocol parameters.

###### Key Results

Maintenance of the affected repositories to support new protocol features:

- **[cardano-ledger-ts](https://github.com/HarmonicLabs/cardano-ledger-ts)**: Collection of functions and classes defining the Cardano ledger data structures
- **[ouroboros-miniprotocols-ts](https://github.com/HarmonicLabs/ouroboros-miniprotocols-ts)**: TypeScript implementation of the Ouroboros networking protocol
- **[plutus-machine](https://github.com/HarmonicLabs/plutus-machine)**: CEK machine implementation for UPLC evaluation
- **[uplc](https://github.com/HarmonicLabs/uplc)**: TypeScript/JavaScript representation of UPLC

###### Estimated Effort

1.5 FTE

##### Hard-Fork & Tooling Maintenance Summary

- total resources estimated: `1.5 FTE`
