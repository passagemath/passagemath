===============================================================================
passagemath: Interface to the SAT solver kissat
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

This pip-installable distribution ``passagemath-kissat`` provides an interface
to the SAT solver `kissat <https://fmv.jku.at/kissat/>`_, a condensed and improved
reimplementation of CaDiCaL in C.


What is included
----------------

* Binary wheels on PyPI contain prebuilt copies of the kissat executable.


Examples
--------

Using kissat programs on the command line::

    $ pipx run --pip-args="--prefer-binary" --spec "passagemath-kissat" sage -sh -c kissat

Finding the installation location of the kissat program::

    $ pipx run --pip-args="--prefer-binary" --spec "passagemath-kissat[test]" ipython

    In [1]: from sage.features.sat import Kissat

    In [2]: Kissat().absolute_filename()
    Out[2]: '.../bin/kissat'

Use with `sage.sat <https://doc.sagemath.org/html/en/reference/sat/index.html>`_::

    $ pipx run --pip-args="--prefer-binary" --spec "passagemath-kissat[test]" ipython

    In [1]: from sage.all__sagemath_kissat import *

    In [2]: from sage.sat.solvers.dimacs import Kissat

    In [3]: solver = Kissat(); solver.add_clause((1,2)); solver.add_clause((-1,2)); solver.add_clause((1,-2))

    In [4]: solver()
    Out[4]: (None, True, True)
