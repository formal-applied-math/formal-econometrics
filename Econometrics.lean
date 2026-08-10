/-
  Econometrics (root module)

  Re-exports the submodules so `lake build` (default target) compiles the whole
  library. Benchmark snippets `import Econometrics.<Section>.<Module>` for a
  specific module, or `import Econometrics` for everything.

  * `Identification/` — an estimand is identified when it equals a functional of
    the observable distribution. Potential outcomes, and the designs that pin a
    causal parameter down.
-/

import Econometrics.Identification.PotentialOutcomes
import Econometrics.Identification.DiD
