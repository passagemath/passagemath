==============================================================================================
 passagemath: Elliptic curves over the rationals with eclib/mwrank
==============================================================================================

`passagemath <https://github.com/passagemath/passagemath>`__ is open
source mathematical software in Python, released under the GNU General
Public Licence GPLv2+.

It is a fork of `SageMath <https://www.sagemath.org/>`__, which has been
developed 2005-2026 under the motto “Creating a Viable Open Source
Alternative to Magma, Maple, Mathematica, and MATLAB”.

The passagemath fork uses the motto "Creating a Free Passage Between the
Scientific Python Ecosystem and Mathematical Software Communities."
It was created in October 2024 with the following goals:

-  providing modularized installation with pip from binary wheels,
   - this major project was started in May 2020 in the Sage codebase and completed in passagemath 10.5.29 (May 2025),

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

-  developing a port to WebAssembly (`Pyodide <https://pyodide.org/en/stable/>`__, emscripten-forge) for
   serverless deployment with Javascript,

-  developing a native Windows port
   - passagemath 10.6.1 (July 2025) published the first pip-installable wheel packages for native Windows on x86_64,
   - passagemath packages became available in the [MSYS2 software distribution](https://packages.msys2.org/search?t=pkg&q=passagemath) in November 2025.

Moreover, the passagemath project:

-  provides a stable, frequently updated version of the Sage distribution,
-  integrates additional mathematical software, notably Macaulay2, a full set of GAP packages,
   and the Combinatorial Matrix Recognition library,
-  curates a library of Sage user packages.

`Full documentation <https://passagemath.org/docs/latest/html/en/index.html>`__ is
available online.

passagemath attempts to support and provides binary wheels suitable for
all major Linux distributions and recent versions of macOS.

Binary wheels for native Windows (x86_64, ARM) are are available for a subset of
the passagemath distributions. Use of the full functionality of passagemath
on Windows currently requires the use of Windows Subsystem for Linux (WSL)
or virtualization.

The supported Python versions in the passagemath-10.8.x series are 3.11.x-3.14.x;
the passagemath-10.6.x series (EOL 2026-10) still supports Python 3.10.x.


About this pip-installable distribution package
-----------------------------------------------

This pip-installable distribution ``passagemath-eclib`` provides the
Cython interface to John Cremona's programs for enumerating and computing
with elliptic curves defined over the rational numbers.


What is included
----------------

- `Sage interface to Cremona’s eclib library (also known as mwrank) <https://passagemath.org/docs/latest/html/en/reference/libs/sage/libs/eclib/interface.html>`_

- `Cython interface to Cremona’s eclib library (also known as mwrank) <https://passagemath.org/docs/latest/html/en/reference/libs/sage/libs/eclib/mwrank.html>`_

- `Cremona matrices <https://passagemath.org/docs/latest/html/en/reference/libs/sage/libs/eclib/mat.html>`_

- `Modular symbols using eclib newforms <https://passagemath.org/docs/latest/html/en/reference/libs/sage/libs/eclib/newforms.html>`_

- `Cremona modular symbols <https://passagemath.org/docs/latest/html/en/reference/libs/sage/libs/eclib/homspace.html>`_

- `Cremona modular symbols (constructor) <https://passagemath.org/docs/latest/html/en/reference/libs/sage/libs/eclib/constructor.html>`_

- `Interface to the mwrank program <https://passagemath.org/docs/latest/html/en/reference/interfaces/sage/interfaces/mwrank.html#module-sage.interfaces.mwrank>`_


Examples
--------

A quick way to try it out interactively::

    $ pipx run --pip-args="--prefer-binary" --spec "passagemath-eclib[test]" ipython

    In [1]: from passagemath_eclib import *

    In [2]: M = CremonaModularSymbols(43, cuspidal=True); M
    Out[2]: Cremona Cuspidal Modular Symbols space of dimension 6 for Gamma_0(43) of weight 2 with sign 0

Finding the installation location of the mwrank program::

    $ pipx run --pip-args="--prefer-binary" --spec "passagemath-eclib" python
    >>> from sage.features.eclib import Mwrank
    >>> Mwrank().absolute_filename()
    '.../bin/mwrank'

Use with `sage.schemes.elliptic_curves <https://passagemath.org/docs/latest/html/en/reference/arithmetic_curves/index.html#elliptic-curves>`_::

    $ pipx run --pip-args="--prefer-binary" --spec "passagemath-eclib[test]" ipython

    In [1]: from passagemath_eclib import *

    In [2]: x = polygen(ZZ, 'x')

    In [3]: K = NumberField(x**2 + 23, 'a'); a = K.gen()

    In [4]: E = EllipticCurve(K, [0,0,0,101,0])

    In [5]: E.gens()


Development
-----------

::

    $ git clone --origin passagemath https://github.com/passagemath/passagemath.git
    $ cd passagemath
    passagemath $ ./bootstrap
    passagemath $ python3 -m venv eclib-venv
    passagemath $ source eclib-venv/bin/activate
    (eclib-venv) passagemath $ pip install -v -e pkgs/sagemath-eclib
