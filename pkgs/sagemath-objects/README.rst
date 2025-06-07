============================================================================================================
 passagemath: Sage objects, elements, parents, categories, coercion, metaclasses
============================================================================================================

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

The pip-installable distribution package `sagemath-objects` is a
distribution of a small part of the Sage Library.

It provides a small, fundamental subset of the modules of the Sage library
("sagelib", `sagemath-standard`), making Sage objects, the element/parent
framework, categories, the coercion system and the related metaclasses
available.


Dependencies
------------

When building from source, development packages of `gmp`, `mpfr`, and `mpc` are needed.


Documentation
-------------

* `Categories <https://doc.sagemath.org/html/en/reference/categories/index.html>`_

* `Structure <https://doc.sagemath.org/html/en/reference/structure/index.html>`_

* `Coercion <https://doc.sagemath.org/html/en/reference/coercion/index.html>`_

* `Classes, Metaclasses <https://doc.sagemath.org/html/en/reference/misc/index.html#special-base-classes-decorators-etc>`_
