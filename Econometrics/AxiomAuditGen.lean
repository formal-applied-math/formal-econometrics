/-
  GENERATED FILE — do not edit by hand.

  Exhaustive axiom audit: every Econometrics constant consumed in PROOF POSITION
  by a benchmark snippet is #guard_msgs-pinned to its exact axiom set, so no
  benchmark-cited theorem can pick up `sorryAx` (a `sorry`) or a non-standard
  axiom without breaking `lake build`.

  The curated, storied audit is Econometrics/AxiomAudit.lean (headliners + dated
  narrative); THIS file is its machine-written closure over the benchmark
  corpus (1 constants). Scope: proof-position Econometrics names only —
  statement-position defs are exercised by elaboration + the verification
  ledger, and library_wrapper entries cite upstream names.

  Regenerate:  python3 -m tools.verify.axiom_audit_gen --write
  Freshness:   tests/test_values.py::test_axiom_audit_gen_is_fresh
  (Excluded from CI kernel replay like AxiomAudit: whole-library closure.)
-/
import Econometrics

namespace Econometrics.AxiomAuditGen

/-- info: 'Econometrics.Model.att_eq_didContrast' depends on axioms: [propext, Classical.choice, Quot.sound] -/
#guard_msgs (whitespace := lax) in #print axioms Econometrics.Model.att_eq_didContrast

end Econometrics.AxiomAuditGen
