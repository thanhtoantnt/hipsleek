#!/usr/bin/env bash
# Local mirror of .github/workflows/test.yml (ubuntu-latest job).
# Idempotent: finished steps are skipped, safe to re-run.
# First run bootstraps opam + ghc (~30 min); later runs are just `dune test`.
set -euo pipefail
cd "$(dirname "$0")/.."

log() { printf '\n=== %s ===\n' "$1" >&2; }

# --- toolchain bootstrap (no sudo; mirrors CI's pinned versions) -----------
export PATH="$HOME/.local/bin:$HOME/.ghcup/bin:$HOME/.cabal/bin:$PATH"

if ! command -v opam >/dev/null; then
  log "installing opam 2.5.2"
  curl -sSL -o "$HOME/.local/bin/opam" https://github.com/ocaml/opam/releases/download/2.5.2/opam-2.5.2-x86_64-linux
  chmod +x "$HOME/.local/bin/opam"
fi

if ! command -v ghc >/dev/null || [ "$(ghc --numeric-version 2>/dev/null)" != 9.4.8 ]; then
  log "installing ghc 9.4.8 + cabal 3.10.3.0 (downloads.haskell.org)"
  # direct bindists, no ghcup: its metadata lives on raw.githubusercontent (flaky)
  if [ ! -x "$HOME/.local/ghc-9.4.8/bin/ghc" ]; then
    curl -sSL https://downloads.haskell.org/~ghc/9.4.8/ghc-9.4.8-x86_64-deb10-linux.tar.xz \
      | tar -xJ -C "$HOME/.local"
  fi
  if [ ! -x "$HOME/.local/ghc-9.4.8/bin/ghc" ]; then
    (cd "$HOME/.local/ghc-9.4.8-x86_64-unknown-linux" && ./configure --prefix="$HOME/.local/ghc-9.4.8" && make install)
  fi
  curl -sSL https://downloads.haskell.org/~cabal/cabal-install-3.10.3.0/cabal-install-3.10.3.0-x86_64-linux-deb11.tar.xz \
    | tar -xJ -C "$HOME/.local/bin"
fi
export PATH="$HOME/.local/ghc-9.4.8/bin:$PATH"

command -v z3 >/dev/null || { log "z3 missing - install it first"; exit 1; }

# --- opam deps (as CI: no depext, deps-only) -------------------------------
if ! opam switch list --short 2>/dev/null | grep -qx 4.14.1; then
  log "creating opam switch 4.14.1"
  # ponytail: sandboxing off, no bwrap on this machine; fine for a dev box
  opam init -a --disable-sandboxing --bare || true
  opam switch create 4.14.1
fi
eval $(opam env --switch 4.14.1)
opam install . --deps-only -y

# --- omega (vendored) --------------------------------------------------------
log "building omega"
(cd omega_modified && make oc)
export PATH="$PWD/omega_modified/omega_calc/obj:$PATH"

# --- mona (from committed tarball, as CI) ------------------------------------
if [ ! -x mona-1.4/bin/mona ]; then
  log "building mona"
  tar -xzf mona-1.4-modif.tar.gz
  (cd mona-1.4 && ./configure --prefix="$PWD" && make install)
fi
[ -f mona_predicates.mona ] || cp mona-1.4/mona_predicates.mona .
export PATH="$PWD/mona-1.4/bin:$PATH"

# --- fixcalc + haskell deps (pins match .github/workflows/test.yml) ----------
if ! ghc-pkg list --global-package-db >/dev/null 2>&1 \
   || ! ghc-pkg field regex-compat id >/dev/null 2>&1; then
  log "cabal lib deps"
  cabal update
  cabal install --lib regex-compat old-time
fi
command -v happy >/dev/null || cabal install happy

if [ ! -x fixcalc_src/fixcalc ]; then
  log "building fixcalc"
  rm -rf omega_stub fixcalc_src
  git clone https://github.com/hipsleek/omega_stub.git
  (cd omega_stub && git checkout 60cdae42b429 && make)
  git clone https://github.com/hipsleek/fixcalc.git fixcalc_src
  (cd fixcalc_src && git checkout 7de7c55730f1 && make fixcalc)
fi
export PATH="$PWD/fixcalc_src:$PATH"

# --- the actual CI step -------------------------------------------------------
log "dune test"
dune test
log "PASSED (local CI equivalent)"
