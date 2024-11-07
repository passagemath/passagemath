====================================================================================
 passagemath: Fast computations with MPFI and FLINT
====================================================================================

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


About this pip-installable source distribution
----------------------------------------------

This pip-installable source distribution ``sagemath-flint`` provides
Cython interfaces to the ``MPFI`` and ``FLINT`` libraries.

It also ships the implementation of number fields.


What is included
----------------

* see https://github.com/passagemath/passagemath/blob/main/pkgs/sagemath-flint/MANIFEST.in


Examples
--------

A quick way to try it out interactively::

    $ pipx run --pip-args="--prefer-binary" --spec "passagemath-flint[test]" ipython
    In [1]: from sage.all__sagemath_flint import *

    In [2]: RealBallField(128).pi()
    Out[2]: [3.1415926535897932384626433832795028842 +/- 1.06e-38]


Development
-----------

::

    $ git clone --origin passagemath https://github.com/passagemath/passagemath.git
    $ cd passagemath
    passagemath $ ./bootstrap
    passagemath $ python3 -m venv flint-venv
    passagemath $ source flint-venv/bin/activate
    (flint-venv) passagemath $ pip install -v -e pkgs/sagemath-flint
