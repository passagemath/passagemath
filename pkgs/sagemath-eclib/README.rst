==============================================================================================
 passagemath: Elliptic curves over the rationals with eclib/mwrank
==============================================================================================

About SageMath
--------------

   "Creating a Viable Open Source Alternative to
    Magma, Maple, Mathematica, and MATLAB"

   Copyright (C) 2005-2024 The Sage Development Team

   https://www.sagemath.org

SageMath fully supports all major Linux distributions, recent versions of
macOS, and Windows (Windows Subsystem for Linux).

See https://doc.sagemath.org/html/en/installation/index.html
for general installation instructions.


About this pip-installable distribution
---------------------------------------

This pip-installable distribution ``passagemath-eclib`` provides the
Cython interface to John Cremona's programs for enumerating and computing
with elliptic curves defined over the rational numbers.


What is included
----------------

- `Sage interface to Cremona’s eclib library (also known as mwrank) <https://doc.sagemath.org/html/en/reference/libs/sage/libs/eclib/interface.html>`_

- `Cython interface to Cremona’s eclib library (also known as mwrank) <https://doc.sagemath.org/html/en/reference/libs/sage/libs/eclib/mwrank.html>`_

- `Cremona matrices <https://doc.sagemath.org/html/en/reference/libs/sage/libs/eclib/mat.html>`_

- `Modular symbols using eclib newforms <https://doc.sagemath.org/html/en/reference/libs/sage/libs/eclib/newforms.html>`_

- `Cremona modular symbols <https://doc.sagemath.org/html/en/reference/libs/sage/libs/eclib/homspace.html>`_

- `Cremona modular symbols (constructor) <https://doc.sagemath.org/html/en/reference/libs/sage/libs/eclib/constructor.html>`_

- `Interface to the mwrank program <https://doc.sagemath.org/html/en/reference/interfaces/sage/interfaces/mwrank.html#module-sage.interfaces.mwrank>`_


Examples
--------

A quick way to try it out interactively::

    $ pipx run --pip-args="--prefer-binary" --spec "passagemath-eclib[test]" ipython

    In [1]: from sage.all__sagemath_eclib import *

    In [2]: M = CremonaModularSymbols(43, cuspidal=True); M
    Out[2]: Cremona Cuspidal Modular Symbols space of dimension 6 for Gamma_0(43) of weight 2 with sign 0

Finding the installation location of the mwrank program::

    $ pipx run --pip-args="--prefer-binary" --spec "passagemath-eclib" python
    >>> from sage.features.eclib import Mwrank
    >>> Mwrank().absolute_filename()
    '/Users/mkoeppe/.local/pipx/.cache/6c494549ef80bf7/lib/python3.11/site-packages/sage_wheels/bin/mwrank'

Use with `sage.schemes.elliptic_curves <https://doc.sagemath.org/html/en/reference/arithmetic_curves/index.html#elliptic-curves>`_::

    $ pipx run --pip-args="--prefer-binary" --spec "passagemath-eclib[test]" ipython

    In [1]: from sage.all__sagemath_eclib import *

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
