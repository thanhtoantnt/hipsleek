/* Frama-C / ACSL classic: absolute value.
   hip --parser cil examples/hip/abs.c */

int abs(int x)
/*@
  case {
    x >= 0 -> requires true ensures res = x;
    x <  0 -> requires true ensures res = -x;
  }
*/
{
  if (x < 0)
    return -x;
  else
    return x;
}
