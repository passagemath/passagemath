========================================================================
 passagemath: Symbolic computation with GIAC
========================================================================

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

This pip-installable source distribution ``sagemath-giac`` provides a Cython
interface to GIAC.


What is included
----------------

- https://doc.sagemath.org/html/en/reference/libs/sage/libs/giac.html

- https://doc.sagemath.org/html/en/reference/interfaces/sage/interfaces/giac.html

- see https://github.com/passagemath/passagemath/blob/main/pkgs/sagemath-giac/MANIFEST.in


Examples
--------

A quick way to try it out interactively::

    $ pipx run --pip-args="--prefer-binary" --spec "passagemath-giac[test]" IPython

    In [1]: from sage.all__sagemath_modules import *

    In [2]: from sage.libs.giac import groebner_basis as gb_giac
