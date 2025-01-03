# sage_setup: distribution = sagemath-repl
# sage.doctest: optional - sympy
r"""
TESTS:

Checking that sympy handles correctly Sage real numbers as
coefficients of polynomials (see :issue:`24380`)::

    sage: import sympy, sympy.polys
    sage: x = sympy.Symbol('x')
    sage: p = sympy.polys.Poly(x**2 - 2.0)
    sage: p
    Poly(1.0*x**2 - 2.0, x, domain='RR')
    sage: p.coeffs()
    [1.00000000000000, -2.00000000000000]
"""
