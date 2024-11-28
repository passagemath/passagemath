===================================================================================================
passagemath: Computing in commutative algebra, algebraic geometry and related fields with Macaulay2
===================================================================================================

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

This pip-installable distribution ``passagemath-macaulay2`` provides an interface to
`https://github.com/Macaulay2/M2 <Macaulay2>`_.


What is included
----------------

- `Python interface to Macaulay 2 <https://doc.sagemath.org/html/en/reference/interfaces/sage/interfaces/macaulay2.html>`_

- The binary wheels published on PyPI include a prebuilt copy of Macaulay 2.


Examples
--------

Using Macaulay 2 on the command line::

    $ pipx run --pip-args="--prefer-binary" --spec "passagemath-macaulay2" sage -sh -c 'M2'

Finding the installation location of Macaulay 2::

    $ pipx run --pip-args="--prefer-binary" --spec "passagemath-macaulay2[test]" ipython

    In [1]: from sage.features.macaulay2 import Macaulay2

    In [2]: Macaulay2().absolute_filename()
    Out[2]: '.../bin/M2'

Using the Python interface::

    $ pipx run --pip-args="--prefer-binary" --spec "passagemath-macaulay2[test]" ipython

    In [1]: from sage.all__sagemath_macaulay2 import *

    In [2]: R = macaulay2('QQ[x, y]'); R
    Out[2]: QQ[x..y]

    In [3]: S = R / macaulay2('ideal {x^2 - y}'); S
    Out[3]:
    QQ[x..y]
    --------
      2
     x  - y

    In [4]: S.gens()
    Out[4]: {x, y}
