=======================================================================================================
 passagemath: Elliptic curve method for integer factorization using GMP-ECM
=======================================================================================================

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

`Full documentation <https://passagemath.org/docs/latest/html/en/index.html>`__ is
available online.

passagemath attempts to support and provides binary wheels suitable for
all major Linux distributions and recent versions of macOS.

Binary wheels for native Windows (x86_64) are are available for a subset of
the passagemath distributions. Use of the full functionality of passagemath
on Windows currently requires the use of Windows Subsystem for Linux (WSL)
or virtualization.

The supported Python versions in the passagemath 10.6.x series are 3.10.x-3.13.x.


About this pip-installable distribution package
-----------------------------------------------

This pip-installable package ``passagemath-libecm`` provides
interfaces to `GMP-ECM <https://gitlab.inria.fr/zimmerma/ecm>`_, the implementation
of the Elliptic Curve Method for integer factorization.


What is included
----------------

- `Python interface to the ECM program <https://passagemath.org/docs/latest/html/en/reference/interfaces/sage/interfaces/ecm.html#module-sage.interfaces.ecm>`_

- `Cython interface to the libecm library <https://passagemath.org/docs/latest/html/en/reference/libs/sage/libs/libecm.html#module-sage.libs.libecm>`_

- The binary wheels published on PyPI include a prebuilt copy of GMP-ECM (executable and library).


Examples
--------

::

    $ pipx run --pip-args="--prefer-binary" --spec "passagemath-libecm[test]" ipython

    In [1]: from sage.libs.libecm import ecmfactor

    In [2]: N = 11 * 43570062353753446053455610056679740005056966111842089407838902783209959981593077811330507328327968191581

    In [3]: ecmfactor(N, 100, verbose=True)
    Performing one curve with B1=100
    Found factor in step 1: 11
    Out[3]: (True, 11, ...)

    In [4]: ecmfactor(N//11, 100, verbose=True)
    Performing one curve with B1=100
    Found no factor.
    Out[4]: (False, None)


Available as extras, from other distributions
---------------------------------------------

``pip install passagemath-libecm[pari]`` additionally makes PARI available (for primality testing)
