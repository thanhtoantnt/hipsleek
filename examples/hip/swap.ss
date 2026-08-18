/* Port of VeriFast examples/swap.c (point_mirror). */

data point {
  int x;
  int y;
}

void swap_fields(point p)
  requires p::point<a,b>
  ensures p::point<b,a>;
{
  int t = p.x;
  p.x = p.y;
  p.y = t;
}

void point_mirror(point p)
  requires p::point<x,y>
  ensures p::point<y,x>;
{
  swap_fields(p);
}
