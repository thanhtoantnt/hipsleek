/* VeriFast lists.c / Smallfoot: insert into a sorted list. */

data node {
  int val;
  node next;
}

sll<n, sm, lg> == self = null & n = 0 & sm <= lg
  or (exists qs, ql: self::node<qmin, q> * q::sll<n-1, qs, ql>
      & qmin <= qs & ql <= lg & sm <= qmin)
  inv n >= 0 & sm <= lg;

node insert(node x, int v)
  requires x::sll<n, sm, lg>
  ensures res::sll<n+1, mi, ma> & mi = min(v, sm) & ma = max(v, lg);
{
  if (x == null)
    return new node(v, null);
  else if (v <= x.val)
    return new node(v, x);
  else {
    x.next = insert(x.next, v);
    return x;
  }
}
