/* Recursive sum 1+...+n. HIP CIL demo, cleaned.
   hip --parser cil examples/hip/sum.c */

int sum(int n)
/*@
  case {
    n <= 0 -> requires true ensures res = 0;
    n >  0 -> requires true ensures res = n;
  }
*/
{
  if (n <= 0)
    return 0;
  else
    return sum(n - 1) + 1;
}
