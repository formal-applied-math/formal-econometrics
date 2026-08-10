# formal-econometrics

Formally verified **econometric identification** in Lean 4, on Mathlib.

Identification — not estimation, not asymptotics. Whether a parameter is pinned
down by the observable distribution at all, before any sample exists. It is where
informal econometrics is at its sloppiest, and where a machine-checked treatment
has the most obvious reason to exist.

## Status: phase 0 — a probe, not a library

One theorem, end to end: **parallel trends ⇒ the ATT is identified**
(difference-in-differences). Its job is to find out whether a potential-outcomes
definitional layer comes out idiomatic over Mathlib's conditioning machinery. If it
does not, the territory gets re-examined before more is spent — see
[`docs/phase0-verdict.md`](docs/phase0-verdict.md).

Do not read this repo as an identification library yet. It is one theorem and the
apparatus that will hold the rest honest.

## What the apparatus is for

Every entry declares how faithful it is to the informal result it is named after —
`full`, `library_wrapper`, `reduced_core`, or `placeholder` — and that declaration
is machine-enforced, not editorial. Alongside it: `#print axioms` pinning on every
headline theorem, an input-hash verification ledger so a claim of "verified" names
exactly what it was verified against, and gates that fail the build on `sorry`,
`native_decide`, and prose that claims more than its own statement proves.

In a field whose entire subject matter is *that empirical claim was overstated*,
this is the part worth building carefully.

## Build

```bash
lake exe cache get && lake build     # canonical verification
python3 -m pytest tests/ -q          # honesty gates
python3 -m tools.verify.ledger status
```

Mathlib is pinned to the same revision as
[`formal-mathfin`](https://github.com/raphaelrrcoelho/formal-mathfin), deliberately:
the two libraries must be able to share a `ForMathlib/` block, and that requires a
shared Mathlib.

## Design of record

`formal-mathfin/docs/applied-areas.md` (territory audit and the Lean-ecosystem
survey), `docs/program-architecture.md` (how the repos are shaped), and
`docs/plans/2026-08-09-program-execution/03-econometrics-phase0.md` (this phase).
