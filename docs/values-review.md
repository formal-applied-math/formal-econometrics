# Values review — the judgment lenses, and what each round found

The eight lenses are read as **gradients**, not as a scorecard: for each one, the
current exemplar and the next concrete upgrade that would raise its ceiling. The
output of a round is a ranked backlog plus the upgrades executed that round. It is
never "8/8 PASS" — a green checkmark is how a disciplined library quietly settles
into being a fine dump.

The judgment is human/agent. The **cadence** is machine-enforced:
`tests/test_values.py::test_values_review_is_current` fails once the corpus outgrows
the newest recorded verdict by more than 12 entries. That gate asks "did anyone
look", not "is it good".

Every round opens with the same standing first pass: **read the prose against its
own statement.** For every docstring, corpus `description` and doc paragraph the
round touched, ask whether it claims more than the Lean proves. It is the one
failure the other gates structurally cannot see, because the build is green
precisely when the statement is weaker than the prose.

---

## 2026-08-10 — corpus 1 — phase 0, first verdict

**Standing first pass — and it fired.** The `Observed` structure omits the potential
outcomes, so `didContrast` provably reads no counterfactual. The first draft of
every docstring, and of the benchmark `description`, said something stronger: "a
functional of the observed data alone". That is not what the statement proves —
both sides take the population measure `μ` on the same `Ω` that carries the
counterfactuals, so what is enforced is *reads no counterfactual*, not *depends only
on the observable law*. Corrected in the module docstrings, the theorem docstring,
the corpus `description` and `metadata.formalization_scope` before anything was
committed. The strengthening is backlog item **B1** below, not a claim.

Recording it because the pattern is the point: the prose described the theorem the
author had in mind, the statement quietly said less, and the build was green
throughout.

### The lenses, as gradients

| Lens | Where it stands at one theorem | The next upgrade that raises the ceiling |
|---|---|---|
| **Inspired math** | The identification claim is carried by the *type discipline* — `att : Model → ℝ` against `didContrast : Observed → ℝ` — rather than by a side condition. The theorem is then literally "these two agree" | Make `Observed` carry the observable **law** rather than functions on `Ω`. Then identification becomes a statement about pushforwards and the type does the whole job (**B1**) |
| **Mathlib coherence** | Consumes `ProbabilityTheory.cond`, `ae_cond_mem`, `integral_sub`, `integral_congr_ae`, `Set.indicator` directly. Nothing is re-derived. One adapter lemma, three lines | Upstream that adapter (`MeasureTheory.Integrable.cond`) instead of carrying it (**B2**) |
| **Zero slop** | 3 definitions, 1 estimand, 1 restriction, 2 bridge lemmas, 1 theorem. No dead hypotheses: each of the five is consumed | Check whether `hT : MeasurableSet m.treated` can be dropped for the control-side bridge by using `NullMeasurableSet` (**B5**) |
| **Architectural ingenuity** | `Model.observed` is a *definition*, so the realization rule is a theorem-side obligation rather than a hypothesis; the two "observed = potential" identities are **derived**, not assumed. Most informal treatments assume them | Same trick for the IV/LATE exclusion restriction when it lands |
| **First principles** | Parallel trends is stated on `Y false` in both groups — a restriction on counterfactuals, which is exactly why it is untestable and must be assumed. The proof is linearity plus one substitution; nothing is hidden in a tactic | — |
| **Idiomatic register** | Bare proof terms for both bridge lemmas (`condMean_congr_ae <| (ae_cond_mem hT).mono fun ω hω ↦ …`); `↦` throughout; minimal typeclasses (`MeasurableSpace`, no `IsProbabilityMeasure`); no `classical` | The final theorem still ends `simp only … ; rw … ; linarith`. A `calc` would show the algebra instead of discharging it (**B3**) |
| **Concept clarity** | `condMean` names the field's central object, so statements read as econometrics rather than as integrals. `Period` is an inductive, not a `Bool` pretending to be one | A blueprint spine, once there is more than one node to draw (**B4**) |
| **Beautiful math** | The proof is four rewrites and `linarith`: two a.e. identities, one integral splitting, one substitution. That the whole content is "parallel trends lets you replace one unobservable with an observable" is visible in the proof, not buried | — |

### Ranked backlog

1. **B1 — identification over the observable law.** Restate `Observed` (or add an
   `ObservedLaw`) as the pushforward of `(outcome, treated)`, and make `didContrast`
   a functional of it. This closes the gap the standing pass found and is the single
   upgrade that makes the library's central claim fully type-enforced. Phase 1,
   before IV/LATE, because every later design inherits the carrier.
2. **B2 — upstream `MeasureTheory.Integrable.cond`.** Field-neutral, three lines,
   genuinely absent from Mathlib. The first `ForMathlib/` candidate the program has
   produced, and much smaller than the Brouwer tower runbook 05 expected.
3. **B3 — `calc` in `att_eq_didContrast`.** The algebra is a four-step chain; ending
   in `linarith` hides it. Cheap, and it is the difference between a proof that
   checks and a proof that explains.
4. **B4 — a blueprint spine.** Deferred honestly: one node is not a graph.
   `test_blueprint_spine_is_audited` is retained and guarded so it re-arms the moment
   `Blueprint.lean` lands.
5. **B5 — drop `MeasurableSet` if `NullMeasurableSet` suffices.** `ae_cond_mem₀`
   exists; check whether the bridges can consume it.

### Executed this round

- The prose-vs-statement correction above (four sites).
- `MeasureTheory.Integrable.cond` declared in Mathlib's own namespace rather than
  ours, so dot-notation resolves and the upstream move is a file move.
- `Model.observed` written with `Set.indicator` rather than `if`, removing a
  decidability obligation from every downstream statement.
