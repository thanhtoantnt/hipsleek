
## Building HIP and SLEEK

You will need opam and a recent OCaml compiler (tested on 4.14.1).

```sh
opam install . --deps-only
dune build
```

Try verifying some small programs.
You will need Z3 (from opam, pip, or a system package manager) on the PATH;
optional provers are [below](#installing-external-provers).

```sh
dune exec ./hip.exe dune-tests/hip/ll.t/ll.ss
dune exec ./sleek.exe dune-tests/sleek/sleek2.t/sleek2.slk
```

## Installing SLEEK as a library

```sh
opam install .
```

## Running tests

```sh
dune test
```

## Installing external provers

Other external provers HIP/SLEEK uses can be built from source.
They will be installed in their respective directories and should be made available on the PATH.

Here is an example .envrc file which makes all the provers available, after following the steps below to build each one:

```envrc
eval "$(opam env --switch=4.14.1 --set-switch)"
PATH_add omega_modified/omega_calc/obj
PATH_add mona-1.4/bin
PATH_add fixcalc_src
```

### Omega

```sh
(cd omega_modified; make oc)
```

### Mona

Mona source is vendored in `mona-1.4/`. Build it in place:

```sh
cd mona-1.4
make
cp mona_predicates.mona ..
cd -
```

Note: HIP's mona backend currently needs a `mona_inter` wrapper binary that
the build does not produce (issue #36); `-tp mona` has been removed until
that exists.

Try some tests:

```sh
./hip -tp z3 dune-tests/hip/ll.t/ll.ss
./sleek -tp z3 dune-tests/sleek/sleek2.t/sleek2.slk
```

### Fixcalc

You will need GHC 9.4.8.

```sh
cabal install --lib regex-compat old-time
cabal install happy
```

Build [Omega](#omega) first. Then, in the hipsleek project directory,

```sh
git clone https://github.com/hipsleek/omega_stub.git
(cd omega_stub; make)

git clone https://github.com/hipsleek/fixcalc.git fixcalc_src
(cd fixcalc_src; make fixcalc)
```
