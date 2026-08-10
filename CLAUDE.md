# CLAUDE.md

Guidance for Claude Code working in this repository.

## What this repo is

A Lean 4 library of formally verified **econometric identification** results,
built on Mathlib. Identification, not estimation and not asymptotics: whether a
parameter is pinned down by the observable distribution at all, before any sample
exists. The Lean library is the artifact; `tools/verify/` is a host-side CLI
harness that drives the corpus gates.

**Scope right now is phase 0: one theorem.** Parallel trends ⇒ ATT identified
(difference-in-differences). It is a *probe* — its job is to find out whether a
potential-outcomes definitional layer comes out idiomatic over Mathlib's
conditioning machinery. `docs/phase0-verdict.md` is the deliverable as much as the
theorem is. Do not describe this repo as an identification library until the
corpus says so.

Design of record: `formal-mathfin/docs/applied-areas.md` (§3.1 territory, §4
pillars, §6 phases, §7 kill criteria) and
`formal-mathfin/docs/plans/2026-08-09-program-execution/03-econometrics-phase0.md`.

## Pins

`lean-toolchain` (`leanprover/lean4:v4.32.0`) + `lakefile.lean` +
`lake-manifest.json` are authoritative. Mathlib is pinned to
`81a5d257c8e410db227a6665ed08f64fea08e997` — **the same revision as
`formal-mathfin`**, deliberately: the two libraries must be able to consume a
shared `ForMathlib/` block, and that requires a shared Mathlib. Bump them
together or accept that the block cannot cross.

## Commands

```bash
lake exe cache get && lake build          # canonical verification
python3 -m pytest tests/ -q               # the honesty gates
python3 -m tools.verify.ledger status     # fresh/stale/missing (exit 1 unless all fresh)
python3 -m tools.verify.coverage_report   # full / library_wrapper / reduced_core / placeholder
python3 -m tools.verify.axiom_audit_gen --write   # after ANY benchmark edit
python3 -m tools.formalization_yaml --check
```

**Memory doctrine — and it binds ACROSS repos.** This box gives WSL ~10 GB. A
Mathlib-loaded Lean environment is ~4–5 GB, so two simultaneous Lean processes
overcommit the host. Before any `lake build` here, confirm no sibling repo holds
the slot:

```bash
docker ps                                                     # nothing Lean-ish
docker compose -f docker/docker-compose.yml down lean-repl    # in formal-mathfin
taskset -c 0-3 lake build                                     # 4 workers, not all cores
```

There is no Docker image for this repo yet — the library is small enough that
`lake exe cache get` plus a host build is the whole story. **Never
`docker compose build` a Mathlib image locally**; that rule does not relax
because a library is small.

## Rules that are not negotiable

- **Module system.** Every `Econometrics/` file uses the module system (`module`
  header + `public import`s) and **must** put `@[expose] public section` right
  after the module docstring. Without it every declaration is module-private:
  importers see nothing, `lake build` stays green, and only consumers break.
  Enforced by `tests/test_router.py`.
- **No `sorry`, no `admit`, no `native_decide`.** Enforced by
  `tests/test_values.py` over committed sources.
- **Every benchmark entry declares `metadata.formalization_status`**: `full`,
  `library_wrapper`, `reduced_core`, or `placeholder`. Delivery claims count only
  `full + library_wrapper`.
- **`description` states what the entry PROVES**, not the textbook theorem it is
  named after. Where an entry delivers less than its source, the description says
  so, and `metadata.formalization_scope` carries the long-form disclosure.
- **Read the prose against its own statement** before calling a session done. For
  every docstring and corpus `description` the session touched, ask whether it
  claims more than the Lean proves. This is the one failure the other gates
  structurally cannot see — the build is green precisely *because* the statement
  is weaker than the prose.
- **Observability is a definition, not a comment.** An estimand is identified iff
  it is a functional of the observable distribution. In a library whose whole
  subject is "that empirical claim was overstated", the discipline that makes it
  worth having is stating that condition in Lean rather than asserting it in a
  docstring.

## The apparatus is a deliberate copy

`tools/` and `tests/` were copied verbatim from `formal-mathfin` and then
adjusted. The verbatim commit is in the history on purpose: its diff against the
next commit **is** `docs/apparatus-divergence.md`, which is the input to the
program's genericize-exactly-once step (`formal-mathfin`
`docs/plans/2026-08-09-program-execution/04-apparatus-genericize.md`, triggered at
~20 entries here).

Until that trigger fires: **record divergence, do not fix it upstream.** Every
line of copied tooling you touch gets a line in the divergence log, classified as
(a) config that should come from the TOML, (b) a genuine parameter the schema
lacks, or (c) a mathfin-ism that was special-cased in code. Category (c) items
are bugs in the flagship and get fixed there when 04 runs — not patched here.

## House style

`formal-mathfin/docs/patterns.md` → "Mathlib house-style golf" applies from day
one: bare proof terms over `by exact`, let Lean insert coercions, bind ∀-vars in
the `have` signature, `simpa … using`, no gratuitous `classical`, the minimal
typeclass the callees need, fewer `have`s and more `suffices`, `↦` over `=>`, and
the headline — lift the reusable abstraction rather than tailoring the proof to
one call site.

Anything field-neutral that Mathlib lacks is a **`ForMathlib/` candidate**, not a
local helper. It carries an upstream target from the day it is written.
