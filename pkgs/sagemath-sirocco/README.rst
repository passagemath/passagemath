==================================================================================
 passagemath: Certified root continuation with sirocco
==================================================================================

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

This pip-installable distribution ``passagemath-sirocco`` provides a Cython interface
to the `sirocco <https://github.com/miguelmarco/SIROCCO2>`_ library for computing
topologically certified root continuation of bivariate polynomials.


What is included
----------------

* `sage.libs.sirocco <https://github.com/passagemath/passagemath/blob/main/src/sage/libs/sirocco.pyx>`_


Examples
--------

::

    $ pipx run --pip-args="--prefer-binary" --spec "passagemath-sirocco[test]" ipython

    In [1]: from sage.all__sagemath_sirocco import *

    In [2]: from sage.libs.sirocco import contpath

    In [3]: pol = list(map(RR,[0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]))

    In [4]: contpath(2, pol, RR(0), RR(0))
    Out[4]:
    [(0.0, 0.0, 0.0),
     (0.3535533905932738, -0.12500000000000003, 0.0),
     (0.7071067811865476, -0.5000000000000001, 0.0),
     (1.0, -1.0, 0.0)]
