===========================================================
 passagemath: Symbolic calculus with maxima
===========================================================

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

This pip-installable distribution ``passagemath-maxima`` provides
interfaces to `Maxima <https://doc.sagemath.org/html/en/reference/spkg/maxima.html>`_.


What is included
----------------

* Binary wheels on PyPI contain prebuilt copies of `Maxima <https://doc.sagemath.org/html/en/reference/spkg/maxima.html>`_.


Examples
--------

Starting Maxima from the command line::

    $ pipx run --pip-args="--prefer-binary" --spec "passagemath-maxima" sage -maxima

Using the pexpect interface to Maxima::

    $ pipx run --pip-args="--prefer-binary" --spec "passagemath-maxima[test]" ipython

    In [1]: from sage.interfaces.maxima import maxima

    In [2]: maxima('1+1')
    Out[2]: 2

Using the library interface to Maxima::

    $ pipx run --pip-args="--prefer-binary" --spec "passagemath-maxima[test]" ipython

    In [1]: from sage.interfaces.maxima_lib import maxima_lib

    In [2]: F = maxima_lib('x^5 - y^5').factor()

    In [3]: F.display2d()
    Out[3]:
                               4      3    2  2    3      4
                   - (y - x) (y  + x y  + x  y  + x  y + x )
