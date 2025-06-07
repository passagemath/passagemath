=============================================================================
 passagemath: Computational Group Theory with GAP
=============================================================================

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

This pip-installable distribution ``passagemath-gap`` is a small
distribution that provides modules that depend on the `GAP system <https://www.gap-system.org>`_.


What is included
----------------

- `Cython interface to libgap <https://doc.sagemath.org/html/en/reference/libs/sage/libs/gap/libgap.html>`_

- `Pexpect interface to GAP <https://doc.sagemath.org/html/en/reference/interfaces/sage/interfaces/gap.html>`_

- numerous modules with build-time dependencies on GAP, see `MANIFEST <https://github.com/passagemath/passagemath/blob/main/pkgs/sagemath-gap/MANIFEST.in>`_

- the binary wheels on PyPI ship a prebuilt copy of GAP


Examples
--------

A quick way to try it out interactively::

    $ pipx run --pip-args="--prefer-binary" --spec "passagemath-gap[test]" IPython

    In [1]: from sage.all__sagemath_modules import *

    In [2]: from sage.all__sagemath_gap import *

    In [3]: G = libgap.eval("Group([(1,2,3), (1,2)(3,4), (1,7)])")

    In [4]: CG = G.ConjugacyClasses()

    In [5]: gamma = CG[2]

    In [6]: g = gamma.Representative()

    In [7]: CG; gamma; g
    [ ()^G, (4,7)^G, (3,4,7)^G, (2,3)(4,7)^G, (2,3,4,7)^G, (1,2)(3,4,7)^G, (1,2,3,4,7)^G ]
    (3,4,7)^G
    (3,4,7)
