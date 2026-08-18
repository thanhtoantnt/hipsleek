# HIP/SLEEK

Separation-logic verifier. HIP checks annotated C-like programs; SLEEK checks entailments.

Needs OCaml 4.14.1 (via opam) and Z3 on `PATH`.

## Build

```sh
opam switch create 4.14.1   # skip if you already have it
eval $(opam env --switch 4.14.1)
opam install . --deps-only -y
dune build
```

Binaries: `_build/default/hip.exe`, `_build/default/sleek.exe`.

## Run

Z3 is enough for the small examples. Put optional provers on `PATH` when you use them (see below).

```sh
dune exec ./hip.exe examples/hip/ll.ss
dune exec ./sleek.exe examples/sleek/sleek2.slk
```

More in [`examples/`](examples/).

## External provers (optional)

After each build, add the binary dir to `PATH`.

**Omega** (use real g++, not a clang shim):

```sh
(cd omega_modified && make oc CC=/usr/bin/g++)
export PATH="$PWD/omega_modified/omega_calc/obj:$PATH"
```

**Mona** (vendored in `mona-1.4/`):

```sh
(cd mona-1.4 && ./configure --prefix="$PWD" && make install)
cp mona-1.4/mona_predicates.mona .
export PATH="$PWD/mona-1.4/bin:$PATH"
```

**Fixcalc** (GHC 9.4.8; pin the clones):

```sh
cabal install --lib regex-compat old-time
cabal install happy
git clone https://github.com/hipsleek/omega_stub.git
(cd omega_stub && git checkout 60cdae42b429 && make)
git clone https://github.com/hipsleek/fixcalc.git fixcalc_src
(cd fixcalc_src && git checkout 7de7c55730f1 && make fixcalc)
export PATH="$PWD/fixcalc_src:$PATH"
```

## Tests

```sh
dune test
```

Or one case: `dune build @dune-tests/sleek/sleek2.t/runtest`.

Full local gate (opam + provers + `dune test`): `scripts/local-ci.sh`.

## Library

```sh
opam install .
```

More background: [docs](https://hipsleek.github.io/hipsleek/).
