# Writing Specifications

The HIP input language (`.ss` files) is a small imperative language with
separation-logic annotations. A program is a set of data declarations,
predicate (view) definitions, and annotated procedures.

## Data and views

```hil
data node {
  int val;
  node next;
}

ll<n> == self = null & n = 0
  or self::node<_, q> * q::ll<n-1>
  inv n >= 0;
```

- `data node { ... }` declares a heap cell with fields.
- `ll<n>` is a **view** (inductive predicate). `self` is the receiver.
- `*` is the separating conjunction: two disjoint heap fragments.
- `inv` states the wellformedness invariant.
- `_` is a wildcard; lowercase names in the body are bound variables.

A heap formula `x::ll<n> * y::ll<m>` means: `x` points to a linked list of
length `n`, `y` to another, and the two lists do not share cells.

## Procedures

```hil
node insert(node x, int v)
  requires x::sll<n, sm, lg>
  ensures res::sll<n+1, mi, ma> & mi = min(v, sm) & ma = max(v, lg);
{
  if (x == null) return new node(v, null);
  else if (v <= x.val) return new node(v, x);
  else { x.next = insert(x.next, v); return x; }
}
```

- `requires` / `ensures` are the precondition / postcondition.
- Multiple requires/ensures pairs are treated as separate spec cases.
- `res` is the return value. Primed variable `x'` refers to the value of `x`
  in the post-state.
- `exists e: ...` binds existential results.

HIP reports `SUCCESS` per procedure when every path satisfies the spec.

## C input

HIP also accepts C through CIL (`cil/`) with annotations in `/*@ ... */`:

```c
void incr(int* x)
/*@
  requires x::int^<n>
  ensures x::int^<n+1>;
*/
{
  *x = *x + 1;
}
```

Run with `hip --parser cil file.c`. Pointer predicates use `t^<v>` shapes
(`int^`, `^^` for pointer-to-pointer); struct pointers are not yet supported
by the CIL path.

## SLEEK entailments (`.slk`)

SLEEK checks entailments directly:

```hil
x::node<v,p> * p::ll<n> & x!=null  |-  x::ll<n+1>
```

Each line reports `Valid` or `Fail` (with a counterexample).

## More

- `examples/` — runnable programs with a README
- [Core Language](./core.md) — grammar reference
- `prelude.ss` (from `prelude_src/`) — the built-in predicate library
