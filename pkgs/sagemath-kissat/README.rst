===============================================================================
passagemath: Interface to the SAT solver kissat
===============================================================================

`passagemath <https://github.com/passagemath/passagemath>`__ is open
source mathematical software in Python, released under the GNU General
Public Licence GPLv2+.

It is a fork of `SageMath <https://www.sagemath.org/>`__, which has been
developed 2005-2025 under the motto “Creating a Viable Open Source
Alternative to Magma, Maple, Mathematica, and MATLAB”.

The passagemath fork was created in October 2024 with the following
goals:

-  providing modularized installation with pip, thus completing a `major
   project started in 2020 in the Sage
   codebase <https://github.com/sagemath/sage/issues/29705>`__,
-  establishing first-class membership in the scientific Python
   ecosystem,
-  giving `clear attribution of upstream
   projects <https://groups.google.com/g/sage-devel/c/6HO1HEtL1Fs/m/G002rPGpAAAJ>`__,
-  providing independently usable Python interfaces to upstream
   libraries,
-  providing `platform portability and integration testing
   services <https://github.com/passagemath/passagemath/issues/704>`__
   to upstream projects,
-  inviting collaborations with upstream projects,
-  `building a professional, respectful, inclusive
   community <https://groups.google.com/g/sage-devel/c/xBzaINHWwUQ>`__,
-  developing a port to `Pyodide <https://pyodide.org/en/stable/>`__ for
   serverless deployment with Javascript,
-  developing a native Windows port.

`Full documentation <https://doc.sagemath.org/html/en/index.html>`__ is
available online.

passagemath attempts to support all major Linux distributions and recent versions of
macOS. Use on Windows currently requires the use of Windows Subsystem for Linux or
virtualization.

Complete sets of binary wheels are provided on PyPI for Python versions 3.9.x-3.12.x.
Python 3.13.x is also supported, but some third-party packages are still missing wheels,
so compilation from source is triggered for those.


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
