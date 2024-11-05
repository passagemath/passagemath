============================================================================
passagemath: Polynomial system solving through algebraic methods with msolve
============================================================================

About SageMath
--------------

   "Creating a Viable Open Source Alternative to
    Magma, Maple, Mathematica, and MATLAB"

   Copyright (C) 2005-2024 The Sage Development Team

   https://www.sagemath.org

SageMath fully supports all major Linux distributions, recent versions of
macOS, and Windows (Windows Subsystem for Linux).

See https://doc.sagemath.org/html/en/installation/index.html
for general installation instructions.


About this pip-installable distribution package
-----------------------------------------------

This pip-installable source distribution ``sagemath-msolve`` provides an interface to `msolve <https://msolve.lip6.fr/>`_, which implements computer algebra algorithms for solving polynomial systems (with rational coefficients or coefficients in a prime field).


Examples
--------

A quick way to try it out interactively::

    $ pipx run --pip-args="--prefer-binary" --spec "passagemath-msolve[test]" ipython

    In [1]: from sage.all__sagemath_msolve import *

    In [2]: R = PolynomialRing(QQ, 2, names=['x', 'y'], order='lex')

    In [3]: x, y = R.gens()

    In [4]: I = Ideal([ x*y - 1, (x-2)**2 + (y-1)**2 - 1])

    In [5]: I.variety(RBF, algorithm='msolve', proof=False)
    Out[5]:
    [{x: [2.76929235423863 +/- 2.08e-15], y: [0.361103080528647 +/- 4.53e-16]},
     {x: 1.000000000000000, y: 1.000000000000000}]
