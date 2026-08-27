/* Smallfoot / Berdine: binary tree count + BST insert. */

data node2 {
  int val;
  node2 left;
  node2 right;
}

tree1<m> == self = null & m = 0
  or self::node2<_, p, q> * p::tree1<m1> * q::tree1<m2> & m = 1 + m1 + m2
  inv m >= 0;

bst<sm, lg> == self = null & sm <= lg
  or (exists pl, qs: self::node2<v, p, q> * p::bst<sm, pl> * q::bst<qs, lg>
      & pl <= v & qs >= v)
  inv sm <= lg;

int count(node2 z)
  requires z::tree1<m>
  ensures z::tree1<m> & res = m;
{
  if (z == null)
    return 0;
  else
    return 1 + count(z.left) + count(z.right);
}

node2 insert(node2 x, int a)
  requires x::bst<sm, lg>
  ensures res::bst<mi, ma> & res != null & mi = min(sm, a) & ma = max(lg, a);
{
  if (x == null)
    return new node2(a, null, null);
  else {
    if (a <= x.val)
      x.left = insert(x.left, a);
    else
      x.right = insert(x.right, a);
    return x;
  }
}
