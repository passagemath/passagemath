===========================================================================
passagemath: Lattice polytopes and applications to toric geometry with PALP
===========================================================================

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

This pip-installable source distribution ``passagemath-palp`` provides
an interface to the `Package for Analyzing Lattice Polytopes <http://hep.itp.tuwien.ac.at/~kreuzer/CY/CYpalp.html>` (PALP)
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

    In [1]: from sage.all__sagemath_polyhedra import *

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
