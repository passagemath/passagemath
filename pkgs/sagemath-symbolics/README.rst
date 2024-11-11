===========================================================
 passagemath: Symbolic calculus
===========================================================

About SageMath
--------------

   "Creating a Viable Open Source Alternative to
    Magma, Maple, Mathematica, and MATLAB"

   Copyright (C) 2005-2023 The Sage Development Team

   https://www.sagemath.org

SageMath fully supports all major Linux distributions, recent versions of macOS, and Windows (using Cygwin or Windows Subsystem for Linux).

The traditional and recommended way to install SageMath is from source via Sage-the-distribution (https://www.sagemath.org/download-source.html).  Sage-the-distribution first builds a large number of open source packages from source (unless it finds suitable versions installed in the system) and then installs the Sage Library (sagelib, implemented in Python and Cython).


About this pip-installable distribution
---------------------------------------

This pip-installable distribution `passagemath-symbolics` is a distribution of a part of the Sage Library.
It provides a small subset of the modules of the Sage library ("sagelib", `passagemath-standard`).


What is included
----------------

* `Symbolic Calculus <https://doc.sagemath.org/html/en/reference/calculus/index.html>`_

* `Pynac <http://pynac.org/>`_ (fork of GiNaC)

* Arithmetic Functions, `Elementary and Special Functions <https://doc.sagemath.org/html/en/reference/functions/index.html>`_
  (via `sagemath-categories <https://doc.sagemath.org/html/en/reference/spkg/sagemath_categories.html>`_)

* `Asymptotic Expansions <https://doc.sagemath.org/html/en/reference/asymptotic/index.html>`_

* SageManifolds: `Topological, Differentiable, Pseudo-Riemannian, Poisson Manifolds <https://doc.sagemath.org/html/en/reference/manifolds/index.html>`_

* `Hyperbolic Geometry <https://doc.sagemath.org/html/en/reference/hyperbolic_geometry/index.html>`_

* Binary wheels on PyPI contain prebuilt copies of `Maxima <https://doc.sagemath.org/html/en/reference/spkg/maxima.html>`_
  and `Embeddable Common Lisp <https://doc.sagemath.org/html/en/reference/spkg/ecl.html>`_


Examples
--------

Starting Maxima from the command line::

    $ pipx run --pip-args="--prefer-binary" --spec "passagemath-symbolics" sage -maxima

Using the pexpect interface to Maxima::

    $ pipx run --pip-args="--prefer-binary" --spec "passagemath-symbolics[test]" ipython

    In [1]: from sage.interfaces.maxima import maxima

    In [2]: maxima('1+1')
    Out[2]: 2

Using the library interface to Maxima::

    $ pipx run --pip-args="--prefer-binary" --spec "passagemath-symbolics[test]" ipython

    In [1]: from sage.interfaces.maxima_lib import maxima_lib

    In [2]: F = maxima_lib('x^5 - y^5').factor()

    In [3]: F.display2d()
    Out[3]:
                               4      3    2  2    3      4
                   - (y - x) (y  + x y  + x  y  + x  y + x )


Available as extras, from other distributions
---------------------------------------------

`pip install "passagemath-symbolics[giac]"`
 Computer algebra system `Giac <https://doc.sagemath.org/html/en/reference/spkg/giac.html>`_, via `passagemath-giac <https://doc.sagemath.org/html/en/reference/spkg/sagemath_giac.html>`_

`pip install "passagemath-symbolics[primecount]"`
 `Prime counting function <https://doc.sagemath.org/html/en/reference/functions/sage/functions/prime_pi.html>`_
 implementation `primecount <https://doc.sagemath.org/html/en/reference/spkg/primecount.html>`_, via `primecountpy <https://doc.sagemath.org/html/en/reference/spkg/primecountpy.html>`_

`pip install "passagemath-symbolics[sympy]"`
 Python library for symbolic mathematics / computer algebra system `SymPy <https://doc.sagemath.org/html/en/reference/spkg/sympy.html>`_

`pip install "passagemath-symbolics[plot]"`
 Plotting facilities
