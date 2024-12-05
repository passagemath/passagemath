==================================================================================
 passagemath: Certified root continuation with sirocco
==================================================================================

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


About this pip-installable distribution
---------------------------------------

This pip-installable distribution ``passagemath-sirocco`` provides a Cython interface
to the `sirocco <https://github.com/miguelmarco/SIROCCO2>`_ library for computing
topologically certified root continuation of bivariate polynomials.


What is included
----------------

* `sage.libs.sirocco <https://github.com/passagemath/passagemath/blob/main/src/sage/libs/sirocco.pyx>`_


Examples
--------

::

    $ pipx run --pip-args="--prefer-binary" --spec "passagemath-sirocco[test]" ipython

    In [1]: from sage.all__sagemath_sirocco import *

    In [2]: from sage.libs.sirocco import contpath

    In [3]: pol = list(map(RR,[0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]))

    In [4]: contpath(2, pol, RR(0), RR(0))
    Out[4]:
    [(0.0, 0.0, 0.0),
     (0.3535533905932738, -0.12500000000000003, 0.0),
     (0.7071067811865476, -0.5000000000000001, 0.0),
     (1.0, -1.0, 0.0)]
