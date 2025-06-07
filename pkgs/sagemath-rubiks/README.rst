===============================================================================
passagemath: Algorithms for Rubik's cube
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

Complete sets of binary wheels are provided on PyPI for Python versions 3.10.x-3.13.x.
Python 3.13.x is also supported, but some third-party packages are still missing wheels,
so compilation from source is triggered for those.


About this pip-installable distribution package
-----------------------------------------------

This pip-installable distribution ``passagemath-rubiks`` provides an interface
to several programs for working with Rubik's cubes.

Michael Reid (GPL) http://www.cflmath.com/~reid/Rubik/optimal_solver.html

-  optimal - uses many pre-computed tables to find an optimal
   solution to the 3x3x3 Rubik's cube

Dik T. Winter (MIT License)

-  cube - uses Kociemba's algorithm to iteratively find a short
   solution to the 3x3x3 Rubik's cube
-  size222 - solves a 2x2x2 Rubik's cube

Eric Dietz (GPL) https://web.archive.org/web/20121212175710/http://www.wrongway.org/?rubiksource

-  cu2 - A fast, non-optimal 2x2x2 solver
-  cubex - A fast, non-optimal 3x3x3 solver
-  mcube - A fast, non-optimal 4x4x4 solver


What is included
----------------

* `Interface <https://doc.sagemath.org/html/en/reference/interfaces/sage/interfaces/rubik.html#module-sage.interfaces.rubik>`_

* `Features <https://doc.sagemath.org/html/en/reference/spkg/sage/features/rubiks.html#module-sage.features.rubiks>`_ (via passagemath-environment)

* Binary wheels on PyPI contain prebuilt copies of rubiks executables.


Examples
--------

Using rubiks programs on the command line::

    $ pipx run --pip-args="--prefer-binary" --spec "passagemath-rubiks" sage -sh -c cubex


Finding the installation location of a rubiks program::

    $ pipx run --pip-args="--prefer-binary" --spec "passagemath-rubiks[test]" ipython

    In [1]: from sage.features.rubiks import cubex

    In [2]: cubex().absolute_filename()


Using the Python interface::

    $ pipx run --pip-args="--prefer-binary" --spec "passagemath-rubiks[test]" ipython

    In [1]: from sage.interfaces.rubik import *

    In [2]: C = RubiksCube("R U F L B D")

    In [3]: sol = CubexSolver().solve(C.facets()); sol
    Out[3]: "U' L' L' U L U' L U D L L D' L' D L' D' L D L' U' L D' L' U L' B' U' L' U B L D L D' U' L' U L B L B' L' U L U' L' F' L' F L' F L F' L' D' L' D D L D' B L B' L B' L B F' L F F B' L F' B D' D' L D B' B' L' D' B U' U' L' B' D' F' F' L D F'"


Using sage.groups.perm_gps::

    $ pipx run --pip-args="--prefer-binary" --spec "passagemath-rubiks[test]" ipython

    In [1]: from sage.all__sagemath_rubiks import *

    In [2]: rubik = CubeGroup(); state = rubik.faces("R")

    In [3]: rubik.solve(state)
    Out[3]: 'R'
