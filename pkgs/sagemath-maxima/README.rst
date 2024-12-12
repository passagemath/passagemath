===========================================================
 passagemath: Symbolic calculus with maxima
===========================================================

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

This pip-installable distribution ``passagemath-maxima`` provides
interfaces to `Maxima <https://doc.sagemath.org/html/en/reference/spkg/maxima.html>`_.


What is included
----------------

* Binary wheels on PyPI contain prebuilt copies of `Maxima <https://doc.sagemath.org/html/en/reference/spkg/maxima.html>`_.


Examples
--------

Starting Maxima from the command line::

    $ pipx run --pip-args="--prefer-binary" --spec "passagemath-maxima" sage -maxima

Using the pexpect interface to Maxima::

    $ pipx run --pip-args="--prefer-binary" --spec "passagemath-maxima[test]" ipython

    In [1]: from sage.interfaces.maxima import maxima

    In [2]: maxima('1+1')
    Out[2]: 2

Using the library interface to Maxima::

    $ pipx run --pip-args="--prefer-binary" --spec "passagemath-maxima[test]" ipython

    In [1]: from sage.interfaces.maxima_lib import maxima_lib

    In [2]: F = maxima_lib('x^5 - y^5').factor()

    In [3]: F.display2d()
    Out[3]:
                               4      3    2  2    3      4
                   - (y - x) (y  + x y  + x  y  + x  y + x )
