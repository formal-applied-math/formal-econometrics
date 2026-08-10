import Lake
open Lake DSL

package Econometrics where
  leanOptions := #[
    ⟨`autoImplicit, false⟩
  ]
  -- Advisory environment-linter gate, consuming Batteries' canonical
  -- `runLinter` exactly as Mathlib does. Scoped to this package's own
  -- declarations, so Mathlib's are not linted. Run on demand; the enforced
  -- soundness floor is `lake build` + the axiom audit, not the linter.
  lintDriver := "batteries/runLinter"
  lintDriverArgs := #["Econometrics"]

-- `globs := .andSubmodules` builds the umbrella AND every submodule, including
-- leaves nothing imports — `Econometrics.AxiomAudit` is exactly such a leaf, and
-- without this it would rot silently while the build stayed green.
@[default_target]
lean_lib Econometrics where
  globs := #[.andSubmodules `Econometrics]

-- Pinned to the SAME revision as formal-mathfin's `lake-manifest.json`. That is
-- deliberate: the two libraries must be able to consume a shared `ForMathlib/`
-- block, and a shared block requires a shared Mathlib. See
-- `formal-mathfin/docs/program-architecture.md` §1 (L0).
--
-- BrownianMotion and kolmogorov_extension4 are NOT required here. Identification
-- needs conditional expectation and orthogonal projection; it needs no
-- continuous-time process theory, and a smaller import closure is a smaller
-- build.
require mathlib from git
  "https://github.com/leanprover-community/mathlib4" @
  "81a5d257c8e410db227a6665ed08f64fea08e997"
