===================================================================================================
passagemath: Computing in commutative algebra, algebraic geometry and related fields with Macaulay2
===================================================================================================

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
