=============================================================================
 passagemath: Computational Group Theory with GAP
=============================================================================

`passagemath <https://github.com/passagemath/passagemath>`__ is open
source mathematical software in Python, released under the GNU General
Public Licence GPLv2+.

It is a fork of `SageMath <https://www.sagemath.org/>`__, which has been
developed 2005-2025 under the motto “Creating a Viable Open Source
Alternative to Magma, Maple, Mathematica, and MATLAB”.

The passagemath fork uses the motto "Creating a Free Passage Between the
Scientific Python Ecosystem and Mathematical Software Communities."
It was created in October 2024 with the following goals:

-  providing modularized installation with pip,
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
-  developing a port to `Pyodide <https://pyodide.org/en/stable/>`__ for
   serverless deployment with Javascript,
-  developing a native Windows port.

`Full documentation <https://doc.sagemath.org/html/en/index.html>`__ is
available online.

passagemath attempts to support and provides binary wheels suitable for
all major Linux distributions and recent versions of macOS.

For the Linux aarch64 (ARM) platform, some third-party packages are still missing
wheels; see the `instructions for building them from source <https://github.com/passagemath/passagemath?tab=readme-ov-file#full-installation-of-passagemath-from-binary-wheels-on-pypi>`__.

Binary wheels for native Windows (x86_64) are are available for a subset of
the passagemath distributions. Use of the full functionality of passagemath
on Windows currently requires the use of Windows Subsystem for Linux (WSL)
or virtualization.

The supported Python versions in the passagemath 10.6.x series are 3.10.x-3.13.x.


About this pip-installable distribution package
-----------------------------------------------

This pip-installable distribution ``passagemath-gap`` is a small
distribution that provides modules that depend on the `GAP system <https://www.gap-system.org>`_.


What is included
----------------

- `Cython interface to libgap <https://passagemath.org/docs/latest/html/en/reference/libs/sage/libs/gap/libgap.html>`_

- `Pexpect interface to GAP <https://passagemath.org/docs/latest/html/en/reference/interfaces/sage/interfaces/gap.html>`_

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
