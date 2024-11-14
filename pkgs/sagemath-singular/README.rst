================================================================================================================
 passagemath: Computer algebra, algebraic geometry, singularity theory with Singular
================================================================================================================

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

This pip-installable distribution ``passagemath-singular``
provides interfaces to [Singular](https://www.singular.uni-kl.de/),
the computer algebra system for polynomial computations, with
special emphasis on commutative and non-commutative algebra, algebraic
geometry, and singularity theory.

It also ships various modules of the Sage library that depend on Singular.


What is included
----------------

- `Cython interface to libSingular <https://doc.sagemath.org/html/en/reference/libs/index.html#libsingular>`_

- `pexpect interface to Singular <https://doc.sagemath.org/html/en/reference/interfaces/sage/interfaces/singular.html>`_

- various other modules, see https://github.com/passagemath/passagemath/blob/main/pkgs/sagemath-singular/MANIFEST.in

- The binary wheels published on PyPI include a prebuilt copy of Singular.


Examples
--------

Using Singular on the command line::

    $ pipx run --pip-args="--prefer-binary" --spec "passagemath-singular" sage -singular
                         SINGULAR                                 /
     A Computer Algebra System for Polynomial Computations       /   version 4.4.0
                                                               0<
     by: W. Decker, G.-M. Greuel, G. Pfister, H. Schoenemann     \   Apr 2024
    FB Mathematik der Universitaet, D-67653 Kaiserslautern        \
    >

Finding the installation location of the Singular executable::

    $ pipx run --pip-args="--prefer-binary" --spec "passagemath-singular[test]" ipython

    In [1]: from sage.features.singular import Singular

    In [2]: Singular().absolute_filename()
    Out[2]: '/Users/mkoeppe/.local/pipx/.cache/51651a517394201/lib/python3.11/site-packages/sage_wheels/bin/Singular'

Using the Cython interface to Singular::

    $ pipx run --pip-args="--prefer-binary" --spec "passagemath-singular[test]" ipython

    In [1]: from sage.all__sagemath_singular import *

    In [2]: from sage.libs.singular.function import singular_function

    In [3]: P = PolynomialRing(GF(Integer(7)), names=['a', 'b', 'c', 'd'])

    In [4]: I = sage.rings.ideal.Cyclic(P)

    In [5]: std = singular_function('std')

    In [6]: std(I)
    Out[6]: [a + b + c + d, b^2 + 2*b*d + d^2, b*c^2 + c^2*d - b*d^2 - d^3,
             b*c*d^2 + c^2*d^2 - b*d^3 + c*d^3 - d^4 - 1, b*d^4 + d^5 - b - d,
             c^3*d^2 + c^2*d^3 - c - d, c^2*d^4 + b*c - b*d + c*d - 2*d^2]
