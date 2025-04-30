=============================================================================================================================================
 passagemath: Schemes, varieties, elliptic curves, algebraic Riemann surfaces, modular forms, arithmetic dynamics
=============================================================================================================================================

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
-----------------------------------------------------------

This pip-installable source distribution `sagemath-schemes` is an experimental distribution of a part of the Sage Library.  Use at your own risk.  It provides a small subset of the modules of the Sage library ("sagelib", `sagemath-standard`).


What is included
----------------

* `Ideals and Varieties <https://doc.sagemath.org/html/en/reference/polynomial_rings/sage/rings/polynomial/multi_polynomial_ideal.html>`_

* `Schemes <https://doc.sagemath.org/html/en/reference/schemes/index.html>`_

* `Plane and Space Curves <https://doc.sagemath.org/html/en/reference/curves/index.html>`_

* `Elliptic and Hyperelliptic Curves <https://doc.sagemath.org/html/en/reference/arithmetic_curves/index.html>`_

* `Modular Forms <https://doc.sagemath.org/html/en/reference/modfrm/index.html>`_

* `Modular Symbols <https://doc.sagemath.org/html/en/reference/modsym/index.html>`_

* `Modular Abelian Varieties <https://doc.sagemath.org/html/en/reference/modabvar/index.html>`_

* `Arithmetic Dynamical Systems <https://doc.sagemath.org/html/en/reference/dynamics/index.html#arithmetic-dynamical-systems>`_


Status
------

The wheel builds. Some Cython modules that depend on FLINT or NTL are excluded.

`sage.all__sagemath_schemes` can be imported.

Many tests fail; see ``known-test-failures.json``.
