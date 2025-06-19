===============================================================================
passagemath: Reverse search for vertex enumeration and convex hulls with lrslib
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

This pip-installable distribution ``passagemath-lrslib`` provides an interface
to `lrslib <http://cgm.cs.mcgill.ca/~avis/C/lrs.html>`_ by David Avis,
an implementation of the reverse search algorithm for vertex enumeration
and convex hull problems.


What is included
----------------

* Binary wheels on PyPI contain prebuilt copies of lrslib executables.


Examples
--------

Using lrslib programs on the command line::

    $ pipx run --pip-args="--prefer-binary" --spec "passagemath-lrslib" sage -sh -c lrs
    *lrs:lrslib v.7.1 2021.6.2(64bit,lrslong.h,hybrid arithmetic)

Finding the installation location of an lrslib program::

    $ pipx run --pip-args="--prefer-binary" --spec "passagemath-lrslib[test]" ipython

    In [1]: from sage.features.lrs import LrsNash

    In [2]: LrsNash().absolute_filename()
    Out[2]: '/Users/mkoeppe/.local/pipx/.cache/db3f5a0e2996f81/lib/python3.11/site-packages/sage_wheels/bin/lrsnash'

Use with `sage.game_theory <https://doc.sagemath.org/html/en/reference/game_theory/index.html>`_::

    $ pipx run --pip-args="--prefer-binary" --spec "passagemath-lrslib[test]" ipython

    In [1]: from sage.all__sagemath_lrslib import *

    In [2]: A = matrix([[1, -1], [-1, 1]]); B = matrix([[-1, 1], [1, -1]])

    In [3]: matching_pennies = NormalFormGame([A, B])

    In [4]: matching_pennies.obtain_nash(algorithm='lrs')
    Out[4]: [[(1/2, 1/2), (1/2, 1/2)]]
