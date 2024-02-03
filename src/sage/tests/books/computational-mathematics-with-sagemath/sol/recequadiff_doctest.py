# sage_setup: distribution = sagemath-repl
"""
This file (./sol/recequadiff_doctest.sage) was *autogenerated* from ./sol/recequadiff.tex,
with sagetex.sty version 2011/05/27 v2.3.1.
It contains the contents of all the sageexample environments from this file.
You should be able to doctest this file with:
sage -t ./sol/recequadiff_doctest.sage
It is always safe to delete this file; it is not used in typesetting your
document.

Sage example in ./sol/recequadiff.tex, line 16::

  sage: x = var('x')
  sage: y = function('y')(x)
  sage: ed = (desolve(y*diff(y,x)/sqrt(1+y^2) == sin(x),y)); ed
  sqrt(y(x)^2 + 1) == _C - cos(x)

Sage example in ./sol/recequadiff.tex, line 27::

  sage: c = ed.variables()[0]
  sage: assume(c-cos(x) > 0)
  sage: sol = solve(ed,y) ; sol
  [y(x) == -sqrt(_C^2 - 2*_C*cos(x) + cos(x)^2 - 1),
   y(x) == sqrt(_C^2 - 2*_C*cos(x) + cos(x)^2 - 1)]

Sage example in ./sol/recequadiff.tex, line 34::

  sage: P = Graphics()
  sage: for j in [0,1]:
  ....:   for k in range(0,20,2):
  ....:     P += plot(sol[j].substitute(c==2+0.25*k).rhs(),x,-3,3)
  sage: P
  Graphics object consisting of 20 graphics primitives

Sage example in ./sol/recequadiff.tex, line 52::

  sage: sol = desolve(diff(y,x)==sin(x)/cos(y), y, show_method=True)
  sage: sol
  [sin(y(x)) == _C - cos(x), 'separable']
  sage: solve(sol[0],y)
  [y(x) == -arcsin(-_C + cos(x))]

Sage example in ./sol/recequadiff.tex, line 80::

  sage: x = var('x')
  sage: y = function('y')(x)
  sage: id(x) = x
  sage: u = function('u')(x)
  sage: d = diff(u*id,x)
  sage: DE = (x*y*d == x**2+y**2).substitute(y == u*id)
  sage: eq = desolve(DE,u)
  sage: sol = solve(eq,u)
  sage: sol
  [u(x) == -sqrt(2*_C + 2*log(x)), u(x) == sqrt(2*_C + 2*log(x))]
  sage: Y = [x*sol[0].rhs() , x*sol[1].rhs()]
  sage: Y[0]
  -sqrt(2*_C + 2*log(x))*x

"""
