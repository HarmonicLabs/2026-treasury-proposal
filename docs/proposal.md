# Dingo: a Production-Grade Block Producer in Go by Blink Labs

## 1. Abstract

Blink Labs is requesting 6,900,000 ADA from the Cardano Treasury to fund
twelve months of full-time engineering on
[Dingo](https://github.com/blinklabs-io/dingo), our Go Cardano node. Dingo
is a work in progress, and that's the whole point of this proposal. But it's
a substantial one: 1,290+ non-dependency PRs merged in the past year,
Plutus V1/V2/V3 at 100% conformance against the Plutus test suite, 314
passing conformance tests, VRF/KES crypto, ChainSync, mempool, and
governance transaction support. This
funding gets Dingo the rest of the way to mainnet block-production
readiness: Ouroboros Praos consensus completion, Dijkstra hard fork support,
CIP-0164 Linear Leios built alongside IO Engineering, a proper
security audit, and the operational hardening that makes a node reliable at
scale.

---

## 2. Motivation: Who We Are

### Blink Labs

We're a small engineering company focused exclusively on blockchain
software integrated with Cardano. We build in Go because it's the right
language for high-performance networked systems, and because Cardano
benefits from
having core infrastructure that millions of developers can actually read
and work on. Our team includes a part-time documentation engineer
and six part-time Paid Open Source Contributors who help maintain and
expand the ecosystem.

We've been building on Cardano since 2021. Here's what we've shipped:

| Project | Description | Maturity |
|---------|-------------|----------|
| [Dingo](https://github.com/blinklabs-io/dingo) | Our Go Cardano node: ChainSync, VRF/KES block forging primitives, Plutus evaluation, mempool, governance, UTxO RPC, Mini-Blockfrost, and Mesh (Rosetta) APIs | Not mainnet-ready yet, but 300+ merged PRs, 314/314 conformance tests |
| [gOuroboros](https://github.com/blinklabs-io/gouroboros) | Ouroboros mini-protocol library with full era support from Byron through Conway | 2,200+ tests, used by downstream projects |
| [Plutigo](https://github.com/blinklabs-io/plutigo) | Our Plutus script evaluator: V1, V2, V3 at 100% conformance against the Plutus test suite | Integrated into Dingo |
| [ouroboros-mock](https://github.com/blinklabs-io/ouroboros-mock) | Conformance testing framework with 314 Amaru test vectors and ledger state mocking | Shared infrastructure |
| [Adder](https://github.com/blinklabs-io/adder) | Chain indexing and event notification pipeline with pluggable outputs | In production |
| [nview](https://github.com/blinklabs-io/nview) | Terminal-based node monitoring | Shipped |
| [TxSubmit API](https://github.com/blinklabs-io/tx-submit-api) | Transaction submission service | In production, Docker-based |
| Docker images | Cardano node and tooling containers | Widely adopted by SPOs |

Beyond our own projects, we co-maintain several Go libraries across the
Cardano ecosystem, including Apollo, Ogmigo, Kugo, and the UTxO RPC Go
SDK.

Our prior Cardano funding has come from Project Catalyst (which funded
gOuroboros development and initial Dingo work) and from self-funding.
We're PRAGMA members, but we haven't received any funds from Amaru's
treasury proposal or any other
treasury withdrawal despite our membership. This proposal stands on its
own.

### Key Personnel

- Chris Gianelloni, Lead Architect. Designed and leads development of
  Dingo, gOuroboros, and the broader Go infrastructure stack. Architecture
  decisions, protocol implementation, and technical direction.

- Christina Gianelloni, COO. Marketing, community outreach, DRep
  engagement, AMAs, social media, and governance communications. She keeps
  the non-engineering side running so the developers can focus.

---

## 3. Motivation: Why Dingo

### Node Diversity Is Network Resilience

Cardano runs on a single node implementation for block production. Every
block producer on the network runs the same code. A critical bug in one
place (consensus defect, memory leak under load, vulnerability in
production) hits all of them at once. There's no fallback.

Node diversity changes that. Amaru is building a Rust implementation, and
Dingo brings Go. Multiple independent implementations mean a bug in one
doesn't take down the whole network. Ethereum learned this the hard way.
Their multi-client architecture has saved them repeatedly when individual
clients hit bugs that would've been network-wide outages otherwise.

### Go Ecosystem Accessibility

Cardano's core infrastructure is written in Haskell. Go has over 5 million
active developers and ranks 7th on TIOBE. It's the language the industry
already chose for blockchain nodes: Geth (Ethereum), btcd (Bitcoin),
CometBFT (50+ Cosmos chains), AvalancheGo, Algorand, and Filecoin. A Go
Cardano node isn't novel. It's overdue.

Go is also the language of choice for major crypto infrastructure
providers. Coinbase built their Rosetta/Mesh blockchain integration
standard entirely in Go. Binance and Kraken both use Go as a core backend
language for their trading infrastructure. Most EVM chains ship Go clients
(Geth forks), which means exchanges and infrastructure providers
integrating with multiple chains have already built deep Go expertise. A
Go Cardano node reduces friction for integration and simplifies onboarding
for the companies Cardano most needs to attract.

Dingo opens Cardano's node internals to those 5 million+ developers.
Engineers at Google, Cloudflare, Docker can read this code, audit it, and
contribute to it without learning a new language. This isn't about
replacing Haskell. It's about making Cardano accessible to the developers
who are actually out there.

### Delivery Track Record and Cost Efficiency

We have a documented track record. Across Dingo, gOuroboros, and Plutigo,
we've merged 1,290 non-dependency PRs in the past twelve months, 593 in
the last quarter, accelerating. With 2-3 part-time engineers. That works
out to roughly 36 PRs per person per month, with 304,000+ lines of code
added.

These numbers are backward-looking, not promises. The work shifts from
protocol implementation to consensus hardening, which is different. But
the engineering culture that produced those numbers is the same culture
we're bringing to this proposal.

#### Development Discipline

We write small PRs, about 236 lines each. On purpose. Smaller PRs mean
faster review, lower merge risk, tighter feedback loops. It adds up:
304,000 lines of new code in twelve months.

#### Cost Efficiency

Personnel cost is $1,250,000 for five FTEs ($250,000 per FTE). The rest
is a one-time audit ($500,000), hosting ($50,000), and 15% contingency.
Other funded node implementations priced at $0.50/ADA during the 2025
cycle. At that same price, our $2,070,000 total is roughly 4,140,000 ADA.
We're not padding this.

### Scalability Through Leios

CIP-0164 Linear Leios is where Cardano gets its next major throughput
jump, 30-50x through a two-block-type architecture (Endorser Blocks and
Ranking Blocks) with sortition-based voting and certificates. We're already
working directly with IO Engineering on this, and Go's concurrency model
(goroutines and channels) is basically purpose-built for the kind of
pipeline concurrency Leios needs. Building it in Go alongside the Haskell
reference also strengthens the spec. You find ambiguities faster
when two teams implement the same protocol in two different languages.

### Sustainability Through Open Source

Everything we build is Apache 2.0. Always has been, always will be.
This work is a permanent public good. It doesn't go away if Blink Labs
does.

### What the Ecosystem Loses Without Funding

Without funding, Dingo continues on whatever time we can scrape together
from existing resources. Concretely:

- Block production limited to local devnet only. The consensus work for
  live networks doesn't get done.
- No SPO story. Pool operators can't run it as a block producer. Node
  diversity stays a talking point, not a reality.
- Dijkstra support will still happen, but on a slower timeline.
- Leios in Go limited to client-side only. The spec-strengthening
  benefits of a full second implementation don't materialize.
- No audit. That takes real money.

The Cardano community has already invested in this stack through Catalyst
and through years of our own time and money. Without this funding, that
investment doesn't reach its potential.

---

## 4. Rationale: Executive Summary of Costs

We're requesting a single treasury withdrawal to cover twelve months of
development. All amounts are in USD with ADA conversion at the time of the
governance action, plus a contingency buffer for price volatility.

| Category | Estimated Cost (USD) |
|----------|---------------------:|
| Engineering (4 FTE Go engineers x 12 months) | $1,000,000 |
| Operations (1 FTE x 12 months: infrastructure, COO, marketing & outreach) | $250,000 |
| Security Audit (major firm) | $500,000 |
| Infrastructure hosting & CI/CD | $50,000 |
| Subtotal | $1,800,000 |
| Contingency (~15% for scope uncertainty) | $270,000 |
| Total | $2,070,000 |

Requested Amount: 6,900,000 ADA (at $0.30/ADA)

### Notes on the Budget

- Engineering is the core cost: four full-time Go engineers for twelve
  months. The $250,000 per FTE is all-in: wages, benefits, and hardware.
  These are Blink Labs employees, not contractors. We'll need to hire three
  Go developers to reach full capacity, and may promote from our existing
  Paid Open Source Contributor team.

- Operations is split across an infrastructure engineer (CI/CD, testnet
  and mainnet node ops, deployment, monitoring) and the COO (marketing,
  community outreach, governance comms, DRep engagement, social media).
  The $50,000 infrastructure line is cloud hosting only; the human effort
  is under operations.

- Security audit is budgeted at about $500,000 for a thorough review by
  a major firm (Trail of Bits, NCC Group, or equivalent). Before we
  recommend anyone run Dingo as a block producer, we want someone to try
  to break it.

- ADA price basis. We're using $0.30/ADA because that's approximately
  what ADA costs right now. Other treasury-funded implementations priced
  at $0.50 during the 2025 cycle. At that price, our $2,070,000 would be
  roughly 4,140,000 ADA. We'd rather price honestly and let the numbers
  speak.

- Contingency is about 15%. The audit might find things that need fixing.
  Since we priced at near-market rather than $0.50, price volatility is
  less of a concern. Our hedge is converting to stablecoin or fiat upon
  receipt.

- Single withdrawal. Full amount in one treasury withdrawal, with
  milestones enforced by smart contract escrow and oversight board review
  (see Section 5).

### Effort Estimate and Capacity Buffer

We want to be upfront about how estimated work maps to funded capacity.
The following table shows our engineering assessment in engineer-months:

| Category | Estimated Effort |
|----------|----------------:|
| Mainnet block production | 6 |
| Dijkstra hard fork | 5 |
| CIP-0164 Linear Leios | 6 |
| Operational hardening | 6 |
| Feature parity | 8 |
| Ecosystem integration | 6 |
| **Total estimated work** | **37** |
| **Team capacity (4 engineers x 12 months)** | **48** |
| **Buffer** | **11 (25%)** |

Our measured velocity over the past year is about 36 non-dependency PRs per
person per month across Dingo, gOuroboros, and Plutigo, well above what
other Cardano node teams have shown. We've adjusted our estimates to
account for the shift from protocol implementation to the harder work of
consensus hardening and operational readiness.

#### Why the Buffer

Specs aren't done, the audit could surface serious findings, and Leios is a
moving target. If things go well, the extra capacity goes into
community-prioritized items. Unused ADA sweeps back to the treasury at
contract expiration. That's enforced at the contract level, not a promise.

---

## 5. Rationale: Administration of the Budget

### Smart Contract Escrow

Funds are held and released through the
[SundaeSwap treasury-contracts](https://github.com/SundaeSwap-finance/treasury-contracts),
a proven framework with two validators:

- treasury.ak: Holds all ADA withdrawn from the Cardano treasury.
  Everything gets locked here when the governance action is enacted.
- vendor.ak: Manages milestone-based vesting for Blink Labs. Payment
  schedule, payout dates, release conditions.

Both contracts have been independently audited by TxPipe and MLabs and are
in production use on mainnet.

### Blink Labs as Single Vendor

We're the sole vendor. All work comes from Blink Labs. No subcontractors.
If something isn't delivered, you know exactly who to hold accountable.

### Independent Oversight Board

An independent oversight board provides third-party governance:

- **Pi Lanningham** (SundaeSwap)
- **Santiago Carmuega** (TxPipe)
- **Lucas Rosa** (Aiken, Midnight)

Board members don't have a stake in Blink Labs. They co-sign
disbursements, review milestones, and can halt funding if we're not
delivering.

### Permission Scheme

We use a least-friction permission model: no bottlenecks, but real
oversight:

| Action | Required Signatures |
|--------|-------------------|
| Disburse (periodic release) | Blink Labs initiates + any 1 board member co-signs |
| Sweep early (return unused funds) | Blink Labs + any 1 board member |
| Reorganize (adjust milestone schedule) | Blink Labs only |
| Fund (initial vendor setup) | Board majority |
| Pause milestone | Any 1 board member |
| Resume milestone | Board majority |
| Modify project | Blink Labs + board majority |

Day-to-day operations need one board signature. Structural changes need the
full board. And any single member can hit pause if something looks off.

### Delegation Policy

The treasury contract enforces auto-abstain DRep delegation and no SPO
delegation for all funds in escrow. Treasury funds don't influence
governance votes or staking.

### Failsafe Sweep

Funds left in the contract after expiration automatically sweep back to the
Cardano treasury. Enforced at the contract level. Can't be overridden.

### Periodic Fixed Releases

Funds release on a fixed schedule in the vendor contract, subject to board
co-signature. Predictable cash flow for us, halt capability for the board.
The schedule aligns with quarterly milestones in Section 8.

---

## 6. Rationale: Reporting

### Monthly Lightweight Updates

End of each month, we publish a status update:

- What shipped
- Key PRs, features, milestones
- Risks or blockers
- What's next

Updates go to the
[treasury-proposal repository](https://github.com/blinklabs-io/treasury-proposal)
and community channels.

### Quarterly Detailed Reports

Each quarter, a full report:

- Progress against each milestone
- Financial summary: received, spent by category, remaining
- Variance analysis for budget deviations
- Updated risk register
- Next quarter's plan

Quarterly reports coincide with disbursement requests, giving the board
what they need to authorize releases.

### Public Transaction Journal

Every on-chain transaction (disbursements, claims, sweeps,
reorganizations) gets recorded in a public
[transaction journal](https://github.com/blinklabs-io/treasury-proposal/tree/main/journal).
Transaction hash, action type, amount, signers, justification, on-chain
metadata hash. SundaeSwap metadata standard. Anyone can verify against
the chain.

### Coding Sessions and Demos

We do periodic live coding sessions and demos so the community can see the
work firsthand. Active development, architectural decisions, Dingo
capabilities as they're built. Announced on X/Twitter and the Cardano
Forum, recorded for later.

---

## 7. Rationale: Constitutionality Checklist

This section checks the proposal against the Cardano Constitution (v2.4),
following the
[PRAGMA mnemos format](https://github.com/pragma-org/mnemos).

### Purpose

This proposal requests a treasury withdrawal to fund Dingo's development to
production readiness: a second full Cardano node capable of data service
and block production, with Dijkstra support and a Leios implementation.

### Article III, Section 5: On-Chain Governance Actions

> *Governance actions shall follow a standardized and legible format,
> including a URL and hash of any off-chain content.*

Assessment: COMPLIANT.

CIP-108 metadata. On-chain action references off-chain metadata via URL
(GitHub commit-hash pinned, IPFS mirror via Blockfrost) with blake2b-256
hash. Self-contained, human-readable, CIP-108 compliant.

### Article IV, Section 1: Budget for the Cardano Blockchain Ecosystem

> *A budget for the Cardano Blockchain ecosystem shall be adopted on an
> annual basis through an on-chain governance action.*

Assessment: COMPLIANT.

Twelve months (~73 epochs), aligned with the annual cycle. Budget fully
specified: engineering, audit, infrastructure, contingency.

### Article IV, Section 2: Fund Administration

> *Cardano Blockchain ecosystem budgets shall be administered by one or
> more budget administrators or administrators selected through a
> transparent process.*

Assessment: COMPLIANT.

Audited SundaeSwap smart contracts with an independent oversight board:
Pi Lanningham (SundaeSwap), Santiago Carmuega (TxPipe), and Lucas Rosa
(Aiken, Midnight). Board members are not Blink Labs stakeholders.
Permissions, disbursement schedule, and oversight fully specified.
Emergency halt and dispute resolution authority included.

### Article IV, Section 3: Net Change Limit

> *The Net Change Limit shall be observed by all treasury withdrawals
> during the applicable budget period.*

Assessment: COMPLIANT.

Doesn't violate the active NCL at submission. We'll operate within
whatever NCL is in effect.

If no NCL exists when this action is evaluated, we suggest: withdrawal
shouldn't exceed 6,900,000 ADA, evaluated on merits against treasury
balance and other requests. This is guidance, not a substitute for a
properly enacted NCL.

### Article IV, Section 4: Auditor

> *An independent audit of all transactions funded from the Cardano
> treasury shall be possible.*

Assessment: COMPLIANT.

Public transaction journal with full provenance: hashes, amounts, signers,
justifications. SundaeSwap contracts enforce fund flows on-chain. Anyone
can verify. Quarterly financials published with category-level detail.

### Guardrail TREASURY-04a

> *Treasury withdrawals for budget proposals require greater than 50% of
> DRep active voting stake to vote Yes.*

Assessment: ACKNOWLEDGED.

Requires >50% DRep active voting stake. We're doing active outreach,
community engagement, and AMAs so delegates have full information about
what we're building, what it costs, and how we're held accountable.

---

## 8. Scope of Work

Twelve months, four quarters, concrete deliverables mapped to vendor
contract milestones. All work on the existing
[Dingo](https://github.com/blinklabs-io/dingo),
[gOuroboros](https://github.com/blinklabs-io/gouroboros),
[Plutigo](https://github.com/blinklabs-io/plutigo), and
[ouroboros-mock](https://github.com/blinklabs-io/ouroboros-mock) codebases.
Apache 2.0.

#### Where We're Starting From

Dingo today syncs from genesis through all eras (Byron through Conway), has
VRF/KES block forging primitives, passes 314 Amaru conformance tests (via
the ouroboros-mock harness), evaluates Plutus V1/V2/V3 at 100%
conformance against the Plutus test suite, handles mempool management and
governance transactions, supports P2P
networking, and runs on multiple storage backends (Badger for blocks, SQLite
for metadata, in-memory for testing). What it can't do yet: produce blocks
in a live consensus environment. That's what Q2 is for.

### Q2: Testnet Block Production and Leios Prototype

#### Goal

Get Ouroboros Praos consensus complete enough for Dingo to produce blocks on
a test network, and begin the Leios prototype. This is the hardest quarter;
consensus is where the real complexity lives.

#### What We'll Deliver

- Full Ouroboros Praos consensus: epoch transitions, slot leader
  election verification, chain selection, and the remaining behaviors
  needed for Dingo to produce and validate blocks as a full participant.
- Hard fork combinator: protocol version negotiation and era
  transition so Dingo handles forks without restarting.
- Genesis bootstrap: the Ouroboros Genesis mechanism for nodes joining
  from scratch, including peer selection and chain validation during initial
  sync.
- Stable ChainSync from genesis to tip on preview and preprod.
  Graceful handling of interruptions, disconnections, rollbacks.
- CIP-0164 Linear Leios prototype, built with IO Engineering.
  Two-block-type architecture (Endorser Blocks, Ranking Blocks) with
  sortition-based voting and certificates for 30-50x throughput. New block
  types, serialization, vote validation, pipeline timing, mini-protocols
  for EB and vote diffusion. We track the spec and feed ambiguities back
  to the research team. That's half the value of a second implementation.
- Conformance test expansion beyond the current 314 vectors to cover
  consensus edge cases and epoch boundaries.

### Q3: Operational Hardening and Storage Scalability

#### Goal

Harden Dingo for long-running stability and address the known storage risks
at mainnet data volumes.

#### What We'll Deliver

- Operational hardening: profiling under realistic workloads. Find
  memory leaks, optimize hot paths, establish performance baselines.
- Storage scalability: our current backends (Badger, SQLite) haven't
  been tested at mainnet scale (~100M UTxOs, ~500 GB chain). Benchmarking,
  bottleneck identification, optimizations or migrations as needed.
- UTxO set management at mainnet cardinality: acceptable lookup
  latency and memory footprint.
- Mainnet-scale testing: Dingo against ~100M UTxOs, ~500 GB chain,
  realistic volumes. Sync, resource consumption, block production under
  load, crash recovery.
- Long-running stability: weeks of continuous operation. No leaks,
  no corruption, no degradation.
- Cross-node validation: automated parallel execution against the
  Haskell node, block-by-block comparison to catch ledger state
  discrepancies.
- Security audit kickoff with a major firm (Trail of Bits, NCC Group,
  or equivalent). Consensus correctness, crypto, network handling, DoS
  resistance.

### Q4: Dijkstra Hard Fork Readiness and Leios Integration

#### Goal

Achieve full Dijkstra readiness (including Plutus V4). Leios and Dijkstra
are expected to ship in the same hard fork, so the Q2 prototype work feeds
directly into final integration here.

#### What We'll Deliver

- Dijkstra protocol changes: ledger rules, new parameters, governance
  modifications. Dingo processes Dijkstra blocks the moment the fork
  happens.
- Plutigo V4: new builtins, updated cost models, any UPLC evaluator
  changes.
- Leios consensus integration: bringing the Q2 prototype to full
  integration with consensus and the Dijkstra protocol changes.
- Remaining mini-protocols: Node-to-Client gaps and LocalStateQuery
  completion for Haskell node feature parity. Downstream tools need this.

### Q1 2027: Mainnet Readiness, Audit Completion, and Ecosystem Integration

#### Goal

Finish the audit, hit mainnet readiness, and deliver the ecosystem work
that makes Dingo actually useful to people.

#### What We'll Deliver

- Security audit completion. All findings addressed. Critical and
  high-severity issues fixed before any mainnet recommendation. Full report
  published.
- Mainnet block production readiness. This is where it all comes
  together: consensus, hardening, audit. "Ready" means tested at scale,
  audited, stable, capable of everything an SPO needs.
- Ecosystem integration: the practical stuff: key management and KES
  rotation, db-sync compatibility or equivalent indexing, API parity for
  wallets, explorers, dApps.
- Mithril integration. Fast bootstrapping, sync in minutes instead of
  hours.
- Operator docs: deployment, configuration, monitoring,
  troubleshooting. The stuff you need to actually run this in production.
- P2P hardening: peer discovery, connection management, topology
  optimization.

---

## 9. Conclusion

Dingo is further along than most alternative node implementations get
before their first treasury ask: 300+ PRs, 314 passing conformance
tests, Plutus at 100% across three versions. But it's not mainnet-ready.
This proposal funds the work to get it there: consensus completion,
operational hardening, a proper audit, Dijkstra support, and Leios.

The risks are real. Storage at mainnet scale, an evolving Leios spec,
whatever the audit turns up. We've planned for those: dedicated scope,
IO Engineering collaboration, contingency, smart contract escrow,
independent oversight.

#### After Twelve Months

- Dingo produces blocks on mainnet.
- SPOs have a real alternative block producer.
- Dijkstra works from day one.
- Leios exists in Go alongside the Haskell reference.
- The audit report is public.
- Every ADA is accounted for on-chain.

We've spent years building this. This proposal is what turns it into
something the network can depend on.

---

## 10. Community Engagement Plan

We're committed to transparency and active community engagement throughout
the proposal lifecycle and the twelve-month development period. Christina
Gianelloni leads all community engagement and ops so the engineering team
stays focused on code.

- Cardano Forum: Dedicated proposal thread for questions, feedback, and
  debate.
- GovTool: Proposal published with full metadata for DRep review and
  voting.
- DRep Outreach: Direct engagement with active DReps to present the
  proposal, answer questions, and address concerns.
- AMA Sessions: Scheduled AMAs where the community can question us on
  technical details, budget, and timelines.
- X/Twitter: Regular updates on progress, milestones, and community
  discussions.
- Live Coding Sessions: Periodic public sessions demonstrating active
  Dingo development, giving the community direct visibility into the work.

If this doesn't pass the first time, we'll take the feedback, refine, and
resubmit. The work speaks for itself.

---

*All software is Apache 2.0. Everything is in the public
[treasury-proposal repository](https://github.com/blinklabs-io/treasury-proposal).*
