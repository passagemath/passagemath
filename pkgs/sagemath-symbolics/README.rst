===========================================================
 passagemath: Symbolic calculus
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

Complete sets of binary wheels are provided on PyPI for Python versions 3.10.x-3.13.x.
Python 3.13.x is also supported, but some third-party packages are still missing wheels,
so compilation from source is triggered for those.


About this pip-installable distribution package
-----------------------------------------------

This pip-installable distribution ``passagemath-symbolics`` is a distribution of a part of the Sage Library.
It provides a small subset of the modules of the Sage library ("sagelib", ``passagemath-standard``).


What is included
----------------

* `Symbolic Calculus <https://doc.sagemath.org/html/en/reference/calculus/index.html>`_

* `Pynac <http://pynac.org/>`_ (fork of GiNaC)

* Arithmetic Functions, `Elementary and Special Functions <https://doc.sagemath.org/html/en/reference/functions/index.html>`_
  (via `sagemath-categories <https://doc.sagemath.org/html/en/reference/spkg/sagemath_categories.html>`_)

* `Asymptotic Expansions <https://doc.sagemath.org/html/en/reference/asymptotic/index.html>`_

* `SageManifolds <https://sagemanifolds.obspm.fr/>`_: `Topological, Differentiable, Pseudo-Riemannian, Poisson Manifolds <https://doc.sagemath.org/html/en/reference/manifolds/index.html>`_

* `Hyperbolic Geometry <https://doc.sagemath.org/html/en/reference/hyperbolic_geometry/index.html>`_


Examples
--------

Using `SageManifolds <https://sagemanifolds.obspm.fr/>`_::

    $ pipx run --pip-args="--prefer-binary" --spec "passagemath-symbolics[test]" ipython

    In [1]: from sage.all__sagemath_symbolics import *

    In [2]: M = Manifold(4, 'M', structure='Lorentzian'); M
    Out[2]: 4-dimensional Lorentzian manifold M

    In [3]: X = M.chart(r"t r:(0,+oo) th:(0,pi):\theta ph:(0,2*pi):\phi")

    In [4]: t,r,th,ph = X[:]; m = var('m'); assume(m>=0)

    In [5]: g = M.metric(); g[0,0] = -(1-2*m/r); g[1,1] = 1/(1-2*m/r); g[2,2] = r**2; g[3,3] = (r*sin(th))**2; g.display()
    Out[5]: g = (2*m/r - 1) dt⊗dt - 1/(2*m/r - 1) dr⊗dr + r^2 dth⊗dth + r^2*sin(th)^2 dph⊗dph

    In [6]: g.christoffel_symbols_display()
    Out[6]:
    Gam^t_t,r = -m/(2*m*r - r^2)
    Gam^r_t,t = -(2*m^2 - m*r)/r^3
    Gam^r_r,r = m/(2*m*r - r^2)
    Gam^r_th,th = 2*m - r
    Gam^r_ph,ph = (2*m - r)*sin(th)^2
    Gam^th_r,th = 1/r
    Gam^th_ph,ph = -cos(th)*sin(th)
    Gam^ph_r,ph = 1/r
    Gam^ph_th,ph = cos(th)/sin(th)


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
