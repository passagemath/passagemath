=============================================================================
 passagemath: Braid computations with libbraiding
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

This pip-installable source distribution ``passagemath-libbraiding`` provides
an interface to `libbraiding <https://github.com/miguelmarco/libbraiding>`_,
a library to compute several properties of braids,
including centralizer and conjugacy check.


What is included
----------------

* `sage.libs.braiding <https://github.com/passagemath/passagemath/blob/main/src/sage/libs/braiding.pyx>`_


Examples
--------

::

    $ pipx run --pip-args="--prefer-binary" --spec "passagemath-libbraiding[test]" ipython

    In [1]: from sage.all__sagemath_libbraiding import *

    In [2]: from sage.libs.braiding import conjugatingbraid

    In [3]: B = BraidGroup(3); b = B([1,2,1,-2]); c = B([1,2])

    In [4]: conjugatingbraid(b,c)
    Out[4]: [[0], [2]]


Development
-----------

::

    $ git clone --origin passagemath https://github.com/passagemath/passagemath.git
    $ cd passagemath
    passagemath $ ./bootstrap
    passagemath $ python3 -m venv libbraiding-venv
    passagemath $ source libbraiding-venv/bin/activate
    (libbraiding-venv) passagemath $ pip install -v -e pkgs/sagemath-libbraiding
