===============================================================================
passagemath: Algorithms for Rubik's cube
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
