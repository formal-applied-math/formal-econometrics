/-
Copyright (c) 2026 Raphael Coelho. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Raphael Coelho
-/
module

public import Econometrics.Identification.PotentialOutcomes

/-!
# Difference-in-differences: parallel trends identifies the ATT

The average treatment effect on the treated is a functional of counterfactuals — it
asks what treated units *would have* done untreated, which is never observed. Under
parallel trends it nevertheless equals a contrast that never reads a counterfactual.

That is the whole shape of an identification theorem, and here it is literally the
shape of the statement: `Model.att` takes a `Model`, `Observed.didContrast` takes an
`Observed`, and the theorem says they agree.

## Main results

* `Econometrics.Model.ParallelTrends` — the identifying restriction
* `Econometrics.Observed.didContrast` — the estimand's observable twin
* `Econometrics.Model.att_eq_didContrast` — the identification theorem

## Scope

Two periods, two groups, a binary treatment, and no covariates. Conditional parallel
trends, staggered adoption, repeated cross sections, and the negative results on
two-way fixed-effects estimators under heterogeneous timing are all outside it.

Both sides of the identification theorem take the population measure `μ` as an
argument. The contrast reads no counterfactual, which is the substantive half of
"identified"; restating it as a functional of the observable *law* is the phase-1
strengthening.
-/

@[expose] public section

open MeasureTheory ProbabilityTheory

/-! ### An integrability transfer

Conditioning on an event rescales a restriction, so it cannot create integrability
problems. Mathlib has `Integrable.restrict` and `Integrable.smul_measure` but not
their composition through `ProbabilityTheory.cond`; this is the one adapter lemma
the probe needed, and it is field-neutral — a `ForMathlib/` candidate rather than an
econometrics lemma, which is why it is declared in Mathlib's own namespace. -/

namespace MeasureTheory

/-- Integrability survives conditioning on an event: `μ[|s]` is a scalar multiple of
`μ.restrict s`, and neither operation can turn a finite integral infinite. -/
theorem Integrable.cond {Ω : Type*} [MeasurableSpace Ω] {f : Ω → ℝ} {μ : Measure Ω}
    (hf : Integrable f μ) (s : Set Ω) : Integrable f (μ[|s]) := by
  rcases eq_or_ne (μ s) 0 with hs | hs
  · simp [ProbabilityTheory.cond_eq_zero_of_meas_eq_zero hs]
  · exact hf.restrict.smul_measure (ENNReal.inv_ne_top.2 hs)

end MeasureTheory

namespace Econometrics

variable {Ω : Type*} [MeasurableSpace Ω]

/-! ### The identifying restriction and its observable twin -/

/-- **Parallel trends**: in the absence of treatment, both groups would have moved
by the same average amount.

Stated on the untreated potential outcome `Y false` in both groups, so it is a
restriction on counterfactuals — untestable, which is exactly why it has to be
assumed rather than derived. -/
def Model.ParallelTrends (m : Model Ω) (μ : Measure Ω) : Prop :=
  condMean μ m.treated (m.Y false .post - m.Y false .pre)
    = condMean μ m.treatedᶜ (m.Y false .post - m.Y false .pre)

/-- The difference-in-differences contrast: the treated group's before/after change,
minus the control group's.

Every outcome argument is a field of `Observed`, so no counterfactual is read. It
does still integrate against the population measure `μ`, so this is "does not consult
a potential outcome", not yet the stronger "depends only on the law of the
observables" — that reformulation is phase 1. -/
noncomputable def Observed.didContrast (o : Observed Ω) (μ : Measure Ω) : ℝ :=
  (condMean μ o.treated (o.outcome .post) - condMean μ o.treated (o.outcome .pre))
    - (condMean μ o.treatedᶜ (o.outcome .post) - condMean μ o.treatedᶜ (o.outcome .pre))

/-! ### What the treated and control groups actually realize -/

/-- On the treated sub-population, the realized post-period outcome *is* the treated
potential outcome — almost everywhere, which is all an integral sees. -/
lemma Model.condMean_observed_post_treated (m : Model Ω) (μ : Measure Ω)
    (hT : MeasurableSet m.treated) :
    condMean μ m.treated (m.observed.outcome .post)
      = condMean μ m.treated (m.Y true .post) :=
  condMean_congr_ae <| (ae_cond_mem hT).mono fun ω hω ↦ by
    simp [Model.observed_outcome_post, Set.indicator_of_mem hω,
      Set.indicator_of_notMem (Set.notMem_compl_iff.2 hω)]

/-- On the control sub-population, the realized post-period outcome is the untreated
potential outcome. -/
lemma Model.condMean_observed_post_control (m : Model Ω) (μ : Measure Ω)
    (hT : MeasurableSet m.treated) :
    condMean μ m.treatedᶜ (m.observed.outcome .post)
      = condMean μ m.treatedᶜ (m.Y false .post) :=
  condMean_congr_ae <| (ae_cond_mem hT.compl).mono fun ω hω ↦ by
    simp [Model.observed_outcome_post, Set.indicator_of_mem hω,
      Set.indicator_of_notMem (Set.notMem_of_mem_compl hω)]

/-! ### Identification -/

/-- **Parallel trends identifies the ATT.** The average treatment effect on the
treated — which reads the counterfactual `Y false .post` on treated units — equals
the difference-in-differences contrast, which reads only realized outcomes and the
treatment indicator.

The integrability hypotheses are on `μ` itself, not on the conditioned measures:
`Integrable.cond` transfers them, and assuming an outcome has a finite mean is the
weakest form of the assumption an econometrician would actually state. -/
theorem Model.att_eq_didContrast (m : Model Ω) (μ : Measure Ω)
    (hT : MeasurableSet m.treated)
    (h₁ : Integrable (m.Y true .post) μ)
    (h₀ : Integrable (m.Y false .post) μ)
    (hpre : Integrable (m.Y false .pre) μ)
    (hPT : m.ParallelTrends μ) :
    m.att μ = m.observed.didContrast μ := by
  have key (s : Set Ω) :
      condMean μ s (m.Y false .post - m.Y false .pre)
        = condMean μ s (m.Y false .post) - condMean μ s (m.Y false .pre) :=
    condMean_sub (h₀.cond s) (hpre.cond s)
  rw [Model.ParallelTrends, key, key] at hPT
  rw [Model.att, condMean_sub (h₁.cond _) (h₀.cond _), Observed.didContrast]
  simp only [Model.observed_treated, Model.observed_outcome_pre]
  rw [m.condMean_observed_post_treated μ hT, m.condMean_observed_post_control μ hT]
  linarith

end Econometrics
