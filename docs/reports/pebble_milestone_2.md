# Milestone 2 - Pebble Language Completeness & Public Benchmarks

**Milestone:** 2, Pebble Language Completeness & Public Benchmarks (Q3 2026)
**Report date:** 2026-10-29 (first drafted 2026-09-07)
**Compiler version delivered:** `@harmoniclabs/pebble` and `@harmoniclabs/pebble-cli` 0.5.0, [GitHub release `v0.5.0`](https://github.com/HarmonicLabs/pebble/releases/tag/v0.5.0) (commit `4e0e403b`)

## Acceptance criteria status

| # | Acceptance criterion | Status |
|---|---|---|
| 1 | A new tagged Pebble release exists with the test framework, standard library additions, and Plutus V4 codegen (visible in release notes) | **Met**: tag `v0.5.0` and its [GitHub release](https://github.com/HarmonicLabs/pebble/releases/tag/v0.5.0), whose notes cover all three areas (sections 1 to 3). Published on npm on 2026-10-28: [`@harmoniclabs/pebble@0.5.0`](https://www.npmjs.com/package/@harmoniclabs/pebble/v/0.5.0) and [`@harmoniclabs/pebble-cli@0.5.0`](https://www.npmjs.com/package/@harmoniclabs/pebble-cli/v/0.5.0) |
| 2 | A Pebble contract compiled with the V4 codegen executes successfully on a Plutus V4 preview/preprod node (committed log or tx link) | **Met** on the only public Plutus V4 network, acceptance requested. A Pebble 0.5.0 contract compiled for Plutus V4 executed successfully on Musashi, the public Leios testnet running protocol version 12: unlock transaction [`e36e3e7a37d6ade13951d793c8646b17105ffafffc7acce7681a822ba2c6195c`](https://kleioscan.com/#/musashi/tx/e36e3e7a37d6ade13951d793c8646b17105ffafffc7acce7681a822ba2c6195c) (block 37057), [source](https://github.com/HarmonicLabs/pebble/blob/ffa20573d3eb81bc1ce22fee43b9964dd3a96af3/examples/plutus-v4-musashi/src/index.pebble), [evidence](https://github.com/HarmonicLabs/pebble/blob/ffa20573d3eb81bc1ce22fee43b9964dd3a96af3/examples/plutus-v4-musashi/onchain/EVIDENCE.md). A second Pebble V4 contract ([source](https://github.com/HarmonicLabs/pebble/blob/ffa20573d3eb81bc1ce22fee43b9964dd3a96af3/examples/plutus-v4-features/src/index.pebble)) then ran for each new V4 feature the current tooling can build (nested transactions, guards, account certificates, withdrawals, minting, direct deposits and account balance intervals), with every transaction hash listed in section 3 ([evidence](https://github.com/HarmonicLabs/pebble/blob/ffa20573d3eb81bc1ce22fee43b9964dd3a96af3/examples/plutus-v4-features/onchain/EVIDENCE.md)). Preview and preprod still run protocol version 11 and cannot execute V4 scripts (section 3) |
| 3 | Pebble appears in at least one new UPLC-CAPE category beyond Fibonacci/Factorial naive recursion on the live report | **Met** with a public, independently reproducible submission, acceptance requested. [IntersectMBO/UPLC-CAPE#263](https://github.com/IntersectMBO/UPLC-CAPE/pull/263) adds Pebble to three new categories (`fibonacci`, `factorial` and the real-world `two_party_escrow`), measured with the official tool, every test vector passing; anyone can rebuild the artifacts from the `v0.5.0` tag with the npm release and repeat the measurement ([steps](https://github.com/HarmonicLabs/pebble/blob/v0.5.0/examples/uplc-cape/README.md), section 4). The entries reach the live report when the maintainers merge #263 |
| 4 | The public benchmark write-up is published and linked from the Pebble README | **Met**: [`BENCHMARKS.md`](https://github.com/HarmonicLabs/pebble/blob/v0.5.0/BENCHMARKS.md), linked from the [README](https://github.com/HarmonicLabs/pebble/blob/v0.5.0/README.md) in the `v0.5.0` release; [current figures](https://github.com/HarmonicLabs/pebble/blob/90eac874956a5effe63e431c3c1d65f5da5e9de4/BENCHMARKS.md) (section 5) |

Note from the proposal's deliverable list: the namespaces / module system item was
already delivered and reported in Milestone 1.A (0.4.3); no new work was required.

---

## 1. Built-in test framework

`pebble test` was a working phase-1 runner at 0.4.x (unit tests, `assert`, per-test
cpu/mem budgets, seeded int/bool property fuzzers). 0.5.0 completes it:

- **Typed default fuzzers** for every practical parameter type: `bytes`, `string`,
  `data`, enums, `Optional<T>` (both encodings; SoP values are passed as UPLC 1.2
  `constr` terms), `List<T>`, `LinearMap<K,V>`, `Value`, data structs (inputs are
  generated from the struct's constructors and field types, so a multi-constructor
  datum exercises every branch), and runtime (SoP) structs. Generators are seeded,
  deterministic, and biased toward edge cases (0, 1, -1 and the integer bounds,
  empty and hash-length byte strings, empty and single-element collections).
- **`via <expr>` fuzzers** now run: the compiler builds a `( seed: int ) => T`
  entry point from the `via` expression, which can be a function of that shape or a
  plain `T` value used as a constant fuzzer (`via 42`), and the runner evaluates it
  on the CEK machine with a fresh seed per iteration.
- **Shrinking**: failing property inputs are minimized before reporting. Integers
  converge logarithmically to the smallest counterexample; byte strings, strings,
  lists and maps shrink structurally. The report shows both the original and the
  minimal failing tuple.
- **CI/machine output**: `pebble test --json` (full results including budgets) and
  `--bail`.
- **Used on the examples**: the `examples/linear-vesting` and
  `examples/two-party-escrow` projects ship property-test suites (vesting-math
  clamp/monotonicity, escrow time-window exclusivity) that run in the repository's
  CI on every push. This also closes the M1.A follow-up about compiling the
  examples in CI.

The test runner executes on the real CEK machine, including the
`@harmoniclabs/plutus-machine` 3.0.5 conformance fixes (the machine now halts
immediately on builtin errors instead of swallowing them; `case` over an errored
scrutinee propagates the underlying message), released as
[plutus-machine 3.0.5](https://github.com/HarmonicLabs/plutus-machine/releases/tag/v3.0.5),
which 0.5.0 requires.

## 2. Standard library for common dApp patterns

All additions ship with CEK round-trip tests and documentation:

- **Value arithmetic**: `negate`, `equals`, `subtract`, `isZero`, `geq`, `leq` as
  `Value` methods and under `std.value`, plus `std.value.singleton`,
  `std.value.assetClass`, `Value.amountOfAsset`, the `AssetClass` prelude struct
  and the `POSIXTime` alias.
- **Script-context helpers** for the checks validators wrote by hand until now,
  as methods and under `std.tx` / `std.interval`: `Tx.signedBy(pkh)`,
  `Tx.findInput(ref)`, `Tx.outputsToCredential(c)`, `Tx.inputsFromCredential(c)`,
  `Tx.valuePaidTo(addr)`, `TxOut.inlineDatum()`, `Interval.lowerBoundFinite()`,
  `Interval.upperBoundFinite()`, `Interval.contains(t)`,
  `Interval.isEntirelyAfter(t)`, `Interval.isEntirelyBefore(t)`. The interval
  helpers read boundary inclusivity with the ledger's boolean encoding.
- **Lists**: `std.list.at` (returns `Optional<T>`), `concat`, `reverse`, `sum`, `count`.
- **LinearMap**: `std.linearMap.has`, `insert` (replace-or-prepend), `remove`.

## 3. Plutus V4

Upstream status, checked again against the sources on 2026-10-26 (this replaces
the status in the M1.B report):

- `PlutusLedgerApi.V4` shipped in plutus-ledger-api 1.68.0.0 (2026-08-21),
  together with `dijkstraPV = MajorProtocolVersion 12`, a V4 cost-model parameter
  list and evaluation context. The V4 context is largely redesigned for CIP-0118
  (Nested Transactions) and CIP-0112 (guards): a 4-field `ScriptContext`
  (adds the executing script's hash), a 19-field `TxInfo` (drops `fee` and
  `requiredSigners`; adds sub-transaction index, direct deposits, account balance
  intervals, guards), script-hash-carrying purposes with a new `Guarding` purpose,
  an accounts-based certificate family, and `TopTxInfo` whole-batch views.
- The shapes changed during this milestone. Pebble's V4 types were first
  written and verified against 1.68.0.0. Upstream then changed the encoding of
  every V4 product type from `Constr 0 fields` to a plain `List` of fields
  (1.69.0.0, 2026-09-11), and replaced the script purposes in the aggregated
  batch view with the redeemers' script hashes (1.71.0.0, 2026-09-29). Pebble
  0.5.0 tracks 1.71.0.0, the version the public Dijkstra-era testnet runs.
- Preview and preprod still run protocol version 11 (checked 2026-10-27).
  The Dijkstra hard fork to protocol version 12 is not scheduled on them yet:
  the public DijkstraNet opened on 2026-10-21 on protocol version 11 and forks to
  12 after the cardano-node 11.2 pre-release. CIP-0118 is still Proposed and the
  V4 cost-model values are not final.
- One public network already runs Plutus V4: Musashi, the Leios testnet
  (network magic 164). It runs the Dijkstra era at protocol version 12 with Leios
  (endorser blocks) enabled, a Plutus V4 cost model in its Dijkstra genesis, and a
  cardano-ledger build that requires plutus-ledger-api >= 1.71. Criterion 2 is
  evidenced there (below).

Delivered in 0.5.0 (everything that can be built before the fork):

- **V4 prelude types**: the complete family, under the same names as the V3
  types (`ScriptContext`, `Tx`, `TxOut`, `TxIn`, `Address`, `ScriptInfo`,
  `ScriptPurpose`) plus the V4-only shapes (`POSIXTimeRange`, `AccountId`,
  `AccountBalanceInterval(s)`, `TxCert`, `TopTxInfo(Simplified)`).
- **Encoding fixtures from the released library**: a small Haskell program
  (vendored at `packages/pebble/scripts/v4-fixtures/`) builds sample values of
  every V4 type with the released plutus-ledger-api 1.71 and dumps their real
  `toData` CBOR: 55 golden fixtures covering every constructor.
  The `compiler.v4Prelude` suite decodes each fixture back through the pebble
  types on the CEK machine, pinning constructor indices, field order and the
  list/constructor encoding of each type to the library's output. Of the 39
  fixtures generated against 1.68, 13 changed with 1.69, all because a product
  type became a list (no field or constructor index moved), and 16 were added for
  the new V4 wrappers and the governance actions. With 1.71 only the fixture
  carrying the renamed field changed. (Upstream added its own V4 encoding
  tests with 1.69.)
- **List-encoded V4 product types**: `ScriptContext`, `Tx`, `TxIn`, `TxOut`,
  `Address`, `POSIXTimeRange`, `TopTxInfo`, `TopTxInfoSimplified`, and the
  products V4 shares with V3 by name (`TxOutRef`, `Rational`, `ProtocolVersion`,
  `ConstitutionInfo`, `ProposalProcedure`, `AssetClass`) are list-encoded under
  `"experimental-v4"` and remain `Constr 0` under `"v3"`;
  `TopTxInfoSimplified.redeemerHashes: List<ScriptHash>` follows 1.71.
- **`targetPlutusVersion` compiler option** (`"v3" | "experimental-v4"`,
  default `"v3"`): the type names never change; the option decides which
  ledger-API family defines them, one family per compilation. The `contract`
  sugar compiles under `"experimental-v4"` and gains a `guard` method keyword
  for the V4 guarding purpose (with `context.guardIndex` / `context.topTxInfo`)
  and `top` / `nested` execution-level keywords on every contract method. The
  derived body matches `tx.subTxIx` before the purpose, and contracts without a
  level are top-only (they always fail inside a sub-transaction). Both keywords
  are rejected under `"v3"` with located diagnostics. The plain `"v4"` spelling
  is reserved until Plutus V4 is active on mainnet, so the option name shows
  that these types predate the fork.

The fixture work found two compiler bugs, both present since before 0.4.x and
both now fixed: `match` with an `else` arm on a data struct with 3+ constructors
sent every value to the `else` branch without any error (a shared wildcard IR
node corrupted the single-parent IR tree and the dispatch was constant-folded
away), and destructuring through an alias of a data struct threw. The four
deployed mainnet contracts never used the affected pattern; they recompile
byte-identically across all milestone changes when the 0.4.x struct encoding is
kept (`"encodingStrategy": "legacy"`, see below).

### List-encoded structs as a language feature

Supporting the V4 encoding required list-encoded structs to work throughout the
compiler, so the capability is exposed to user code as well. The form of a
single-constructor struct declaration now picks its encoding:

```ts
struct ListEncoded { a: int }                                 // List [ I a ]
struct SingleConstrEncoded { SingleConstrEncoded { a: int } } // Constr 0 [ I a ]
```

- A list encoding existed since 0.4.x behind an `untagged` keyword, but only
  some lowering paths honoured it: a list-encoded struct bound to a `const`,
  cast from `data`, destructured, used as a loop variable, nested in another
  struct or instantiated from a generic was still decoded as a constructor and
  failed at runtime. All of these paths are fixed and covered by 27 new tests
  that assert evaluated results.
- **Breaking change** for contracts that declare shortcut-form structs:
  recompiling them with 0.5.0 changes their script bytes and the
  encoding of those values. A `contract`'s own datum and redeemer are not
  affected. The previous behaviour is available with
  `"encodingStrategy": "legacy"`, and with it the four deployed mainnet
  contracts recompile byte-identically (verified 2026-09-29 by SHA-256
  against the committed artifacts). Under the new default three of the four
  compile to different bytes, as expected.
- Known follow-up: under the new default one of those contracts is 4% larger
  (5,311 B to 5,523 B) although two are smaller; the optimizer shares fewer
  construction sites for list-encoded values. Output is correct; this is a
  size optimization still to be done.

### A Pebble V4 contract executed on chain (criterion 2)

Preview and preprod cannot execute Plutus V4 scripts until the Dijkstra hard fork,
so the evidence was produced on Musashi, the public Leios testnet, which runs
the Dijkstra era at protocol version 12 with Leios enabled. It is the only public
network that executes `PlutusScriptV4` scripts today. The project is
[`examples/plutus-v4-musashi`](https://github.com/HarmonicLabs/pebble/tree/ffa20573d3eb81bc1ce22fee43b9964dd3a96af3/examples/plutus-v4-musashi) in the Pebble repository; the full record,
with commands to verify each step independently, is in
[`EVIDENCE.md`](https://github.com/HarmonicLabs/pebble/blob/ffa20573d3eb81bc1ce22fee43b9964dd3a96af3/examples/plutus-v4-musashi/onchain/EVIDENCE.md).

- **Contract**: `HashLockV4`, source
  [`src/index.pebble`](https://github.com/HarmonicLabs/pebble/blob/ffa20573d3eb81bc1ce22fee43b9964dd3a96af3/examples/plutus-v4-musashi/src/index.pebble), compiled by Pebble 0.5.0
  ([`v0.5.0`](https://github.com/HarmonicLabs/pebble/tree/4e0e403b81bd18033b55529eea3337747c06807c)) with `targetPlutusVersion: "experimental-v4"`
  ([`pebble.config.json`](https://github.com/HarmonicLabs/pebble/blob/ffa20573d3eb81bc1ce22fee43b9964dd3a96af3/examples/plutus-v4-musashi/pebble.config.json)) into 321 bytes, Plutus Core
  1.1.0, script hash `c12677608f4872a8fad80dc61543c18ace733f2e2e8bac023e4f2f56`. Spending
  checks a secret against the hash in the datum and requires the transaction's
  validity interval to start no earlier than a time in the datum, so it decodes
  the datum, the redeemer and the transaction from the V4 script context,
  including the list-encoded `ScriptContext`, `TxInfo` and `POSIXTimeRange`.
- **From source to chain**: the source compiles to the committed program byte for
  byte, both with the published CLI (`npm i -g @harmoniclabs/pebble-cli@0.5.0`)
  and with the `v0.5.0` compiler built from a fresh clone of the repository
  ([steps](https://github.com/HarmonicLabs/pebble/blob/ffa20573d3eb81bc1ce22fee43b9964dd3a96af3/examples/plutus-v4-musashi/README.md#reproducing)); its script hash is the one the explorer
  reports for the unlock and the one the committed signed unlock carries.
- **On chain**: both transactions were confirmed on 2026-10-27.

  | step | transaction | block (number, hash) |
  |---|---|---|
  | lock: 20 ADA to the script with an inline datum | [`c4af6685095147d8e9f0a2447f602660d83bc50f91a60e8bece363a238bd0855`](https://kleioscan.com/#/musashi/tx/c4af6685095147d8e9f0a2447f602660d83bc50f91a60e8bece363a238bd0855) | 37049, `8f3fd9249d995f5393dd8fd832d0bb479508c4c91201c0870629405a9ef9a00f` |
  | unlock: the V4 script runs | [`e36e3e7a37d6ade13951d793c8646b17105ffafffc7acce7681a822ba2c6195c`](https://kleioscan.com/#/musashi/tx/e36e3e7a37d6ade13951d793c8646b17105ffafffc7acce7681a822ba2c6195c) | 37057, `2e0a241cca26a34e0fa53c42ed05ab52949817375e8eeb0287f020e3be81a1cf` |

  For the unlock, the explorer reports `valid_contract: true`, script type
  `plutusV4` with the script hash above, and 31,996 memory and 9,258,110 CPU
  units; the collateral was not taken. Both block headers carry protocol version
  12.0. Block 37057 certifies Leios endorser block
  `07fd04d010856055d292ab41c5a6e68227e3d41f6a19e2ea9733de821f213613`, which
  brings in its 1,414 transactions, so the unlock reached the chain through
  Leios.
- **Verifying it**: each hash opens in KleioScan, and
  `https://kleioscan.com/api/musashi/txs/<hash>` returns the record as JSON. The
  signed transactions are committed with the evidence, so
  `cardano-cli dijkstra transaction txid --tx-file tx/unlock.signed` recomputes the
  hash from the file. If Musashi has been respun by the time of review, KleioScan
  lists the previous chain under its own network id; this chain is network magic
  164 with Shelley genesis hash
  `d1b19e006c1198fb7ac9d53073c1a9f77acb1a9474c92310006ae4418290cda3`, and the
  explorer's records as of 2026-10-27 are saved with the evidence.
- **Negative case**: the same unlock with a wrong secret is rejected by the script
  during evaluation. The ledger's evaluator reports `Script language: PlutusV4`,
  `Protocol version: Version 12` and the contract's own trace, `wrong secret`.
- **Locally**: the same program accepts the valid spend and rejects a wrong
  secret, an early spend, a missing lower bound, and execution inside a
  sub-transaction, against contexts built from the plutus-ledger-api 1.71
  encodings.

#### Each new Plutus V4 feature on chain

A second contract, `V4Features` ([source](https://github.com/HarmonicLabs/pebble/blob/ffa20573d3eb81bc1ce22fee43b9964dd3a96af3/examples/plutus-v4-features/src/index.pebble), [project](https://github.com/HarmonicLabs/pebble/tree/ffa20573d3eb81bc1ce22fee43b9964dd3a96af3/examples/plutus-v4-features)), has one method per purpose, so a
single script (hash `067e368d715135fccf0d399f9d47ce9ec9b92dbc0d5e75ae44d17a14`)
is the minting policy, the script account, the guard and the spending address.
Each method checks the part of the V4 script context its feature introduced.
On 2026-10-27 it ran on Musashi for every feature that the available tooling
can put in a transaction; each transaction was accepted with
`valid_contract: true`, and the ledger runs every Plutus script of a batch,
sub-transactions included, before accepting it. Full record and verification
steps: [`EVIDENCE.md`](https://github.com/HarmonicLabs/pebble/blob/ffa20573d3eb81bc1ce22fee43b9964dd3a96af3/examples/plutus-v4-features/onchain/EVIDENCE.md).

| feature | the script checks | transaction (block) |
|---|---|---|
| account-based certificate (certifying purpose) | a script account is registered with the 2 ADA deposit | [`ffab987ef36b8eb9a8c78985dfc329091cf2a5aa19e71c9a60f78f425864ead8`](https://kleioscan.com/#/musashi/tx/ffab987ef36b8eb9a8c78985dfc329091cf2a5aa19e71c9a60f78f425864ead8) (37257, via a Leios endorser block) |
| minting | exactly one token of its policy is minted | [`c4531fc8ac0d6287e634d4880453551a7dbee17f28693b38236dd3a626189b61`](https://kleioscan.com/#/musashi/tx/c4531fc8ac0d6287e634d4880453551a7dbee17f28693b38236dd3a626189b61) (37275) |
| withdrawing, keyed by account | its account withdraws 0 | [`6a0d8f1e809079dc17f56a6a935ed1064e6cb1a05299fc696310f6563c4dbcc9`](https://kleioscan.com/#/musashi/tx/6a0d8f1e809079dc17f56a6a935ed1064e6cb1a05299fc696310f6563c4dbcc9) (37286, via a Leios endorser block) |
| nested transaction (CIP-0118): spend inside a sub-transaction, required top-level guard | it runs inside a sub-transaction and the batch requires the expected top-level guard | [`22b4675dc685a79c79a42e705989c878ed46feb6b680387cd079b709145d5f36`](https://kleioscan.com/#/musashi/tx/22b4675dc685a79c79a42e705989c878ed46feb6b680387cd079b709145d5f36), sub-transaction `5abad9c5334a7ba924099db5de3f2197370adfc71d7726cef1ba4e1636652552` (37310) |
| guard inside a sub-transaction (CIP-0112) | no batch view inside a sub-transaction | same sub-transaction (37310) |
| direct deposits and account balance intervals | 1 ADA deposited into a key account; the script account's balance bounded to `[0, 1 ADA)` | [`048dfd10e2879820e77416093528e88f80201168ff98357e9a17f3418821565b`](https://kleioscan.com/#/musashi/tx/048dfd10e2879820e77416093528e88f80201168ff98357e9a17f3418821565b) (37324); the key account's balance is exactly 1 ADA afterwards |
| guard of the top-level transaction (CIP-0112) | it sees the whole batch, with exactly one sub-transaction | [`cd1f02c217bcdeedbc5d45225d18326d6da9274e9bcf996d1e4be35e399ba448`](https://kleioscan.com/#/musashi/tx/cd1f02c217bcdeedbc5d45225d18326d6da9274e9bcf996d1e4be35e399ba448), sub-transaction `d3374a0dbe9604e54247fbe06dd8839bdd045350e1a01253d2a2dd352dd9f607` (37362) |

- **From source to chain**: the script was compiled from that source by the
  compiler at [`cff5f0b0`](https://github.com/HarmonicLabs/pebble/commit/cff5f0b0605f0e7cf5f88dac65890c999eae4d89), which is 0.5.0 plus the fix
  described below; without that fix the source does not compile. Rebuilt from a fresh clone of
  the repository, it comes out byte for byte the same
  ([steps](https://github.com/HarmonicLabs/pebble/blob/ffa20573d3eb81bc1ce22fee43b9964dd3a96af3/examples/plutus-v4-features/README.md#reproducing)), and every transaction in the table
  carries the Plutus V4 script with the hash above. The explorer shows that
  hash for every run except the two guard runs, and the evidence's
  `inspect-tx.py` reads it from each committed signed transaction, guard runs
  included.
- **Tooling**: `cardano-cli` 11.3 (the Musashi build) has
  no options for direct deposits or account balance intervals, and accepts
  script guards only on sub-transactions; buildooor has no Dijkstra support yet.
  Those two transactions were built with `cardano-cli` and then extended by two
  small scripts committed with the evidence, which add the missing fields
  without touching anything the script data hash covers.
- **Explorer**: KleioScan shows the two guard redeemers with purpose
  `propose`; its purpose list predates the `guarding` tag (6). The evidence
  includes `inspect-tx.py`, which reads the tag, the sub-transaction ids, the
  new body fields and the hash of each script carried straight from the
  committed signed transactions.
- **Not covered**: voting needs an open governance action (Musashi's only one is
  enacted); proposing needs a 100,000 ADA deposit; the starting account balance
  intervals of a batch were not exercised.
- **Compiler fix**: withdraw methods could not read their
  account as `context.credential` (the contract sugar exposed it only as
  `context.policy`). Fixed after the tag, in `cff5f0b0`, with regression tests;
  the `V4Features` script was built with the fix.

What waits for the Dijkstra fork on preview/preprod and mainnet: emitting the
`PlutusScriptV4` envelope from the export pipeline and buildooor (the demo above
wraps the compiled program by hand), and the final V4 cost-model values. The plan
is in the repo at `internal_docs/plutus-v4-status.md`.

## 4. Three new UPLC-CAPE categories

The three submissions are in
[IntersectMBO/UPLC-CAPE#263](https://github.com/IntersectMBO/UPLC-CAPE/pull/263)
as `submissions/<scenario>/Pebble_0.5.0_michele-nuzzi/`, with sources vendored
and pinned to the `v0.5.0` release commit (`4e0e403b`). They are rebased on
upstream `main` (last on 2026-10-28), which in the meantime changed the escrow
scenario (refund deadline 1,800,000 ms instead of 1,800, #253; exclusive upper
time bounds, #247); the escrow source was updated accordingly. All metrics were
produced by the official CAPE `measure` tool (evaluator
`PlutusTx.Eval-1.63.0.0`, the cardano-node 11.0.1 mainnet line), with every
scenario test vector passing, and `cape submission verify` passes for all
three. Aggregates follow the report's accounting (the measured positive vectors);
lower is better. Competitors are the best entry per compiler in upstream `main`
on 2026-10-29.

| scenario | Pebble 0.5.0 (CPU / mem / size) | next best entry | standing |
|---|---|---|---|
| `fibonacci` (open) | 55,846,226 / 222,119 / 75 B | Plinth 1.61: 59,206,243 / 243,219 / 63 B | fastest entry that computes the result; the faster entries (Scalus, Plutarch, Aiken) answer from prepacked lookup tables of the 26 expected values |
| `factorial` (open) | 25,651,296 / 104,195 / 49 B | Plutarch 1.11: 37,001,975 / 137,290 / 65 B | fastest overall (31% less CPU), lowest memory |
| `two_party_escrow` (open, real-world) | 163,663,780 / 574,564 / 1,357 B | Plinth 1.67: 163,913,498 / 486,978 / 1,572 B | lowest CPU in the scenario on Pebble's first real-world entry; 23% below Scalus 1.3.0; script within 4% of the smallest (Plinth keeps the memory lead, a known CPU/memory trade-off of Pebble's value-reading fast path) |

Separately, the UPLC-CAPE maintainers re-submitted Pebble's two naive-recursion
entries with Pebble 0.4.4 (#257, merged 2026-10-08) and 0.5.0
([#268](https://github.com/IntersectMBO/UPLC-CAPE/pull/268), merged
2026-10-29 and already on the [live report](https://intersectmbo.github.io/UPLC-CAPE/));
both versions compile the same sources to the same programs. After
#264 and #266 (2026-10-28) brought the sources to the prescribed base cases
(Pebble's factorial had stopped at `n <= 1`, the Scalus fibonacci entries had an
extra base case), Pebble leads both scenarios among five compilers:
`factorial_naive_recursion` at 26,979,195 CPU, 4% below the next, and
`fibonacci_naive_recursion` at 112,400,919,906 CPU, 13% below the next.

The escrow validator is a fully-applied `(data) -> unit` script with
deposit/accept/refund endpoints, and it validates each endpoint in a single pass
over the outputs. The work also added `pebble uplc pretty --canonical` to the
CLI: it emits spec-compliant plutus-core concrete syntax, which the harness
parses directly (formatted with the repository's `pretty-uplc`, the output is
byte-identical to the submitted artifacts).

This milestone's deliverable asked for the two open fixed-function scenarios
plus at least one of the three real-world contracts. The escrow covers the
real-world part; the other two real-world scenarios (Linear Vesting, HTLC) can
follow on the same setup.

The submissions are public and independently reproducible. Each one vendors its
source, and the
[reproduction steps](https://github.com/HarmonicLabs/pebble/blob/v0.5.0/examples/uplc-cape/README.md)
start from a clone of the `v0.5.0` tag and the npm release
`@harmoniclabs/pebble-cli@0.5.0`. Following them on 2026-10-29 gave the
submitted programs for all three scenarios, and the CAPE `measure` tool, run on
the PR branch, reproduced every figure in the table above with all test vectors
passing (11 of 11, 10 of 10 and 47 of 47). Criterion 3 is reported as met on
this basis; the entries reach the live report when the maintainers
merge #263. The PR follows the upstream conventions and passes the repository's
own verification locally; its CI runs once a maintainer approves the workflow.

## 5. Public benchmark write-up

[`BENCHMARKS.md`](https://github.com/HarmonicLabs/pebble/blob/90eac874956a5effe63e431c3c1d65f5da5e9de4/BENCHMARKS.md),
at the repository root, covers the methodology (official CAPE metrics and
evaluator), the per-scenario comparison tables against Aiken, Plinth, Plutarch,
Scalus and OpShin, the naive-recursion results, and the mainnet Aiken-port
cross-check (Pebble scripts at 89 to 98% of the Aiken port's size). The README's "what is
pebble?" section, empty until this milestone, now introduces the language and
links the write-up. Both are in the `v0.5.0` release. The link above is the
current version on `milestone2`: its tables were refreshed after the tag, on
2026-10-26 with the figures above and on 2026-10-29 with the naive-recursion
standings after #264 and #268.

## 6. Work inventory

**Releases**

- [`@harmoniclabs/pebble` / `pebble-cli` 0.5.0, GitHub release `v0.5.0`](https://github.com/HarmonicLabs/pebble/releases/tag/v0.5.0);
  the release notes are the 0.5.0 changelog (test framework, standard library,
  Plutus V4). Merge of `milestone2` into `main`:
  [HarmonicLabs/pebble#27](https://github.com/HarmonicLabs/pebble/pull/27), which awaits a
  maintainer review; its CI passes on Linux, macOS and Windows.
- [`@harmoniclabs/plutus-machine` 3.0.5, GitHub release `v3.0.5`](https://github.com/HarmonicLabs/plutus-machine/releases/tag/v3.0.5)
  (CEK conformance fixes the test runner relies on), merged through
  [HarmonicLabs/plutus-machine#3](https://github.com/HarmonicLabs/plutus-machine/pull/3).
- Documentation:
  [HarmonicLabs/plu-ts-docs#49](https://github.com/HarmonicLabs/plu-ts-docs/pull/49),
  merged.

Pebble monorepo, `v0.5.0` (on top of 0.4.5):

| commit | content |
|---|---|
| `3d4c88a4` | test framework completion + stdlib expansion (2,711 insertions) |
| `18c812dd` | 0.5.0 version bump, changelog, UPLC-CAPE submission sources |
| `fed99a71` | BENCHMARKS.md, README, Plutus V4 status doc |
| `57cdd291` | `pebble uplc pretty --canonical` |
| `9ce18bbd` | example test suites in CI |
| `30206144` | official CAPE metrics, escrow optimization, V4 upstream re-verification |
| `60750042` | Plutus V4 prelude types + encoding fixtures + the two compiler-bug fixes |
| `e68a46a3` | vendored V4 fixture generator |
| `98471804` | `targetPlutusVersion` option |
| `058e1477`, `10ead1c0` | `guard` methods, `top` / `nested` execution levels |
| `a2a534e0` | list-encoded structs: shortcut form is a list, every lowering path fixed (section 3) |
| `f9b57506` | escrow deadline in POSIXTime milliseconds (UPLC-CAPE #253) |
| `4791113f` | V4 types track plutus-ledger-api 1.71; fixtures regenerated |
| `4e0e403b` | requires plutus-machine ^3.0.5 (tag `v0.5.0`) |
| `6943bed1` | BENCHMARKS.md refreshed with the current UPLC-CAPE figures (after the tag) |
| `7b2cc30a` | `examples/plutus-v4-musashi`: the V4 contract and its on-chain evidence (after the tag) |
| `34bbe70d` | evidence: block hashes, chain identity, explorer snapshots (after the tag) |
| `cff5f0b0` | fix: withdraw methods expose the account as `context.credential` (after the tag) |
| `e7924eaf` | `examples/plutus-v4-features`: each V4 feature executed on chain, with evidence (after the tag) |
| `ffa20573` | both V4 examples: rebuild-from-source steps, checked from a fresh clone; `inspect-tx.py` prints script hashes (after the tag) |
| `64414d38` | lockfiles resolve the published `plutus-machine` 3.0.5 and Pebble 0.5.0 (after the tag) |
| `f629c7fc`, `5e547bf9` | build: the version generators resolve their paths on Windows (the Windows build had been failing since May); CI runs every OS to completion (after the tag) |
| `90eac874` | BENCHMARKS.md: naive-recursion standings after UPLC-CAPE #264 and #268 (after the tag) |

**Verification**: the compiler suite grew from 844 to 934 passing tests (147
suites; 12 skipped, 5 todo) with zero failures; the four deployed mainnet
contracts (`the-cardano-masterpiece`) recompile byte-identically with
`"encodingStrategy": "legacy"` (section 3); the three CAPE artifacts are byte-identical
before and after the encoding change (their sources declare no shortcut-form
structs), apart from the escrow's deadline constant; the 14 on-chain code
snippets in the documentation compile against 0.5.0.

## 7. Variance analysis

**Scope variance**: two pieces of work were not in the plan and were absorbed
within the milestone:

- tracking the Plutus V4 ledger API through three upstream releases with
  breaking encoding changes (1.68, 1.69, 1.71; section 3), and
- making list-encoded structs work throughout the compiler, which V4 required and
  which shipped as a language feature (section 3).

**Schedule variance**: the milestone window closed on 2026-09-30; this report and
the release follow it by four weeks. The delay came from the V4 re-verification
and from criterion 2, which could not be evidenced until a public network ran
Plutus V4.

## 8. Plan for Q4 2026 (Milestone 3)

Milestone 3 deliverables, from the proposal:

1. **REPL**: `pebble repl` exists in the CLI but is undocumented. Harden it and
   add the public README walkthrough on a freshly cloned example project that the
   acceptance criterion asks for.
2. **Sourcemaps**: emit a sourcemap from the compiler that maps UPLC terms back to
   Pebble source ranges; carry it alongside the compiled script.
3. **buildooor sourcemap support** (acceptance criterion): report script
   evaluation failures with Pebble file and line.
4. **LSP**: upgrade `pebble-lsp` and `tree-sitter-pebble` from 0.3.0 to the 0.5.x
   compiler, then surface sourcemapped locations.
5. **Library maintenance for the Dijkstra hard fork**: Plutus Core 1.2.0 and the
   Dijkstra builtin semantics variants F and G in `uplc` / `plutus-machine`; final
   V4 cost-model values in `cardano-costmodels-ts`. `cardano-ledger-ts`
   0.6.0 (released 2026-10-26) already models Dijkstra transactions:
   sub-transactions, guards, required top-level guards, direct deposits, account
   balance intervals and `PlutusScriptV4` witnesses. What remains is in
   buildooor: building those transactions, constructing V4 script contexts
   to evaluate execution units, and the per-(sub-)transaction script data hash.
   The on-chain feature runs in section 3 needed hand-assembled transactions for
   exactly these gaps.

Carried over from M2: evidence for criterion 2 on preview/preprod once they fork;
the size optimisation for list-encoded values; monthly updates.
