===============================================================================
passagemath: Interface to the SAT solver glucose
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

This pip-installable distribution ``passagemath-glucose`` provides an interface
to the SAT solver `glucose <http://www.labri.fr/perso/lsimon/glucose/>`_.


What is included
----------------

* Binary wheels on PyPI contain prebuilt copies of glucose executables.


Examples
--------

Using glucose programs on the command line::

    $ pipx run --pip-args="--prefer-binary" --spec "passagemath-glucose" sage -sh -c glucose

Finding the installation location of a glucose program::

    $ pipx run --pip-args="--prefer-binary" --spec "passagemath-glucose[test]" ipython

    In [1]: from sage.features.sat import Glucose

    In [2]: Glucose().absolute_filename()
    Out[2]: '.../bin/glucose'

Use with `sage.sat <https://doc.sagemath.org/html/en/reference/sat/index.html>`_::

    $ pipx run --pip-args="--prefer-binary" --spec "passagemath-glucose[test]" ipython

    In [1]: from sage.all__sagemath_glucose import *

    In [2]: from sage.sat.solvers.dimacs import Glucose

    In [3]: solver = Glucose(); solver.add_clause((1,2)); solver.add_clause((-1,2)); solver.add_clause((1,-2))

    In [4]: solver()
    Out[4]: (None, True, True)
