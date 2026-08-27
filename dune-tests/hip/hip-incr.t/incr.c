/* HIP can verify C via CIL:  hip --parser cil examples/hip/incr.c */

void incr(int* x)
/*@
  requires x::int^<n>
  ensures x::int^<n+1>;
*/
{
  *x = *x + 1;
}

void swap(int* a, int* b)
/*@
  requires a::int^<x> * b::int^<y>
  ensures a::int^<y> * b::int^<x>;
*/
{
  int t = *a;
  *a = *b;
  *b = t;
}
