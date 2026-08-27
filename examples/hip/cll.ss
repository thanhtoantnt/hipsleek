/* Smallfoot: circular list insert + count. */

data node {
  int val;
  node next;
}

cll<p, n> == self = p & n = 0
  or self::node<_, r> * r::cll<p, n-1> & self != p
  inv n >= 0;

hd<n> == self = null & n = 0
  or self::node<_, r> * r::cll<self, n-1>
  inv n >= 0;

void insert(node x, int v)
  requires x::hd<n> & n > 0
  ensures x::hd<n+1>;
{
  x.next = new node(v, x.next);
}

int count_rest(node rest, node h)
  requires rest::cll<p, n> & h = p
  ensures rest::cll<p, n> & res = n;
{
  if (rest == h)
    return 0;
  else
    return 1 + count_rest(rest.next, h);
}

int count(node x)
  requires x::hd<n>
  ensures x::hd<n> & res = n;
{
  if (x == null)
    return 0;
  else
    return 1 + count_rest(x.next, x);
}
