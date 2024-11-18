=====================================================================================
passagemath: Special values of symmetric power elliptic curve L-functions with sympow
=====================================================================================

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

This pip-installable distribution ``passagemath-sympow`` provides an interface
to sympow.


What is included
----------------

* Binary wheels on PyPI contain prebuilt copies of the sympow executable and data files.


Examples
--------

Using the sympow program on the command line::

    $ pipx run --pip-args="--prefer-binary" --spec "passagemath-sympow" sage -sh -c sympow


Finding the installation location of the sympow executable::

    $ pipx run --pip-args="--prefer-binary" --spec "passagemath-sympow[test]" ipython

    In [1]: from sage.features.lrs import LrsNash

    In [2]: LrsNash().absolute_filename()
    Out[2]: '/Users/mkoeppe/.local/pipx/.cache/db3f5a0e2996f81/lib/python3.11/site-packages/sage_wheels/bin/lrsnash'
