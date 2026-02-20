# Blink Labs Treasury Proposal: Funding Dingo -- A Production-Grade Go Node for Cardano

## 1. Abstract

Blink Labs requests a single Cardano Treasury withdrawal of **$PLACEHOLDER ADA** to fund
twelve months of full-time engineering on
[Dingo](https://github.com/blinklabs-io/dingo), a production-grade Cardano node
written in Go. Dingo is not a research prototype: it is a functional node with
over 300 merged pull requests, full Plutus V1--V3 script evaluation, 314 passing
conformance tests, VRF/KES cryptographic operations, block production
capabilities, mempool management, and governance transaction processing. This
proposal funds the work required to bring Dingo from its current advanced state
to mainnet block-production readiness, including full Ouroboros Praos consensus
completion, Dijkstra hard fork support, a Leios protocol implementation developed
in collaboration with IOG's research team, a comprehensive security audit by a
major firm, and the operational hardening necessary to run reliably at mainnet
scale. The result is genuine node diversity for Cardano -- a second implementation
capable of both data service and block production -- strengthening the network's
resilience, expanding its developer ecosystem into the Go community, and
providing a foundation for next-generation protocol evolution.

---

## 2. Motivation: Who We Are

### Blink Labs

Blink Labs is a nine-person engineering company focused exclusively on Cardano
infrastructure. We build in Go because it is the language best suited to
high-performance networked systems, and because the Cardano ecosystem benefits
from having its core infrastructure accessible to the millions of developers who
already know Go.

We have been building on Cardano since 2022 and have a track record of shipping
production software that the community depends on today:

| Project | Description | Maturity |
|---------|-------------|----------|
| **[Dingo](https://github.com/blinklabs-io/dingo)** | Go Cardano node -- block production, sync, VRF/KES, Plutus evaluation, mempool, governance | 300+ merged PRs, 314/314 conformance tests |
| **[gOuroboros](https://github.com/blinklabs-io/gouroboros)** | Ouroboros mini-protocol library -- full era support Byron through Conway | 2,200+ tests, used by downstream projects |
| **[Plutigo](https://github.com/blinklabs-io/plutigo)** | Plutus script evaluation engine -- V1, V2, V3 at 100% conformance | Integrated into Dingo |
| **[Adder](https://github.com/blinklabs-io/adder)** | Chain indexing pipeline with pluggable outputs | Production use |
| **[Snek](https://github.com/blinklabs-io/snek)** | Event notification framework for Cardano | Production use |
| **[nview](https://github.com/blinklabs-io/nview)** | Terminal-based node monitoring tool | Shipped |
| **[TxSubmit API](https://github.com/blinklabs-io/tx-submit-api)** | Cardano transaction submission service | Production use, Docker-based |
| **Docker images** | Cardano node and tooling container images | Widely adopted by SPOs |

Our prior Cardano funding has been exclusively through **Project Catalyst Fund 12**,
which funded initial Dingo development. We are members of PRAGMA, the Cardano
maintenance organization. **We have received no funds from the Amaru project or
any other PRAGMA treasury initiative despite our membership.** This proposal
stands entirely on its own merits.

### Key Personnel

- **Chris Gianelloni** -- Lead Architect. Designed and leads development of
  Dingo, gOuroboros, and the broader Go infrastructure stack. Responsible for
  architecture decisions, protocol implementation, and technical direction.

- **Ales S.** -- Infrastructure Engineer. Manages CI/CD pipelines, deployment
  infrastructure, testing automation, and the operational systems that keep
  Blink Labs' software running in production environments.

- **Rich C.** -- Technical Documentation. Owns developer-facing documentation,
  API references, and the technical writing that makes our software accessible
  to the broader Cardano community.

- **Christina Gianelloni** -- Chief Operating Officer. Manages all community
  engagement, governance communications, DRep outreach, and operational
  coordination. Christina handles the public-facing side so that engineers can
  stay focused on code.

---

## 3. Motivation: Why Dingo

### Node Diversity Is Network Resilience

Cardano currently depends on a single node implementation for block production.
This is a single point of failure at the protocol level. A critical bug in one
implementation -- whether a consensus defect, a memory leak under load, or a
vulnerability discovered in production -- affects every node on the network
simultaneously. There is no fallback.

Dingo provides that fallback. A second node implementation capable of full block
production means that a bug in either implementation leaves the other still
operational. This is not a theoretical concern: Ethereum's multi-client
architecture has repeatedly demonstrated its value when individual clients
experienced issues that would have been network-wide outages in a
single-implementation world.

### Go Ecosystem Accessibility

Cardano's core infrastructure is written in Haskell, a language with a small
professional developer community. Go, by contrast, is one of the most widely
adopted systems programming languages in the world, with particular strength in
networked services, cloud infrastructure, and concurrent systems -- exactly the
domains that matter for blockchain nodes.

Dingo makes Cardano's node internals accessible to this vast developer pool.
Engineers who build with Go at companies like Google, Cloudflare, Docker, and
thousands of others can read, understand, audit, and contribute to Cardano's
infrastructure without learning Haskell first. This is not about replacing
Haskell -- it is about expanding the talent pool that can meaningfully
participate in Cardano's evolution.

### Scalability Through Leios

The Leios protocol represents Cardano's next major scalability leap. Blink Labs
is already collaborating directly with IOG's research team on Leios, and Dingo's
Go architecture -- with its native concurrency model via goroutines and
channels -- is exceptionally well suited to the parallelism that Leios demands.
Implementing Leios in a second language alongside the Haskell reference
implementation strengthens the specification itself by surfacing ambiguities and
ensuring the protocol is truly implementation-independent.

### Sustainability Through Open Source

All Blink Labs software is released under the **Apache 2.0** license. Dingo,
gOuroboros, Plutigo, and every supporting tool are and will remain open source.
The work funded by this proposal is a permanent public good for the Cardano
ecosystem -- it does not depend on Blink Labs' continued operation to remain
available to the community.

### What the Ecosystem Loses Without Funding

Without dedicated funding, Dingo continues at a reduced pace using only Blink
Labs' existing resources. Concretely, this means:

- **No block production readiness.** Dingo remains a data node only. The
  consensus work required for mainnet block production does not happen.
- **No SPO story.** Stake pool operators cannot run Dingo as an alternative or
  failover block producer. The node diversity value proposition does not
  materialize.
- **No Dijkstra hard fork support.** Protocol changes for the next hard fork
  are deprioritized. Dingo falls behind the network.
- **No Leios implementation.** The Go implementation of Leios -- and the
  specification-strengthening benefits of a second implementation -- does not
  happen on any meaningful timeline.
- **No security audit.** A comprehensive audit of a full Cardano node
  implementation requires dedicated funding.

The Cardano community has invested significantly in the Go infrastructure stack
through Catalyst and through Blink Labs' own resources. Without this funding,
that investment reaches only a fraction of its potential value.

---

## 4. Rationale: Executive Summary of Costs

This proposal requests a single treasury withdrawal to cover twelve months of
development. All amounts are denominated in USD with an ADA conversion at the
time of the governance action, plus a contingency buffer to absorb price
volatility.

| Category | Estimated Cost (USD) |
|----------|---------------------:|
| Engineering (4 FTE x 12 months) | $PLACEHOLDER |
| Security Audit (major firm) | ~$500,000 |
| Infrastructure & CI/CD | $PLACEHOLDER |
| Documentation & Community Engagement | $PLACEHOLDER |
| **Subtotal** | **$PLACEHOLDER** |
| Contingency (~40% for ADA volatility) | $PLACEHOLDER |
| **Total** | **$PLACEHOLDER** |

**Requested Amount: $PLACEHOLDER ADA**

### Notes on the Budget

- **Engineering** is the core cost: four full-time engineers for twelve months
  at market rates for senior systems/protocol engineers. This is not outsourced
  or contracted work -- these are Blink Labs employees with deep Cardano
  expertise and years of context on the Dingo codebase.

- **Security audit** is budgeted at approximately $500,000 for a comprehensive
  review by a major firm (e.g., Trail of Bits, NCC Group, or equivalent). A
  full Cardano node implementation warrants a thorough audit before any
  production block production.

- **Contingency** of approximately 40% follows precedent set by other Cardano
  treasury proposals and accounts for ADA price volatility between the time of
  proposal approval and the expenditure of funds. Our price volatility strategy
  combines this buffer with significant upfront conversion to stablecoin or fiat
  upon receipt, plus acceptance of remaining residual risk.

- **Single withdrawal.** We request the full amount in a single treasury
  withdrawal, with internal milestones enforced by smart contract escrow and
  oversight board review (see Section 5).

---

## 5. Rationale: Administration of the Budget

### Smart Contract Escrow

Funds are held and disbursed through the
[SundaeSwap treasury-contracts](https://github.com/SundaeSwap-finance/treasury-contracts),
a battle-tested smart contract framework consisting of two validators:

- **treasury.ak** -- Holds the funds withdrawn from the Cardano treasury. All
  withdrawn ADA is locked in this contract upon enactment of the governance
  action.
- **vendor.ak** -- Manages milestone-based vesting for Blink Labs as the sole
  vendor. Defines the payment schedule, maximum payout dates, and conditions
  under which funds are released.

Both contracts have been independently audited by **TxPipe** and **MLabs** and
are in production use on Cardano mainnet.

### Blink Labs as Single Vendor

Blink Labs is the sole vendor under this proposal. All engineering, documentation,
and deliverables are produced by Blink Labs employees. There are no subcontractors
or secondary vendors. This simplifies accountability: if a deliverable is not met,
there is exactly one party responsible.

### Independent Oversight Board

An independent oversight board provides third-party governance over fund
disbursements. Board members are PRAGMA-adjacent individuals who are not direct
Blink Labs stakeholders. The board's responsibilities include:

- Co-signing periodic fund releases from the vendor contract
- Reviewing milestone completion before authorizing disbursements
- Emergency halt capability if deliverables are not being met
- Dispute resolution with binding authority

### Permission Scheme

We use a least-friction permission model to avoid operational bottlenecks while
maintaining meaningful oversight:

| Action | Required Signatures |
|--------|-------------------|
| Disburse (periodic release) | Blink Labs initiates + any 1 oversight board member co-signs |
| Sweep early (return unused funds) | Blink Labs + any 1 oversight board member |
| Reorganize (adjust milestone schedule) | Blink Labs only |
| Fund (initial vendor setup) | Oversight board majority |
| Pause milestone | Any 1 oversight board member |
| Resume milestone | Oversight board majority |
| Modify project | Blink Labs + oversight board majority |

This scheme ensures that routine operations (disbursements) require only a
single board member's approval, while structural changes (modifying the project
scope) require broader consensus. Any single board member can pause a milestone
if they identify a concern, providing an effective emergency brake.

### Delegation Policy

The treasury contract enforces an **auto-abstain DRep delegation** and **no SPO
delegation** for all funds held in escrow. This ensures that treasury funds do
not influence governance votes or staking during the proposal period.

### Failsafe Sweep

Any funds remaining in the treasury contract after the proposal expiration date
are automatically swept back to the Cardano treasury. This is enforced at the
smart contract level and cannot be overridden by either Blink Labs or the
oversight board.

### Periodic Fixed Releases

Funds are released on a periodic fixed schedule defined in the vendor contract,
subject to oversight board co-signature. This provides predictable cash flow for
engineering while maintaining the board's ability to halt releases if
deliverables fall short. The release schedule aligns with the quarterly milestone
structure defined in the Scope of Work (Section 8).

---

## 6. Rationale: Reporting

### Monthly Lightweight Updates

At the end of each calendar month, Blink Labs publishes a brief status update
covering:

- Summary of work completed during the month
- Key pull requests merged, features shipped, and milestones reached
- Any new risks or blockers identified
- Preview of planned work for the following month

These updates are published to the
[treasury-proposal repository](https://github.com/blinklabs-io/treasury-proposal)
and announced through community channels.

### Quarterly Detailed Reports

At the end of each quarter, Blink Labs publishes a comprehensive report
including:

- Detailed progress against each milestone in the Scope of Work
- Financial summary: funds received, funds spent by category, funds remaining
- Variance analysis for any budget deviations
- Updated risk register
- Forward-looking plan for the next quarter

Quarterly reports are timed to coincide with vendor contract disbursement
requests, providing the oversight board with the information needed to authorize
fund releases.

### Public Transaction Journal

Every on-chain transaction related to this proposal -- disbursements, milestone
claims, sweeps, reorganizations -- is recorded in a public
[transaction journal](https://github.com/blinklabs-io/treasury-proposal/tree/main/journal)
within this repository. Each entry includes the transaction hash, action type,
amount, signers, justification, and on-chain metadata hash, following the
SundaeSwap metadata standard. Any community member can independently verify
every entry against the on-chain record.

### Coding Sessions and Demos

Blink Labs conducts periodic live coding sessions and technical demonstrations
to give the community direct visibility into the engineering work. These sessions
cover active development areas, walk through architectural decisions, and
demonstrate Dingo capabilities as they are built. Sessions are announced on
X/Twitter and the Cardano Forum and are recorded for later viewing.

---

## 7. Rationale: Constitutionality Checklist

This section self-assesses the proposal's compliance with the Cardano
Constitution (v2.4), following the format established by the
[PRAGMA mnemos template](https://github.com/pragma-org/mnemos).

### Purpose

This proposal requests a treasury withdrawal to fund development of Dingo, a
Go-based Cardano node implementation, to production readiness. The purpose is to
deliver genuine node diversity for the Cardano network -- a second full node
capable of both data service and block production -- along with Dijkstra hard
fork support and a Leios protocol implementation.

### Article III, Section 5 -- On-Chain Governance Actions

> *Governance actions shall follow a standardized and legible format, including
> a URL and hash of any off-chain content.*

**Assessment: COMPLIANT.**
This governance action is submitted as a Treasury Withdrawal action using
CIP-108 metadata. The on-chain governance action references an off-chain
metadata document via URL (GitHub commit-hash pinned, with IPFS mirror via
Blockfrost) and includes the blake2b-256 hash of the metadata content. The
metadata document is comprehensive and self-contained, including the full
proposal title, abstract, motivation, and rationale. All content is human-readable
and follows the CIP-108 standard structure.

### Article IV, Section 1 -- Budget for the Cardano Blockchain Ecosystem

> *A budget for the Cardano Blockchain ecosystem shall be adopted on an annual
> basis through an on-chain governance action.*

**Assessment: COMPLIANT.**
This proposal covers a twelve-month period, approximately 73 epochs, aligning
with the annual budget cycle. The budget is fully specified, including
engineering costs, security audit, infrastructure, and a contingency buffer for
ADA price volatility.

### Article IV, Section 2 -- Fund Administration

> *Cardano Blockchain ecosystem budgets shall be administered by one or more
> budget administrators or administrators selected through a transparent
> process.*

**Assessment: COMPLIANT.**
Funds are administered through audited SundaeSwap treasury and vendor smart
contracts, with an independent oversight board serving as the budget
administrator. The board is composed of PRAGMA-adjacent individuals who are not
direct Blink Labs stakeholders. The permission scheme, disbursement schedule,
and oversight mechanisms are fully specified in Section 5 of this proposal. The
board has emergency halt authority and dispute resolution responsibility.

### Article IV, Section 3 -- Net Change Limit

> *The Net Change Limit shall be observed by all treasury withdrawals during the
> applicable budget period.*

**Assessment: COMPLIANT.**
This proposal does not violate the active Net Change Limit at the time of
submission. We are committed to operating within whatever NCL is in effect during
the proposal's governance action lifecycle.

If no Net Change Limit is in effect at the time this governance action is
evaluated, we propose the following as a suggestive framework: the total
withdrawal should not exceed $PLACEHOLDER ADA, and the proposal should be
evaluated on its individual merits against the total available treasury balance
and other pending withdrawal requests. This fallback clause is offered as
optional guidance and is not intended to substitute for a properly enacted NCL.

### Article IV, Section 4 -- Auditor

> *An independent audit of all transactions funded from the Cardano treasury
> shall be possible.*

**Assessment: COMPLIANT.**
All treasury transactions are recorded in a public transaction journal with full
provenance (transaction hashes, on-chain metadata hashes, amounts, signers, and
justifications). The SundaeSwap smart contracts provide on-chain enforcement of
fund flows. Any community member, constitutional committee member, or
independent auditor can verify every disbursement against the on-chain record.
Quarterly financial reports with detailed category-level spending are published
publicly.

### Guardrail TREASURY-04a

> *Treasury withdrawals for budget proposals require greater than 50% of DRep
> active voting stake to vote Yes.*

**Assessment: ACKNOWLEDGED.**
This governance action requires a majority of DRep active voting stake (>50%)
to pass. Blink Labs is conducting active DRep outreach, community engagement,
and AMA sessions to ensure that voting delegates have full information about
the proposal's merits, deliverables, and accountability mechanisms. Our
community engagement plan is detailed below.

---

## 8. Scope of Work

The following scope covers twelve months of development, organized into four
quarters. Each quarter defines concrete deliverables that map to the vendor
contract milestone schedule. All work is performed on the existing
[Dingo](https://github.com/blinklabs-io/dingo),
[gOuroboros](https://github.com/blinklabs-io/gouroboros), and
[Plutigo](https://github.com/blinklabs-io/plutigo) codebases and released under
Apache 2.0.

**Current baseline:** Dingo today is a functional Cardano node with block
production, VRF/KES key operations, 314 passing Amaru conformance tests, Plutus
V1--V3 evaluation at 100% conformance, mempool management, governance transaction
processing, peer-to-peer networking, and multiple storage backends (Badger for
block data, SQLite for metadata). It syncs from genesis and processes all eras
from Byron through Conway.

### Q1: Consensus Completeness and Operational Hardening Kickoff

**Objective:** Complete the Ouroboros Praos consensus implementation to the point
where Dingo can participate in block production on a test network, and begin the
operational hardening work needed for long-running stability.

**Deliverables:**

- **Full Ouroboros Praos consensus.** Complete epoch transition logic, slot
  leader election verification, chain selection rules, and the remaining
  consensus-layer behaviors required for a node to produce and validate blocks
  as a full network participant.
- **Hard fork combinator.** Implement the protocol version negotiation and era
  transition logic that allows Dingo to handle hard forks without restart.
- **Genesis bootstrap.** Implement the Ouroboros Genesis bootstrap mechanism for
  nodes joining the network from scratch, including peer selection and chain
  validation during initial sync.
- **Sync stability.** Achieve stable, uninterrupted chain sync from genesis to
  tip on both preview and preprod testnets, including graceful handling of
  network interruptions, peer disconnections, and chain rollbacks.
- **Operational hardening kickoff.** Begin profiling Dingo under realistic
  workloads: identify memory leaks, optimize hot paths, and establish
  performance baselines for mainnet-scale operation.
- **Conformance test expansion.** Expand the test suite beyond the current 314
  Amaru conformance vectors to cover consensus-specific behaviors, epoch
  boundaries, and edge cases specific to block production.

### Q2: Dijkstra Hard Fork Readiness and Storage Scalability

**Objective:** Achieve full readiness for the Dijkstra hard fork, including
Plutus V4 support, and address the known storage scalability risks at mainnet
data volumes.

**Deliverables:**

- **Dijkstra protocol changes.** Implement all ledger rule changes, new
  protocol parameters, and governance modifications introduced by the Dijkstra
  hard fork. Dingo must be able to process Dijkstra-era blocks immediately
  upon hard fork enactment.
- **Plutigo V4.** Extend the Plutigo Plutus evaluation engine to support
  Plutus V4, including new built-in functions, updated cost models, and any
  changes to the UPLC evaluator introduced by Dijkstra.
- **Storage scalability.** Address the known risk that Dingo's current storage
  backends (Badger for block/blob data, SQLite for metadata) have not been
  tested at mainnet scale (~100 million UTxOs, ~500 GB chain history). This
  includes benchmarking at scale, identifying bottlenecks, and implementing
  necessary optimizations or backend migrations.
- **UTxO set management.** Implement or optimize the in-memory and on-disk
  UTxO set to handle mainnet cardinality with acceptable lookup latency and
  memory footprint.
- **Cross-node validation.** Establish automated parallel execution against the
  Haskell reference node, comparing outputs block-by-block to detect
  discrepancies in ledger state computation.

### Q3: Leios Prototype and Mainnet-Scale Testing

**Objective:** Deliver a working Leios protocol implementation on a test network,
execute comprehensive testing at mainnet data volumes, and begin the security
audit.

**Deliverables:**

- **Leios protocol implementation.** Implement the Leios input-endorsement
  protocol in Dingo, developed in collaboration with IOG's research team. This
  includes the new mini-protocols, transaction parallelism, endorser block
  handling, and the consensus changes required for Leios operation. The
  implementation tracks the evolving Leios specification and surfaces
  ambiguities back to the research team.
- **Mainnet-scale testing.** Execute Dingo against a full mainnet-equivalent
  dataset: ~100 million UTxOs, ~500 GB chain, realistic transaction volumes.
  Validate sync performance, steady-state resource consumption, block
  production under load, and crash recovery.
- **Long-running stability.** Demonstrate that Dingo can run continuously for
  weeks without degradation: no memory leaks, no database corruption, no
  gradual performance decline.
- **Security audit kickoff.** Engage a major security firm (e.g., Trail of
  Bits, NCC Group, or equivalent) to begin a comprehensive audit of the Dingo
  codebase, focusing on consensus correctness, cryptographic operations,
  network protocol handling, and denial-of-service resistance.
- **Missing mini-protocols.** Implement remaining Node-to-Client
  mini-protocols and complete the LocalStateQuery interface to achieve
  protocol-level feature parity with the Haskell node for downstream tooling
  compatibility.

### Q4: Mainnet Readiness, Audit Completion, and Ecosystem Integration

**Objective:** Complete the security audit, achieve mainnet block-production
readiness, and deliver the ecosystem integration work that makes Dingo
practically usable for SPOs and application developers.

**Deliverables:**

- **Security audit completion.** Receive and address all findings from the
  security audit. Critical and high-severity findings are resolved before any
  mainnet block production recommendation. The full audit report is published
  publicly.
- **Mainnet block production readiness.** Dingo is capable of producing blocks
  on Cardano mainnet. This is the culmination of the consensus completeness,
  operational hardening, and security audit work streams. "Ready" means: tested
  at mainnet scale, audited, stable under long-running operation, and capable
  of performing all duties of a stake pool block-producing node.
- **Ecosystem integration.** Deliver tooling and compatibility layers that make
  Dingo practically useful to SPOs and developers:
  - SPO operational tooling (key management, KES rotation, operational
    certificate handling)
  - db-sync compatibility layer or equivalent chain indexing interface
  - API surface parity for common downstream tools (wallets, explorers,
    dApps)
- **Mithril integration.** Implement Mithril snapshot support for fast node
  bootstrapping, reducing initial sync time from hours to minutes.
- **Documentation.** Comprehensive operator documentation for running Dingo
  as a block-producing node, including deployment guides, configuration
  references, monitoring setup, and troubleshooting procedures.
- **P2P networking hardening.** Finalize peer-to-peer networking for production
  use, including peer discovery, connection management, and network topology
  optimization.

---

## 9. Conclusion

Dingo is not a speculative project. It is a functional Cardano node with over
300 merged pull requests, 314 passing conformance tests, Plutus evaluation at
100% across three script versions, and active block production capabilities.
The work described in this proposal takes Dingo from this already-advanced state
to full mainnet production readiness -- a genuine second node implementation
that strengthens Cardano's resilience, expands its developer ecosystem, and
positions the network for next-generation protocol evolution through Leios.

We acknowledge the risks. Storage scalability at mainnet volumes is a known
challenge. The Leios specification is still evolving. A comprehensive security
audit may surface findings that require significant remediation. ADA price
volatility between approval and expenditure introduces financial uncertainty.
We have addressed these risks through dedicated scope (storage scalability is a
funded deliverable, not an afterthought), direct collaboration with IOG's
research team (Leios), a meaningful contingency buffer (approximately 40%), and
a robust smart contract escrow with independent oversight.

**What success looks like at the end of twelve months:**

- Dingo produces blocks on Cardano mainnet, audited and operationally hardened.
- Stake pool operators can choose to run Dingo as an alternative or failover
  block producer, giving the network genuine implementation diversity.
- The Dijkstra hard fork is fully supported from day one.
- A working Leios implementation exists in Go, developed alongside the Haskell
  reference, strengthening the specification and accelerating Cardano's
  scalability roadmap.
- A comprehensive security audit report is publicly available.
- Every dollar of treasury funds is accounted for in a public transaction
  journal, verified on-chain, and reviewed by an independent oversight board.

Cardano's long-term resilience depends on having more than one team capable of
implementing its protocols. Blink Labs has spent years building the Go
infrastructure to make that possible. This proposal is the investment that
turns that foundation into a production reality.

---

## Community Engagement Plan

Blink Labs is committed to full transparency and active community engagement
throughout the proposal lifecycle and, if approved, the twelve-month development
period. Christina Gianelloni, COO, leads all community engagement efforts so
that the engineering team remains focused on delivering code.

- **Cardano Forum:** Dedicated proposal discussion thread for community
  questions, feedback, and debate.
- **GovTool:** Proposal published with full metadata for DRep review and
  voting.
- **DRep Outreach:** Direct engagement with active DReps to present the
  proposal, answer questions, and address concerns.
- **AMA Sessions:** Scheduled Ask-Me-Anything sessions where the community
  can question the Blink Labs team about technical details, budget, and
  timelines.
- **X/Twitter:** Regular updates on development progress, milestone
  achievements, and community discussions.
- **Live Coding Sessions:** Periodic public coding sessions demonstrating
  active Dingo development, giving the community direct visibility into the
  engineering work.

If this proposal does not pass on the first submission, we will incorporate
community feedback, refine the proposal where appropriate, and resubmit. We
believe the work speaks for itself, and we are committed to earning the
community's support through transparency and demonstrated competence.

---

*All software funded by this proposal is released under the Apache 2.0 license.
The full proposal, metadata, transaction journal, and all supporting documents
are maintained in the public
[treasury-proposal repository](https://github.com/blinklabs-io/treasury-proposal).*
