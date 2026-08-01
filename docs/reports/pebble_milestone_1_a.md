# Milestone 1.A — Pebble Type System

**Milestone:** 1.A (Q2 2026) — Pebble Type System
**Report date:** 2026-08-01
**Compiler version delivered:** `@harmoniclabs/pebble` **0.4.3** (published to npm 2026-07-31)

## Acceptance criteria status

| # | Acceptance criterion | Status |
|---|---|---|
| 1 | Pebble has a new version with the specified features (full inference, sum types, generics, namespaces) released on npm | **Met** — 0.4.3 published 2026-07-31 |
| 2 | ≥3 example contracts of meaningful complexity committed to the Pebble repo, compiling end-to-end to UPLC | **Met** — `examples/` committed; see §2 |
| 3 | Those contracts execute successfully on a current preview/preprod node, with a committed log or tx link | **Met** — 10 preprod transactions, all `valid_contract: true`, plus the third example live on mainnet at [thecardanomasterpiece.com](https://thecardanomasterpiece.com); see §4 |

**All three acceptance criteria are met.**

## Released packages

| package | version | published | notes |
|---|---|---|---|
| `@harmoniclabs/pebble` | 0.4.3 | 2026-07-31 | the compiler |
| `@harmoniclabs/pebble-cli` | 0.4.3 | 2026-07-31 | pins `@harmoniclabs/pebble@0.4.3`, so `npm i -g @harmoniclabs/pebble-cli` delivers this compiler |

Everything reported below was verified against the **published** 0.4.3 tarball
installed fresh from npm, not against a local working tree.

---

## 1. Type system — what was delivered

### Sum types

Multi-constructor structs in both the `data` (constr) and `runtime` (sum-of-products)
encodings, with flow-sensitive narrowing, `match` statements and `case` expressions,
and compile-time exhaustiveness checking on both.

Delivered in this milestone:

- **Recursive struct definitions** — `data struct L { Nil{} Cons{ h: int, t: L } }`.
  Lists, trees and mutually recursive pairs, walked by recursive functions.
- **Exhaustiveness enforced on `case` expressions**, not only `match` statements.
- Arm types are joined; incompatible arms are rejected.

### Generics

- **Generic struct declarations**, both encodings, including generic
  multi-constructor sum types — so `Result<T,E>` and friends are expressible.
- **Generic type aliases.**
- **Generic functions** with monomorphization, generic containers in signatures
  (`List<T>`, `Optional<T>`), and **generic recursive types** (`L2<T>`, `Tr<T>`).
- **Function types in parameter annotations** (`f: (a: A) => B`), which makes
  user-written higher-order functions — `map`, `filter`, `fold` — possible.
- **Constraint-based dispatch**: `<T implements I>` resolves the interface method
  at each instantiation, for both prelude and user-defined interfaces.

### Namespaces / modules

Nested namespaces, `private` members, `using { x } = M`, `using m = M`,
`export namespace`, `import * as`, a recursive dependency graph with cycle
detection, and — added in this milestone — **re-exports** (`export * from`,
`export { x } from`) and construction through a qualified namespace path
(`M.S.C{ … }`).

### Type inference

Pebble 0.4.3 provides bidirectional checking with local inference:

- `const` / `let` types inferred from initializers;
- function **return** types inferred from bodies, including returns nested inside
  `if` / `match` / loop bodies;
- lambda parameter types inferred from the expected callback signature;
- generic type arguments inferred at call sites by structural unification of the
  argument types — containers, function types, and generic structs/aliases
  (e.g. `unbox( b )` on a `Box<int>` binds `T = int`).

Function **parameter** annotations are always required; there is no global
Hindley–Milner-style inference. See "Documented limitations" below.

---

## 2. Example contracts

`examples/` in the Pebble repo holds three examples in increasing order of
complexity, each compiling end-to-end to on-chain UPLC.

| example | source | size | demonstrates |
|---|---|---|---|
| `linear-vesting` | 105 lines | 921 B | datum state carried across partial spends; reading the validity interval's **lower** bound |
| `two-party-escrow` | 96 lines | 782 B | contract `param`s; three redeemer endpoints; reading **both** bounds; payment tagging against double satisfaction |
| `the-cardano-masterpiece` | ~1080 lines | — | **contracts that compose** — live on mainnet at [thecardanomasterpiece.com](https://thecardanomasterpiece.com) |

The first two are committed as source in the Pebble repo. The third is a **git
submodule** tracking
[github.com/HarmonicLabs/the-cardano-masterpiece](https://github.com/HarmonicLabs/the-cardano-masterpiece),
pinned at commit `9b10fa17`, so `git clone --recurse-submodules` (or
`git submodule update --init`) reproduces all three from the Pebble repo alone.

**Linear vesting** vests funds continuously —
`vested(t) = total * (t - start) / (end - start)`, clamped — rather than
unlocking in one step. Partial claims are allowed, and any withdrawal that
leaves value behind must return it under the same schedule with `claimed`
advanced by exactly the amount taken. `claimed` lives in the datum rather than
being derived from the remaining balance, so topping the UTxO up cannot inflate
the entitlement.

**Two-party escrow** locks `price` lovelace for a named seller, with `accept`,
`refund` and `settle` endpoints. Each endpoint reads the interval bound that
cannot be gamed — `accept` the upper, `refund` the lower — so a wide validity
interval cannot satisfy both. The payment output is tagged with the spent
escrow's own `TxOutRef`, so one payment can never discharge two escrows.

**the-cardano-masterpiece** is included for the one thing a single validator
cannot show: parameterisation by another script's hash, cross-script
authorisation via reference inputs, and a single transaction that satisfies two
validators at once. It is not a demo — it is live on mainnet and backs the
public site **<https://thecardanomasterpiece.com>** (§4).

Each example ships **off-chain code built on `@harmoniclabs/buildooor`** —
datum/redeemer encoders, transaction builders, and a runnable end-to-end flow.

---

## 3. Verification

The type system was verified by an **internal audit** — conducted within the
project, not by a third party. No external security review was commissioned for
this milestone, and the acceptance criteria do not ask for one; this section
describes what was done so the evidence can be weighed accordingly.

The method is what gives it force: every check asserts **evaluated results**.
Each program is compiled to UPLC, run on the CEK machine, and the runtime value
is compared against an expected value. This matters because the defect class
that dominated this milestone (see §5) consists of programs that type-check
cleanly and produce wrong or broken UPLC — so a green `check()` is not evidence
of anything, and an audit that only collected diagnostics would have found none
of the three silent miscompiles.

The audit scripts are committed in the Pebble repo under `bug-repros/` and are
re-runnable by anyone against the published compiler (see "Reproducing" below),
so the findings can be checked without taking this report's word for them.

| evidence | result |
|---|---|
| Compiler test suite | **810 passing**, 0 failing (12 skipped, 5 todo, 126 suites) |
| Field-type × encoding sweep | **50 / 50** |
| Contract / state / redeemer shape sweep | **16 / 16** |
| Feature-interaction sweep | **17 / 18** (the 1 non-pass is a declared limitation, §6) |
| Vesting arithmetic property test | **414 / 414** inputs match a separately written reference |
| Example contracts on a local devnet | both flows **PASS**, including every negative case |
| Example contracts on **preprod** | **10 transactions**, all `valid_contract: true` (§4) |
| Regression: 4 production contracts | compile cleanly, **reproducible** byte-for-byte from the published compiler |

### Example contracts executed on chain

Both self-contained examples were run end-to-end against a local 3-node devnet
at protocol version 11 with the full 350-parameter PlutusV3 cost model,
submitting real transactions through `cardano-cli` and having the node validate
them. The negative cases matter as much as the positive ones — in each, the
transaction was built successfully and the **script** rejected it in phase 2:

- **Linear vesting** — lock 100 ADA; a partial claim mid-window succeeds and
  writes the correct continuation datum (verified by reading it back off chain);
  **an over-claim is rejected**; the remainder is claimable once the window
  closes.
- **Two-party escrow** — accept before the deadline succeeds while **refund
  before it is rejected**; after the deadline refund succeeds while **accept is
  rejected**; mutual settlement splits the funds.

Separately, the vesting formula — nested conditionals plus truncating integer
division — was property-tested against a separately written reference implementation
across 414 inputs covering every boundary (before `start`, exactly `start`,
`start + 1`, midpoints, `end - 1`, exactly `end`, past `end`, and negative). All
414 agree, confirming that the on-chain and off-chain arithmetic do not drift.

The regression check compiles the four `the-cardano-masterpiece` validators — real
contracts that are deployed and executing on Cardano mainnet — using the compiler
installed from the published npm tarball, and compares SHA-256 against the
maintainer's committed build artifacts. All four match exactly, so **0.4.3 is a
reproducible build**: an independent party can install 0.4.3, compile the sources,
and obtain the identical script bytes.

The compiled output is **smaller than the 0.4.1-era builds currently deployed on
mainnet**, reflecting the codegen fixes made during this milestone:

| contract | 0.4.1 (deployed) | 0.4.3 | delta |
|---|---|---|---|
| stewardship | 5835 B | 5404 B | −431 B |
| masterpiece | 5354 B | 4835 B | −519 B |
| marketplace | 3202 B | 3059 B | −143 B |
| lock | 87 B | 87 B | — |

This is expected and not a defect, but it has an operational consequence worth
recording: recompiling an existing contract with 0.4.3 yields **different script
bytes and therefore a different script address**. Already-deployed scripts are
unaffected — they remain on chain exactly as compiled — but any redeployment must
treat the resulting addresses as new.

Three separate sweep axes were run — field types × encodings, real validator
shapes (contracts, states, redeemers, prelude types as fields), and interactions
between features that were implemented separately (generics × recursion × HOFs ×
interfaces × namespaces × imports). The first two axes each found defects on
their first run; the third found none.

The field-type matrix has since been ported into the compiler test suite as
`compiler.structFieldRoundTrip.test.ts`, so the property is now enforced by CI
rather than by running a script.

Writing the two example contracts (§2) amounted to a fourth exercise, on the
axis of ordinary contract authoring rather than compiler probing. Both compiled
on the first attempt with no diagnostics, and every defect encountered while
getting the end-to-end flows working was in the off-chain code, not the
compiler. That is a useful signal after the earlier axes, though a narrow one:
two contracts of conventional shape is evidence about the common path, not proof
of absence.

### Reproducing

```bash
# compiler audit
npm i @harmoniclabs/pebble@0.4.3
# audit scripts live in the Pebble repo under bug-repros/
node bug-repros/audit-field-matrix.mjs
node bug-repros/audit-axis2-contracts.mjs
node bug-repros/audit-axis3-interactions.mjs

# example contracts (Pebble repo, examples/)
npm install
npm run compile                      # both contracts -> out/out.flat
bash devnet/bootstrap-devnet.sh      # 3-node PV11 devnet, ~4 min
npm run e2e                          # submits real transactions, asserts results
```

Running the flows needs `cardano-node`, `cardano-cli` and `cardano-testnet` on
PATH. `PEBBLE_DEVNET=/path/to/.devnet/data` points them at an existing devnet
instead.

---

## 4. On-chain execution evidence

All three examples have committed on-chain evidence, satisfying acceptance
criterion 3: the two self-contained examples were executed end-to-end on the
**public preprod network**, and the third is live on **mainnet**.

Full details — explorer links, script addresses and the compiled-artifact
SHA-256s — are committed in the **Pebble repo** (a different repository from
this one) at `examples/onchain-evidence/DEPLOYMENTS.md`, published at
[github.com/HarmonicLabs/pebble/blob/main/examples/onchain-evidence/DEPLOYMENTS.md](https://github.com/HarmonicLabs/pebble/blob/main/examples/onchain-evidence/DEPLOYMENTS.md),
with machine-readable JSON records alongside it. Every hash below is reproduced
in this report, so the report stands on its own if that link moves.

**10 transactions, every one confirmed with `valid_contract: true`** — the
ledger's own attestation that it ran the Plutus script in phase 2 and the script
succeeded.

### Linear vesting — script `ded0247d…`, address `addr_test1wr0dqfra7j9eayyxek4j5mvkhy3926k5cl3dwvqwsq5lx4spr75rj`

100 ADA vesting over an 8-minute window.

| step | transaction | block |
|---|---|---|
| lock | `38bc75ea88395c3d7f3ffaacd209a94bc3342baea647b3af4e7a7396744dec20` | 5001171 |
| partial claim (41 ADA) | `145536208765f639db6c1b5dec90c2e63397f16db0eb79f03a8f8e7b196b676d` | 5001184 |
| final claim (58 ADA) | `3b5a0aa49fb6d550f2729c6efaa52c0ab6ba5eac5f9fbe23fb3d5d94782c320e` | 5001197 |

The partial claim's continuation datum was read back from chain and matched the
expected `claimed` value exactly. An **over-claim was rejected by the validator**.

### Two-party escrow — script `941f4646…`, address `addr_test1wz2p73jx5htmk4w9qrytjgft2s22f8qsg0yyd3tpu7ww35gpw3eq0`

Parameterised with a buyer, a **distinct** seller wallet, and a 75 ADA price —
the price from the UPLC-CAPE two-party-escrow scenario.

| step | transaction | block |
|---|---|---|
| seller funding | `c66f26dc621eb0ea6529e4ccd9a2d19a0133d01dc995878b945488632a6989e6` | 5001204 |
| A — deposit | `ea45bdd7fda59da2e8621f1abf7fb7dd5811474a01cfdb976d7dc7feaaf4fd00` | 5001205 |
| A — accept (before deadline) | `cc7ebe90b4df4dd18110729ce83cda2fc1eafc5a66f88777f3ab4c3953108b11` | 5001206 |
| B — deposit | `c6b92caf00d0f617f315e6accf5d2dfcdedd97c6064d53598cb34edf55dcef54` | 5001207 |
| B — refund (after deadline) | `4c7ab60fbad22ed3c5c7dd00a74b3402ae0bfe58cbe9d9f9362a884f59ddb7b8` | 5001221 |
| C — deposit | `76f40e7e7bea41df6cbf7cc373fc7c45b50ee00e825301db5a28ad384fe80c85` | 5001223 |
| C — settle (both signatures) | `a185b03f8b74460a29c7c7c0cd445917e921c77c69d7e240b98edac0d28495c6` | 5001224 |

Both time guards were confirmed to bind: a **refund before the deadline** and an
**accept after the deadline** were each rejected by the validator.

### the-cardano-masterpiece — mainnet

The third example is not a test deployment. Its three interacting validators are
live on **Cardano mainnet**, re-verified against Koios on 2026-08-01.

| contract | reference-script deployment | block |
|---|---|---|
| stewardship | `0db69e21cf87aee3db69947c2424cff18aa9b1a7a0edda8a36947794d3c0e6d4` | 13728953 |
| masterpiece | `40f95cacb59118e12e34488f036df90e723945985b8052d563e6611c4273ba12` | 13728954 |
| marketplace | `6a9b8b6bf201e5d27f820852b81ede460891505fd694805b6a21ea474d419a57` | 13728958 |

A deployment transaction only proves a script was published, so the live state
matters more: tokens exist under both mint policies that **only the validators
could have created**, and the three script addresses hold spendable state —
masterpiece 85 UTxOs (~4650 ADA), stewardship 6, marketplace 5.

**The most direct evidence is that these contracts back a working public
product: <https://thecardanomasterpiece.com>.** A reviewer can simply open it.
The site is a thin client over mainnet, and publishes what it reads:
[`/api/state`](https://thecardanomasterpiece.com/api/state) reports live
validator state and [`/bf/blocks/latest`](https://thecardanomasterpiece.com/bf/blocks/latest)
the chain tip it is reading from. As of 2026-08-01 it shows **84 of 84 leaves
hatched, 0 unhatched** — each one required a successful `Nursery.hatch` spend,
so that count is a direct tally of validator executions — against the same
policy IDs and address verified above.

One result is worth singling out. `masterpiece.pebble` recomputes the
**whole-image IPFS CIDv1 on chain**, in Pebble, so the CIP-68 `image` field is
provably the canvas rather than an off-chain indexer's claim. The committed URI
`ipfs://bafybeidoy3mwz4jrbsvubvafndykruuun3rqpdydmbckdyebisg5krvkyi` resolves on
independent public gateways to a **1,017,142-byte `image/bmp`** — and 1008 × 1008
pixels at 8 bits plus a 1078-byte BMP header and palette is exactly 1,017,142
bytes. A hash computed by a Pebble validator addresses precisely the artifact
the contract's own geometry predicts.

This is stronger evidence than the criterion asks for, since it is mainnet
rather than a testnet, but it is recorded alongside the preprod runs so a
reviewer can check all three examples the same way.

### On the negative cases

The rejections are as much a part of the evidence as the successes — a contract
that accepts everything would also produce a clean list of confirmed
transactions. In each case the transaction was constructed normally and the
Plutus script failed during evaluation, so it was never submitted. That is the
correct outcome: a validator that lets an over-claim or an out-of-window
settlement through would be the defect.

### Verifying independently

```bash
curl https://cardano-preprod.blockfrost.io/api/v0/txs/<hash>   # valid_contract: true
# or open https://preprod.cardanoscan.io/transaction/<hash>
```

---

## 5. Defects found and fixed

The internal audit (§3) opened 22 numbered findings (BUGs 27–48) against the
0.4.1 baseline. All are resolved: 21 fixed, 1 (BUG 35) determined not to be a defect. Full
technical detail, with repros and root causes, is in `PEBBLE_BUGS.md` in the
Pebble repo.

**Three were silent miscompiles** — programs that type-checked cleanly and
produced wrong on-chain code. This is the category that can put a broken
validator on chain, and it is the reason the audit asserts evaluated values:

| # | Defect | Impact |
|---|---|---|
| 27 | SoP struct literals always emitted constructor 0 | matching a non-first variant silently ran the **wrong branch** |
| 41 | `data struct` with a `List<…>` field | broken UPLC at runtime (`mkCons :: incongruent list types`) |
| 42 | multi-ctor `runtime struct` with an `Optional<…>` field | broken UPLC at runtime (`unIData :: not data value`) |

The remainder were compile-time crashes, missing features, or diagnostics that
pointed at the wrong construct. Notable among them: `List.map` was unusable with
any lambda (BUG 39); generic structs, aliases and interfaces crashed the compiler
with uncaught internal errors rather than diagnostics (BUG 31); and
`Compiler.export()` discarded diagnostics, which had made a large share of the
test suite vacuous (BUG 30) — fixing that one first was what made the subsequent
fixes verifiable.

---

## 6. Follow-ups — not blocking this milestone

All three acceptance criteria are met. The items below improve durability and
presentation; none is a prerequisite for sign-off, and none depends on further
changes to 0.4.3.

### CI for the examples

Add a job that compiles every contract under `examples/`. Four of the five
documented on-chain snippets silently rotted earlier in this milestone
(`signatories` → `requiredSigners`, the `match` expression form, `state` in a
stateless method) precisely because nothing compiled them. The examples are now
the most visible Pebble code in the repo and should not be able to rot the same
way.

Running the end-to-end flows in CI additionally requires `cardano-node`,
`cardano-cli` and `cardano-testnet` on PATH plus roughly four minutes to
bootstrap the devnet, so it is reasonable to gate the compile step on every push
and the devnet step on a schedule or a label.
