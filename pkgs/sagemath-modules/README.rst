===========================================================================================================================================================================================================
 passagemath: Vectors, matrices, tensors, vector spaces, affine spaces, modules and algebras, additive groups, quadratic forms, root systems, homology, coding theory, matroids
===========================================================================================================================================================================================================

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

This pip-installable source distribution `sagemath-modules` is a distribution of a part of the Sage Library.  It provides a small subset of the modules of the Sage library ("sagelib", `sagemath-standard`).


What is included
----------------

* `Vectors, Vector Spaces, Modules <https://doc.sagemath.org/html/en/reference/modules/index.html>`_

* `Matrices and Spaces of Matrices <https://doc.sagemath.org/html/en/reference/matrices/index.html>`_

* Fields of real and complex numbers in arbitrary precision floating point arithmetic (using MPFR, GSL, mpmath, MPC)

* `Free Modules with Combinatorial Bases <https://doc.sagemath.org/html/en/reference/combinat/sage/combinat/free_module.html>`_

* `Tensor Modules <https://doc.sagemath.org/html/en/reference/tensor_free_modules/index.html>`_

* `Additive Abelian Groups <https://doc.sagemath.org/html/en/reference/groups/sage/groups/additive_abelian/additive_abelian_group.html>`_

* `Matrix and Affine Groups <https://doc.sagemath.org/html/en/reference/groups/index.html#matrix-and-affine-groups>`_

* `Root Systems <https://doc.sagemath.org/html/en/reference/combinat/sage/combinat/root_system/all.html#sage-combinat-root-system-all>`_

* `Quadratic Forms <https://doc.sagemath.org/html/en/reference/quadratic_forms/index.html>`_

* `Ring Extensions <https://doc.sagemath.org/html/en/reference/rings/sage/rings/ring_extension.html>`_ and `Derivations <https://doc.sagemath.org/html/en/reference/rings/sage/rings/derivation.html>`_

* `Clifford, Exterior <https://doc.sagemath.org/html/en/reference/algebras/sage/algebras/clifford_algebra.html>`_, and  `Weyl Algebras <https://doc.sagemath.org/html/en/reference/algebras/sage/algebras/weyl_algebra.html>`_

* `Chain Complexes, Homology <https://doc.sagemath.org/html/en/reference/homology/index.html>`_, `Free Resolutions <https://doc.sagemath.org/html/en/reference/resolutions/index.html>`_

* `Matroid Theory <https://doc.sagemath.org/html/en/reference/matroids/index.html>`_

* `Coding Theory <https://doc.sagemath.org/html/en/reference/coding/index.html>`_

* `Cryptography <https://doc.sagemath.org/html/en/reference/cryptography/index.html>`_

* `Probability Spaces and Distributions <https://doc.sagemath.org/html/en/reference/probability/index.html>`_, `Statistics <https://doc.sagemath.org/html/en/reference/stats/index.html>`_


Examples
--------

A quick way to try it out interactively::

    $ pipx run --pip-args="--prefer-binary" --spec "passagemath-modules[test]" ipython

    In [1]: from sage.all__sagemath_modules import *

    In [2]: M = matroids.Wheel(5); M
    Out[2]: Wheel(5): Regular matroid of rank 5 on 10 elements with 121 bases

    In [3]: M.representation()
    Out[3]:
    [ 1  0  0  0  0  1  0  0  0 -1]
    [ 0  1  0  0  0 -1  1  0  0  0]
    [ 0  0  1  0  0  0 -1  1  0  0]
    [ 0  0  0  1  0  0  0 -1  1  0]
    [ 0  0  0  0  1  0  0  0 -1  1]


Available as extras, from other distributions
---------------------------------------------

``pip install "sagemath-modules[RDF,CDF]"``
 Linear algebra over fields of real and complex numbers using NumPy

``pip install "sagemath-modules[RBF,CBF]"``
 Linear algebra over fields of real and complex numbers with ball arithmetic using FLINT/arb

``pip install "sagemath-modules[GF,GF2,GF2e,GFpn]"``
 Linear algebra over finite fields (various implementations)

``pip install "sagemath-modules[QQbar,NumberField,CyclotomicField]"``
 Linear algebra over the algebraic numbers or number fields

``pip install "sagemath-modules[flint,fpylll,linbox]"``
 Lattice basis reduction (LLL, BKZ)::

    $ pipx run --pip-args="--prefer-binary" --spec "passagemath-modules[flint,fpylll,linbox,test]" ipython

    In [1]: from sage.all__sagemath_modules import *

    In [2]: M = matrix(ZZ, [[1,2,3],[31,41,51],[101,201,301]])

    In [3]: A = M.LLL(); A
    Out[3]:
    [ 0  0  0]
    [-1  0  1]
    [ 1  1  1]

`pip install "sagemath-modules[padics]"`
 Linear algebra over p-adic rings and fields

`pip install "sagemath-modules[combinat]"`
 Modules and algebras with combinatorial bases; algebraic combinatorics

`pip install "sagemath-modules[invariant]"`
 Submodules invariant under group actions

`pip install "sagemath-modules[standard]"`
 All related features as in a standard installation of SageMath


Development
-----------

::

    $ git clone --origin passagemath https://github.com/passagemath/passagemath.git
    $ cd passagemath
    passagemath $ ./bootstrap
    passagemath $ python3 -m venv modules-venv
    passagemath $ source modules-venv/bin/activate
    (modules-venv) passagemath $ pip install -v -e pkgs/sagemath-modules
