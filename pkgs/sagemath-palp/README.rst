===========================================================================
passagemath: Lattice polytopes and applications to toric geometry with PALP
===========================================================================

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

This pip-installable source distribution ``passagemath-palp`` provides
an interface to the `Package for Analyzing Lattice Polytopes <http://hep.itp.tuwien.ac.at/~kreuzer/CY/CYpalp.html>`__ (PALP)
by M. Kreuzer and H. Skarke, a set of C programs for calculations
with lattice polytopes and applications to toric geometry.


What is included
----------------

- The binary wheels published on PyPI include a prebuilt copy of PALP.


Examples
--------

Using PALP programs on the command line::

    $ pipx run --pip-args="--prefer-binary" --spec "passagemath-palp" sage -sh -c 'echo "14 2 3 4 5" | class.x -f -po zbin'
    0kR-0 0MB 0kIP 0kNF-0k 5_13 v8r8 f10r10 10b6 0s 0u 0n
    14 2 3 4 5 R=152 +0sl hit=0 IP=276 NF=179 (0)
    Writing zbin: 152+0sl 0m+0s 644b  u36 done: 0s

Finding the installation location of a PALP program::

    $ pipx run --pip-args="--prefer-binary" --spec "passagemath-palp[test]" ipython

    In [1]: from sage.features.palp import PalpExecutable

    In [2]: PalpExecutable("poly", 5).absolute_filename()
    Out[2]: '/Users/mkoeppe/.local/pipx/.cache/db3f5a0e2996f81/lib/python3.11/site-packages/sage_wheels/bin/poly-5d.x'

Use with sage.geometry::

    $ pipx run --pip-args="--prefer-binary" --spec "passagemath-palp[test]" ipython

    In [1]: from passagemath_polyhedra import *

    In [2]: square = lattice_polytope.cross_polytope(2).polar()

    In [3]: square.points()
    Out[3]:
    N( 1,  1),
    N( 1, -1),
    N(-1, -1),
    N(-1,  1),
    N(-1,  0),
    N( 0, -1),
    N( 0,  0),
    N( 0,  1),
    N( 1,  0)
    in 2-d lattice N
