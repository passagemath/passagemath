===============================================================================
passagemath: Finding cliques in graphs with cliquer
===============================================================================

`passagemath <https://github.com/passagemath/passagemath>`__ is open
source mathematical software in Python, released under the GNU General
Public Licence GPLv2+.

It is a fork of `SageMath <https://www.sagemath.org/>`__, which has been
developed 2005-2026 under the motto “Creating a Viable Open Source
Alternative to Magma, Maple, Mathematica, and MATLAB”.

The passagemath fork uses the motto "Creating a Free Passage Between the
Scientific Python Ecosystem and Mathematical Software Communities."
It was created in October 2024 with the following goals:

-  providing modularized installation with pip from binary wheels,
   - this major project was started in May 2020 in the Sage codebase and completed in passagemath 10.5.29 (May 2025),

-  establishing first-class membership in the scientific Python
   ecosystem,

-  giving `clear attribution of upstream
   projects <https://groups.google.com/g/sage-devel/c/6HO1HEtL1Fs/m/G002rPGpAAAJ>`__,

-  providing independently usable Python interfaces to upstream
   libraries,

-  offering `platform portability and integration testing
   services <https://github.com/passagemath/passagemath/issues/704>`__
   to upstream projects,

-  inviting collaborations with upstream projects,

-  `building a professional, respectful, inclusive
   community <https://groups.google.com/g/sage-devel/c/xBzaINHWwUQ>`__,

-  `empowering Sage users to participate in the scientific Python ecosystem
   <https://github.com/passagemath/passagemath/issues/248>`__ by publishing packages,

-  developing a port to WebAssembly (`Pyodide <https://pyodide.org/en/stable/>`__, emscripten-forge) for
   serverless deployment with Javascript,

-  developing a native Windows port
   - passagemath 10.6.1 (July 2025) published the first pip-installable wheel packages for native Windows on x86_64,
   - passagemath packages became available in the [MSYS2 software distribution](https://packages.msys2.org/search?t=pkg&q=passagemath) in November 2025.

Moreover, the passagemath project:

-  provides a stable, frequently updated version of the Sage distribution,
-  integrates additional mathematical software, notably Macaulay2, a full set of GAP packages,
   and the Combinatorial Matrix Recognition library,
-  curates a library of Sage user packages.

`Full documentation <https://passagemath.org/docs/latest/html/en/index.html>`__ is
available online.

passagemath attempts to support and provides binary wheels suitable for
all major Linux distributions and recent versions of macOS.

Binary wheels for native Windows (x86_64, ARM) are are available for a subset of
the passagemath distributions. Use of the full functionality of passagemath
on Windows currently requires the use of Windows Subsystem for Linux (WSL)
or virtualization.

The supported Python versions in the passagemath-10.8.x series are 3.11.x-3.14.x;
the passagemath-10.6.x series (EOL 2026-10) still supports Python 3.10.x.


About this pip-installable distribution package
-----------------------------------------------

This pip-installable distribution ``passagemath-cliquer`` provides an interface
to `cliquer <https://users.aalto.fi/~pat/cliquer.html>`_, an exact branch-and-bound
algorithm for finding cliques in an arbitrary weighted graph by Patric Östergård.


What is included
----------------

* `Cython interface to cliquer <https://passagemath.org/docs/latest/html/en/reference/graphs/sage/graphs/cliquer.html>`_


Examples
--------

::

   $ pipx run --pip-args="--prefer-binary" --spec "passagemath-cliquer[test]" ipython

   In [1]: from passagemath_cliquer import *

   In [2]: from sage.graphs.cliquer import max_clique

   In [3]: C = graphs.PetersenGraph(); max_clique(C)
   Out[3]: [7, 9]
