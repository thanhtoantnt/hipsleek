# Examples

Same idea as [VeriFast](https://github.com/verifast/verifast/tree/master/examples):
small annotated programs you can open and run.

```sh
# from the repo root, after `dune build`
dune exec ./hip.exe examples/hip/ll.ss
dune exec ./hip.exe examples/hip/append.ss
dune exec ./sleek.exe examples/sleek/sleek2.slk
dune exec ./hip.exe -- --parser cil examples/hip/incr.c
```

| File | What it is |
|------|------------|
| `hip/ll.ss` | Singly-linked list: length, append, reverse |
| `hip/append.ss` | List append with a precise spec |
| `hip/cell.ss` | VeriFast `cell.c`: get/set/inc/swap a heap cell |
| `hip/counter.ss` | VeriFast `counter.c`: increment and swap |
| `hip/swap.ss` | VeriFast `swap.c`: swap two point fields |
| `hip/stack.ss` | VeriFast `aplas-stack.c`: push/pop |
| `hip/reverse.ss` | Smallfoot: reverse a list in place |
| `hip/dll.ss` | Smallfoot: doubly-linked list insert |
| `hip/sll.ss` | sorted-list insert |
| `hip/tree.ss` | tree count + BST insert |
| `hip/cll.ss` | circular-list insert + count |
| `hip/incr.c` | C via CIL: incr / swap `int*` |
| `hip/abs.c` | Frama-C/ACSL: absolute value |
| `hip/max.c` | ACSL: max of two ints |
| `hip/sum.c` | recursive `1+...+n` |
| `hip/loop.c` | Frama-C WP: while-loop count |
| `sleek/sleek2.slk` | Entailment checks (Valid / Fail) |

The full regression suite (hundreds of cases) lives under `dune-tests/`.
