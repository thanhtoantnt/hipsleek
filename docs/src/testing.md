# Testing

Regression tests are [cram](https://dune.readthedocs.io/en/stable/tests.html#cram-tests)
tests under `dune-tests/`:

```
dune-tests/
├── hip/ll.t/          # one directory per program
│   ├── ll.ss          # the input
│   └── run.t          # cram script + expected output
├── sleek/sleek2.t/
└── dune               # copies postprocess scripts into scope
```

## Running

```sh
dune build @dune-tests/hip/ll.t/runtest        # one test
dune build @dune-tests/sleek/sleek2.t/runtest
```

`dune test` runs everything. Note: the Omega-backed tests race when run in
parallel; if you see flakes, run the specific tests sequentially as above.

Tests invoke the binaries with `../../../sleek.exe` / `../../../hip.exe` and
pipe through `sleek_postprocess.sh` / `hip_postprocess.sh` (in
`dune-tests/test_assets/`) which strip timing lines so output is
deterministic.

## Adding a test

1. `mkdir dune-tests/hip/mytest.t`
2. Copy `mytest.ss` in.
3. Write `run.t`:

   ```
     $ ../../../hip.exe mytest.ss | ../../hip_postprocess.sh
     Procedure append$node~node SUCCESS.
     ...
   ```

   (Run `dune build @.../runtest` once and paste the actual output — cram
   compares literally.)
4. Commit both files.

## Examples vs tests

`examples/` are curated, documented programs for humans (README, comments).
`dune-tests/` is the regression suite — hundreds of files, machine-checked.
When you add an example worth keeping, add a cram test for it too.
