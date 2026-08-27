/* Port of VeriFast examples/counter.c */

data counter {
  int value;
}

counter init(int v)
  requires true
  ensures res::counter<v>;
{
  return new counter(v);
}

void increment(counter c)
  requires c::counter<v>
  ensures c::counter<v+1>;
{
  c.value = c.value + 1;
}

void swap(counter c1, counter c2)
  requires c1::counter<v1> * c2::counter<v2>
  ensures c1::counter<v2> * c2::counter<v1>;
{
  int t1 = c1.value;
  int t2 = c2.value;
  c1.value = t2;
  c2.value = t1;
}
