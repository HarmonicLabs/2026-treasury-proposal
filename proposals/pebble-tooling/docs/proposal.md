# HLabs 2026 — Pebble + Tooling Maintenance

## Abstract

Harmonic Laboratories (HLabs for short) is an R&D firm born and focused solely on the Cardano ecosystem.

Harmonic Laboratories supports and maintains a considerable portion of the TypeScript tooling for the Cardano ecosystem, which the majority of Cardano developers use, either directly, or indirectly via other libraries that depend on code written and maintained by HLabs.

The mission of HLabs is for true decentralization to become the baseline of application development, not only a nice-to-have feature.

This proposal funds two complementary engineering tracks:

- a production-ready, imperative and efficient, programming language for smart contracts ([Pebble](https://github.com/HarmonicLabs/pebble));
- ongoing maintenance of HLabs' TypeScript tooling, including support for an upcoming intra-era hard fork.

A separate proposal funds the [Gerolamo light node](https://github.com/HarmonicLabs/gerolamo) at 5 FTE and is voted on independently.

### Duration & Milestones

This proposal spans over **12 months**, throughout which there will be several deliveries and demos. Amongst the key deliveries, we note:

- maintenance for an upcoming hard fork;
- a production-ready, imperative and efficient, programming language for smart contracts ([Pebble](https://github.com/HarmonicLabs/pebble)).

### Total Budget Ask

The estimated USD budget is of **`$1,125,000`** (or **`₳4,500,000`**) + 15% in refundable contingency (**`₳675,000`**); for a total ask of **`5,175,000 ADA`**.

## Motivation

### Ecosystem benefits

Pebble and ongoing tooling maintenance each serve distinct stakeholders while collectively strengthening Cardano's developer experience and long-term sustainability.

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

For a fair valuation of the proposal, we will follow a similar process to what is used in the Amaru proposal, which we believe is setting a good standard in terms of Treasury budget proposals, and we will estimate the scopes of this proposal in _FTE_ (Full-Time Equivalent), which we will consider to equal a figure of `$225k` yearly rate.

We use a conversion rate of `4` ADA [`₳`] per USD [`$`].

#### Complete View

| Scope                                                     | Estimated (FTEs) | Project Total ($)  |
| :---                                                      | ---:             | ---:               |
| Pebble (programming language + dApp development tools)    | 3.5              | `$787,500`         |
| Hard-fork & tooling maintenance                           | 1.5              | `$337,500`         |
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

#### Q2 2026 (Apr–Jun): Hard Fork Readiness & Foundations

- Hard-fork maintenance: all TypeScript libraries updated for the upcoming hard fork
- Pebble: complete the type system; support for upcoming hard fork changes

**Completion evidence:**

- All relevant libraries maintained by HLabs support the Hardfork
- Multiple (≥3) pebble contracts of various complexity compiled end-to-end to valid on-chain code

#### Q3 2026 (Jul–Sep): Core Delivery

- Pebble: additional key language features, such as namespaces, tests and more comprehensive standard library

**Completion evidence:**

- New language features implemented (e.g. namespaces, tests, standard library)

#### Q4 2026 (Oct–Nov): Integration & Browser Support

- Pebble: complete IDE integration & CLI + push for developers onboarding

**Completion evidence:**

- Pebble IDE extension published with syntax highlighting and inline errors
- Pebble CLI `build` command working on multiple projects

#### Q1 2027 (Dec–Mar): Production Readiness, Documentation & Adoption

- Pebble: interactive console, documentation, tutorials

**Completion evidence:**

- Pebble language features documented with examples
- End-to-end tutorials published

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

- Comprehensive type system with full type inference
- Optimized UPLC code generation with minimal script sizes
- Complete error reporting with actionable messages
- Support for Plutus V4
- Key language features: namespaces, built-in test support, comprehensive standard library
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
