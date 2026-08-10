/-
Copyright (c) 2026 Raphael Coelho. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Raphael Coelho
-/
module

public import Mathlib

/-!
# Potential outcomes, and what it means to be observed

The definitional layer every identification argument in this library is stated over.
Two types carry the whole idea:

* `Observed` — what an analyst has: who was treated, and one realized outcome per
  period. The potential outcomes are **absent from this type**, and that absence is
  the entire content of an identification claim.
* `Model` — the counterfactual object behind the data: an outcome for every unit
  under every arm, of which exactly one is ever realized.

An estimand is a function of a `Model`. An estimator is a function of `Observed`.
*Identification* is a theorem equating the two. Because `Observed` is a type rather
than a comment, a term of type `Observed Ω → ℝ` cannot quietly consult a
counterfactual: that much is enforced by elaboration rather than asserted in prose.

**What the type does not yet enforce.** These functionals also take the measure `μ`,
which lives on the same `Ω` the potential outcomes do. So the type rules out reading
a counterfactual, not dependence on the full population measure; the stronger
statement — that an estimand depends only on the *law* of the observables — needs
the pushforward of `(outcome, treated)` as the carrier, and is a phase-1 upgrade
rather than something claimed here.

## Main definitions

* `Econometrics.Observed`, `Econometrics.Model`, `Econometrics.Model.observed`
* `Econometrics.condMean` — the mean of a function on a sub-population
* `Econometrics.Model.att` — the average treatment effect on the treated
-/

@[expose] public section

open MeasureTheory ProbabilityTheory

namespace Econometrics

variable {Ω : Type*}

/-- The two periods of a panel design: before and after the intervention. -/
inductive Period
  | pre
  | post

/-- What the analyst sees: a treated sub-population and one realized outcome path
per period.

The potential outcomes are deliberately not fields of this structure. An estimator
is a function of `Observed`, an estimand is a function of `Model`, and an
identification theorem equates them; keeping the two types apart is what makes that
statement mean anything. -/
structure Observed (Ω : Type*) where
  /-- the treated sub-population -/
  treated : Set Ω
  /-- the outcome actually realized in each period -/
  outcome : Period → Ω → ℝ

/-- A two-period potential-outcome model: `Y d t ω` is the outcome unit `ω` would
realize in period `t` under treatment arm `d`. At most one arm per unit is ever
realized, which is why identification needs an argument. -/
structure Model (Ω : Type*) where
  /-- the treated sub-population -/
  treated : Set Ω
  /-- `Y d t` is the period-`t` outcome under arm `d` -/
  Y : Bool → Period → Ω → ℝ

namespace Model

variable (m : Model Ω)

/-- The data a model generates under the panel realization rule: nobody is treated
before the intervention, so every unit's pre-period outcome is its untreated
potential outcome, and in the post period each unit realizes the arm it was
assigned.

Written with `Set.indicator` rather than an `if`, so no decidability instance on
membership is needed and the two branches are literally disjoint summands. -/
noncomputable def observed : Observed Ω where
  treated := m.treated
  outcome := fun
    | .pre => m.Y false .pre
    | .post => m.treated.indicator (m.Y true .post)
        + m.treatedᶜ.indicator (m.Y false .post)

@[simp] lemma observed_treated : m.observed.treated = m.treated := rfl

@[simp] lemma observed_outcome_pre : m.observed.outcome .pre = m.Y false .pre := rfl

lemma observed_outcome_post :
    m.observed.outcome .post =
      m.treated.indicator (m.Y true .post) + m.treatedᶜ.indicator (m.Y false .post) :=
  rfl

end Model

section Mean

variable [MeasurableSpace Ω]

/-- The mean of `f` on the sub-population `s`: the integral of `f` against `μ`
conditioned on `s`. Every identification statement below is an equation between
these. -/
noncomputable def condMean (μ : Measure Ω) (s : Set Ω) (f : Ω → ℝ) : ℝ :=
  ∫ ω, f ω ∂(μ[|s])

lemma condMean_congr_ae {μ : Measure Ω} {s : Set Ω} {f g : Ω → ℝ}
    (h : f =ᵐ[μ[|s]] g) : condMean μ s f = condMean μ s g :=
  integral_congr_ae h

/-- A conditional mean is additive on differences, given integrability against the
conditioned measure. `Integrable.cond` below turns an ordinary integrability
hypothesis into this one. -/
lemma condMean_sub {μ : Measure Ω} {s : Set Ω} {f g : Ω → ℝ}
    (hf : Integrable f (μ[|s])) (hg : Integrable g (μ[|s])) :
    condMean μ s (f - g) = condMean μ s f - condMean μ s g :=
  integral_sub hf hg

/-- The average treatment effect on the treated: the mean, over the treated
sub-population, of the difference between the two post-period potential outcomes.

This is a function of the `Model`, not of `Observed` — its value depends on the
counterfactual `Y false .post` for treated units, which is never realized. -/
noncomputable def Model.att (m : Model Ω) (μ : Measure Ω) : ℝ :=
  condMean μ m.treated (m.Y true .post - m.Y false .post)

end Mean

end Econometrics
