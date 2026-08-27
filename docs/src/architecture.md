# Architecture

HIP/SLEEK is a separation-logic verifier written in OCaml (~200 modules).
Two binaries share one library:

- **hip** verifies whole annotated programs (`.ss`), checking each procedure
  against its specification.
- **sleek** checks individual entailments (`.slk`) — does one heap state
  imply another?

Both reduce to the same subproblem — *is this entailment valid?* — which is
why HIP calls SLEEK internally for every procedure call and loop invariant.

## The pipeline

```
source file (.ss / .c / .slk)
   │
   ├── hip:  parse → preprocess (prelude, lib files, inlining)
   │         → typecheck (`typechecker.ml`)
   │         → shape analysis (`sleekengine.ml`) + inference (`infer.ml`, `inferHP.ml`)
   │         → normalisation (`norm.ml`)
   │         → per-node entailment queries
   │
   └── sleek: parse → entailment check, one per query in the file
                    │
                    ▼
        entailment prover core (`solver.ml`, `fixpoint.ml`, `infer.ml`)
                    │
                    ▼
        pure-fragment SMT queries → external provers
```

External provers are dispatched by `src/tpdispatcher.ml` (`-tp` flag):

| Prover | Fragment | Built from |
|--------|----------|------------|
| z3 | default, nonlinear arithmetic + uninterpreted functions | system package |
| Omega (`oc`) | Presburger arithmetic | `omega_modified/`, `make oc` |
| Mona (`set`) | WS1S | `mona-1.4/`, `make` (file-based; `-tp mona` and the om/zm/cm/rm/prm combos were dropped until `mona_inter` exists, issues #36/#52; `parahip`/`auto` keep Mona bag paths) |
| fixcalc | fixed-point (recursive predicate) constraints | `fixcalc_src/` (Haskell) |
| redlog | quantifier elimination | system package |

Only z3 is required; the rest extend coverage.

## Repository layout

| Path | Contents |
|------|----------|
| `hip.ml`, `sleek.ml` | entry points (CLI, orchestration) |
| `common/` | shared library `hipsleek_common`: AST (`iast.ml`), core AST (`cast.ml`), heap formulae (`cformula.ml`, `cpure.ml`), lexer/parser (`lexer.mll`, `parser.ml`), pretty-printers (`iprinter.ml`, `cprinter.ml`), prover wrappers (`z3m.ml`, `coq.ml`, ...) |
| `src/` | analysis: `typechecker.ml`, `sleekengine.ml`, `infer.ml`, `inferHP.ml`, `solver.ml`, `norm.ml`, `fixpoint.ml`, `tpdispatcher.ml`, fixpoint grammar (`fixparser.mly`, `fixlexer.mll`) |
| `cil/` | vendored CIL 1.5.1 (`--parser cil` for C input) + `src/cilparser.ml` adapter |
| `api/` | SLEEK-as-a-library (`sleekapi.ml`, `api_prelude.ss`) |
| `prelude_src/` | built-in predicate library, installed as `prelude.ss` / `prelude.slk` |
| `dune-tests/` | cram regression tests (`.t/run.t`) |
| `examples/` | small runnable programs (see `examples/README.md`) |
| `omega_modified/` | Omega Calculator sources (vendored) |
| `mona-1.4/` | Mona sources (vendored) |
| `fixcalc_src/`, `omega_stub/` | fixcalc + Omega stub (git submodules) |
| `scripts/local-ci.sh` | local mirror of the former GitHub Actions job |

## Libraries (`dune`)

Three dune libraries, layered:

1. `hipsleek_common` (`common/`) — everything shared between hip and sleek.
2. `hipsleek.cil` (`cil/`) — CIL parser, depends on common.
3. `hipsleek` (`src/`, `hip.ml`, `sleek.ml`) — the binaries.

`common/parser.ml` is camlp5-based (dynamic grammar, `Grammar.gcreate`);
the fixpoint grammar in `src/` uses menhir. C input goes through CIL's own
ocamlyacc parser (`cil/cparser.mly`).

## Debug printing

The codebase is instrumented with `x_*` trace macros (now a plain module,
`common/xdebug.ml`): `x_add`, `x_tinfo_hp`, etc. They print proof states,
entailment attempts, and prover calls; enabled with `-pp` / `-pk` / `--trace`
style flags (see `hip --help`). Infer-style: `x_loc` maps to `__LOC__`.
