==============================================================================================
 passagemath: Elliptic curves over the rationals with eclib/mwrank
==============================================================================================

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

This pip-installable source distribution ``passagemath-eclib`` provides the
Sage interface to John Cremona's programs for enumerating and computing with elliptic curves
defined over the rational numbers.


Examples
--------

A quick way to try it out interactively::

    $ pipx run --pip-args="--prefer-binary" --spec "passagemath-eclib[test]" IPython

    In [1]: from sage.all__sagemath_eclib import *


Development
-----------

::

    $ git clone --origin passagemath https://github.com/passagemath/passagemath.git
    $ cd passagemath
    passagemath $ ./bootstrap
    passagemath $ python3 -m venv eclib-venv
    passagemath $ source eclib-venv/bin/activate
    (eclib-venv) passagemath $ pip install -v -e pkgs/sagemath-eclib
