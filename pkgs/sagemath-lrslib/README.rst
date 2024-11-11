===============================================================================
passagemath: Reverse search for vertex enumeration and convex hulls with lrslib
===============================================================================

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

This pip-installable distribution ``passagemath-lrslib`` provides an interface
to `lrslib <http://cgm.cs.mcgill.ca/~avis/C/lrs.html>`_ by David Avis,
an implementation of the reverse search algorithm for vertex enumeration
and convex hull problems.


What is included
----------------

* Binary wheels on PyPI contain prebuilt copies of lrslib executables.


Examples
--------

Using lrslib programs on the command line::

    $ pipx run --pip-args="--prefer-binary" --spec "passagemath-lrslib" sage -sh -c lrs
    *lrs:lrslib v.7.1 2021.6.2(64bit,lrslong.h,hybrid arithmetic)

Finding the installation location of an lrslib program::

    $ pipx run --pip-args="--prefer-binary" --spec "passagemath-lrslib[test]" ipython

    In [1]: from sage.features.lrs import LrsNash

    In [2]: LrsNash().absolute_filename()
    Out[2]: '/Users/mkoeppe/.local/pipx/.cache/db3f5a0e2996f81/lib/python3.11/site-packages/sage_wheels/bin/lrsnash'

Use with `sage.game_theory <https://doc.sagemath.org/html/en/reference/game_theory/index.html>`_::

    $ pipx run --pip-args="--prefer-binary" --spec "passagemath-lrslib[test]" ipython

    In [1]: from sage.all__sagemath_lrslib import *

    In [2]: A = matrix([[1, -1], [-1, 1]]); B = matrix([[-1, 1], [1, -1]])

    In [3]: matching_pennies = NormalFormGame([A, B])

    In [4]: matching_pennies.obtain_nash(algorithm='lrs')
    Out[4]: [[(1/2, 1/2), (1/2, 1/2)]]
