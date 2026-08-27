/* Port of VeriFast examples/cell.c
   A heap cell: create, get, set, inc, swap. */

data cell {
  int val;
}

cell create()
  requires true
  ensures res::cell<0>;
{
  return new cell(0);
}

void cell_set(cell c, int v)
  requires c::cell<_>
  ensures c::cell<v>;
{
  c.val = v;
}

void inc(cell c, int v)
  requires c::cell<x>
  ensures c::cell<x+v>;
{
  c.val = c.val + v;
}

int cell_get(cell c)
  requires c::cell<v>
  ensures c::cell<v> & res = v;
{
  return c.val;
}

void swap(cell c1, cell c2)
  requires c1::cell<v1> * c2::cell<v2>
  ensures c1::cell<v2> * c2::cell<v1>;
{
  int t1 = cell_get(c1);
  int t2 = cell_get(c2);
  cell_set(c1, t2);
  cell_set(c2, t1);
}
