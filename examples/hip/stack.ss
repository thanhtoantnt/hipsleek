/* Port of VeriFast examples/aplas-stack.c */

data node {
  int val;
  node next;
}

data stack {
  node top;
}

ll<n> == self = null & n = 0
  or self::node<_, q> * q::ll<n-1>
  inv n >= 0;

stk<n> == self::stack<t> * t::ll<n>;

stack create()
  requires true
  ensures res::stk<0>;
{
  return new stack(null);
}

void push(stack s, int x)
  requires s::stk<n>
  ensures s::stk<n+1>;
{
  s.top = new node(x, s.top);
}

int pop(stack s)
  requires s::stk<n> & n > 0
  ensures s::stk<n-1>;
{
  int v = s.top.val;
  s.top = s.top.next;
  return v;
}
