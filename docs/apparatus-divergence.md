# Apparatus divergence log

`tools/` and `tests/` in this repo are a **deliberate copy** of `formal-mathfin`'s,
taken at `b8ee67a`. The copy is the program's central timing rule made concrete:

> Extract exactly once, when library two starts. Not before, not after.
> — `formal-mathfin/docs/program-architecture.md` §4

Before is speculative generality (the seams get guessed wrong, and a wrong seam in
shared infrastructure is worse than duplication). After is a de-duplication across
two live corpora, each with its own drift. So library two runs on a copy, and this
file records what actually diverged. It is the **only input** to
`formal-mathfin/docs/plans/2026-08-09-program-execution/04-apparatus-genericize.md`,
which fires at ~20 entries here. A thin log makes that runbook unrunnable.

**The log is mechanical, not remembered.** Commit `dfced5f` is the verbatim copy,
untouched. Its diff against the next commit is this document's source:

```bash
git diff dfced5f <the adjustment commit> -- tools/ tests/
```

## Classification

Runbook 04 step 1 asks every touched line to be sorted into three buckets. Doing it
here, while the line is under the hand, is worth more than reconstructing it later.

- **(a) config that should come from the TOML** — the schema should have carried it
  and did not.
- **(b) a genuine parameter the config schema lacks** — needs a new key.
- **(c) a mathfin-ism special-cased in code** — a bug in the flagship, to be fixed
  there when 04 runs, not patched here.

### (a) Config that should come from the TOML

| Where | What | Note |
|---|---|---|
| `verify/config.py` | `MathFinConfig` → `EconometricsConfig`; the `["mathfin.toml", "pyproject.toml"]` search list; the `tool.mathfin` / `mathfin` table keys | The config loader is named after one corpus. The class name is cosmetic; the **search list and table key are not** — they are the reason a second corpus cannot simply point the same code at a different file |
| `verify/ledger.py` | the import regex `^\s*(?:public\s+)?import(?:\s+all)?\s+(MathFin(?:\.[A-Za-z0-9_]+)*)`; `EXEC_TMP = "MathFin/.ledger-exec-check.lean"` | Library namespace and Lake root, hardcoded into a regex and a path |
| `verify/axiom_audit_gen.py` | `GEN_PATH`; `PROOF_HEAD_RE`; `MATHFIN_NAME_RE`; the generated file's `import MathFin` / `namespace MathFin.AxiomAuditGen` header | Same namespace, five more times, including inside **generated Lean** |
| `tests/test_router.py`, `tests/test_values.py` | every `Path("MathFin").rglob("*.lean")` and `Path("MathFin/AxiomAudit.lean")` | The gates walk a hardcoded library root |
| `verify/cli.py` | `prog="mathfin-verify"`; `--config mathfin.toml` in the usage line | |

**The single largest item in this bucket is the `Domain` enum**
(`verify/models.py`). Eleven finance domains are spelled as Python code, and
`router.DEFAULT_ROUTING` repeats them. A benchmark file's domain is *corpus data* —
it belongs in the TOML with `Router` validating against the configured list. Here it
was replaced wholesale with `IDENTIFICATION`; in the flagship it should become
config-driven, and `mathfin.toml` should carry the routing table.

### (b) Genuine parameters the schema lacks

| Parameter | Needed because |
|---|---|
| library namespace (`MathFin` / `Econometrics`) | Consumed by the ledger's import regex, the audit generator's two regexes, and the generated audit's header. One value, five call sites |
| library root path | The gates rglob it; the ledger writes a temp file inside it |
| curated + generated audit paths | `AUDIT_PATH`, `GEN_PATH` |
| benchmarks dir | Currently a constant beside the ledger path |
| domain list / routing table | See above |
| whether a blueprint exists | `test_blueprint_spine_is_audited` assumes `<Lib>/Blueprint.lean` is present |

### (c) Mathfin-isms special-cased in code — bugs to fix in the flagship

1. **`tools/formalization_yaml.py` hardcodes the provenance narrative.** The
   editorial side-car `formalization_meta.toml` carries project, sources,
   `main_results`, reviewers and acknowledgements — but `automation.methods` is a
   hardcoded three-element list naming Leanstral, the `mathfin-foundry` pipeline and
   an AFP actuarial source, and the `status.scope` sentence hardcodes "continuous-time
   stochastic processes and mathematical finance, built on Mathlib + BrownianMotion".
   **A second corpus running this generator emits the flagship's provenance claims as
   its own.** In an artifact whose whole purpose is honest disclosure, that is the
   worst possible failure mode, and only a copy could have surfaced it. Fixed here by
   reducing the block to the one true method; the flagship fix is to move the whole
   narrative into `formalization_meta.toml`.
2. **`tools/verify/__init__.py` and `cli.py` describe the library in their own
   docstrings** ("quant-finance library", "formal-finance library"). Blanket renaming
   produced two sentences that were false about this repo. Description belongs in the
   TOML.
3. **`verify/lean_repl.py` documents a Docker daemon workflow that is repo-specific**
   (bind mounts, `scripts/lean-check.sh`, a `~5 min` Mathlib + BrownianMotion load).
   Harmless prose, but it is operational documentation living in library code.

## Deliberate omissions (not divergence — absences, recorded so they are evidence)

| Omitted | Why | Re-armed when |
|---|---|---|
| Docker / GHCR verify image | One import closure, no BrownianMotion; `lean-action` + the Mathlib cache server is the whole story at this size | The foundry targets this repo (runbook 06) |
| `LeanArchitect` + the blueprint | No spine to draw at one entry. `test_blueprint_spine_is_audited` is **retained and guarded** on the artifact's absence, not deleted | `Econometrics/Blueprint.lean` lands |
| `tools/blueprint_render.py` | Same | Same |
| `kernel-replay.yml`, `lint.yml`, `publish-image.yml` | Downstream of the two above | With them |
| HuggingFace dataset publication | `hf_dataset.py` was copied and renamed but no dataset exists; nothing publishes it | The corpus is worth publishing |
| `.gitattributes` ledger merge driver | Single-branch repo with one entry; the flagship needed it after a real merge dropped a row | The first parallel branch |

## Rule while the copy stands

**Record divergence; do not fix it upstream yet.** Every line of copied tooling
touched from here on gets a row above, classified. Category (c) items are flagship
bugs and get fixed there when runbook 04 runs — patching them here would destroy the
evidence that motivates the fix.
