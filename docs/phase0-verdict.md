# Phase 0 verdict — is the definitional layer idiomatic?

**Date:** 2026-08-10 · **Corpus:** 1 entry (`did-att-1`) · **Build:** green, zero
`sorry`, axiom-pinned to `[propext, Classical.choice, Quot.sound]`

Phase 0 was a **probe, not a launch**. Its question, from
`formal-mathfin/docs/applied-areas.md` §7 risk 2:

> If potential outcomes / treatment assignment cannot be stated idiomatically over
> Mathlib's measure theory, phases 1–2 inherit the ugliness.

and its kill criterion, from runbook 03:

> If the potential-outcomes layer needs bespoke measure-theoretic scaffolding rather
> than consuming `condExp` directly — more than ~a screenful of adapter lemmas that
> Mathlib "should" have had — STOP.

## Verdict: continue — with one part of the criterion untested, stated plainly

**The adapter count is one lemma, three lines.**

```lean
theorem MeasureTheory.Integrable.cond (hf : Integrable f μ) (s : Set Ω) :
    Integrable f (μ[|s]) := by
  rcases eq_or_ne (μ s) 0 with hs | hs
  · simp [ProbabilityTheory.cond_eq_zero_of_meas_eq_zero hs]
  · exact hf.restrict.smul_measure (ENNReal.inv_ne_top.2 hs)
```

Everything else is consumed from Mathlib unchanged: `ProbabilityTheory.cond` and its
`ae_cond_mem`, `integral_sub`, `integral_congr_ae`, `Set.indicator`. No bespoke
measure theory, no re-derivation, nothing that felt like fighting the library. That
is comfortably under "a screenful", so the criterion as written does not fire.

**But the criterion named `condExp`, and this proof does not use it.** The theorem
conditions on an *event* via `ProbabilityTheory.cond`, because that is what the
informal DiD statement says and because it keeps the four observable means as four
integrals. The σ-algebra route through `MeasureTheory.condExp` — the one covariate
conditioning needs, and therefore the one RDD and IV will be written against — was
**not exercised**. So the probe verified the encoding it chose and left the other
encoding's ergonomics an open question.

Calling this a clean pass of the stated criterion would be exactly the rounding-up
the honesty register forbids. The accurate statement: *the event-conditioning layer
is idiomatic; the σ-algebra layer is untested and is the top residual risk.*

## What the probe actually learned

**1. The definitional layer wants two types, not one.** `Observed` (treatment group
+ realized outcomes) and `Model` (potential outcomes) as separate structures makes
identification a statement Lean can check rather than a claim a comment makes: an
estimand is a function of `Model`, an estimator a function of `Observed`, and the
theorem equates them. This came out cleanly and it is the design phases 1–2 should
keep.

**2. The realization rule should be a definition, not a hypothesis.** `Model.observed`
*constructs* the observed data from the model, so "the observed post-period outcome
equals the treated potential outcome on the treated group" is **derived** — from
`ae_cond_mem` — rather than assumed. Most informal treatments assume it (as SUTVA or
"consistency"). Deriving it costs two three-line lemmas and removes two hypotheses
from every downstream statement.

**3. `Set.indicator` beats `if` for the realization rule.** It removes the
decidability obligation on set membership that would otherwise propagate into every
statement mentioning observed outcomes, and it makes the two arms literally disjoint
summands, which is what the a.e. argument wants.

**4. The hypothesis set is small and every member is consumed.** Measurability of the
treated set, integrability of the three potential outcomes that appear, parallel
trends. Notably *not* needed: `IsProbabilityMeasure μ`, `IsFiniteMeasure μ`, or any
positivity assumption on `μ(treated)` — `cond` degenerates to the zero measure when
the conditioning event is null, and the algebra survives it.

**5. The type discipline is weaker than the phrase "identified".** `didContrast`
provably reads no counterfactual. It does still take the population measure `μ`,
which lives on the same `Ω` as the potential outcomes, so the statement is not yet
"depends only on the law of the observables". See the values review's **B1** — this
is the first phase-1 task, before IV/LATE, because every later design inherits the
carrier.

## Consequences for the program

- **Phase 1 proceeds**, with B1 first: restate the observable side over the
  pushforward law. Doing it after IV/LATE would mean rewriting them.
- **The `condExp` bridge is the gating experiment for RDD/IV**, not a nice-to-have.
  Run it early in phase 1 as its own small probe; if it is ugly, that is the phase-1
  version of this document's question and it deserves the same treatment.
- **`MeasureTheory.Integrable.cond` is a `ForMathlib/` candidate** and, at three
  lines, a far more tractable first upstream than the Brouwer tower runbook 05
  anticipated — which turned out to exist already
  (`formal-mathfin/docs/applied-areas.md` §2a, corrected 2026-08-09).
- **The apparatus copy worked and paid for itself immediately**: it surfaced a real
  bug in the flagship's `formalization_yaml.py`, which hardcodes a provenance
  narrative that a second corpus would emit as its own. See
  [`apparatus-divergence.md`](apparatus-divergence.md).
