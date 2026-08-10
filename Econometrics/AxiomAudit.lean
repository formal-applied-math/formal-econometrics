/-
Copyright (c) 2026 Raphael Coelho. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Raphael Coelho
-/
import Econometrics

/-!
# Axiom audit — the "axioms-clean" claim, build-enforced

Every derivation this library calls `full` depends only on the three standard
Mathlib axioms `[propext, Classical.choice, Quot.sound]`: no `sorryAx`, no extra
axioms.

Each `#guard_msgs in #print axioms` block below turns that from a docstring
assertion into a **build-enforced invariant**. If an audited theorem ever picks up
`sorryAx` — a `sorry` slipped in somewhere in its transitive dependencies — or a new
axiom because a dependency changed, the guard fails and the build breaks.

This is the curated, storied file. `Econometrics/AxiomAuditGen.lean` is generated
and covers every proof-position constant the benchmark corpus cites; the two are
complementary and neither replaces the other.
-/

namespace Econometrics.AxiomAudit

/-! ## Identification -/

/-! The headline result of phase 0: parallel trends identifies the ATT. -/

/-- info: 'Econometrics.Model.att_eq_didContrast' depends on axioms: [propext, Classical.choice, Quot.sound] -/
#guard_msgs in #print axioms Econometrics.Model.att_eq_didContrast

/-! The two realization bridges it rests on: the observed post-period outcome is the
treated potential outcome on the treated group, and the untreated one on the control
group. -/

/-- info: 'Econometrics.Model.condMean_observed_post_treated' depends on axioms: [propext, Classical.choice, Quot.sound] -/
#guard_msgs in #print axioms Econometrics.Model.condMean_observed_post_treated

/-- info: 'Econometrics.Model.condMean_observed_post_control' depends on axioms: [propext, Classical.choice, Quot.sound] -/
#guard_msgs in #print axioms Econometrics.Model.condMean_observed_post_control

/-! ## The staged adapter

`MeasureTheory.Integrable.cond` is field-neutral and missing from Mathlib. It is
pinned here because an upstream candidate has to be at least as clean as the
library that hosts it. -/

/-- info: 'MeasureTheory.Integrable.cond' depends on axioms: [propext, Classical.choice, Quot.sound] -/
#guard_msgs in #print axioms MeasureTheory.Integrable.cond

end Econometrics.AxiomAudit
