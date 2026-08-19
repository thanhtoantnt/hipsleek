/* VeriFast / ACSL: max of two ints.
   hip --parser cil examples/hip/max.c */

int max(int a, int b)
/*@
  case {
    a >= b -> requires true ensures res = a;
    a <  b -> requires true ensures res = b;
  }
*/
{
  if (a >= b)
    return a;
  else
    return b;
}
