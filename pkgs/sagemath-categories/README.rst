=========================================================================
 passagemath: Sage categories, basic rings, polynomials, functions
=========================================================================

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

The pip-installable distribution package `sagemath-categories` is a
distribution of a small part of the Sage Library.

It provides a small subset of the modules of the Sage library
("sagelib", `sagemath-standard`) that is a superset of `sagemath-objects`
(providing Sage objects, the element/parent framework, categories, the coercion
system and the related metaclasses), making various additional categories
available without introducing dependencies on additional mathematical
libraries.


What is included
----------------

* `Structure <https://doc.sagemath.org/html/en/reference/structure/index.html>`_, `Coercion framework <https://doc.sagemath.org/html/en/reference/coercion/index.html>`_, `Base Classes, Metaclasses <https://doc.sagemath.org/html/en/reference/misc/index.html#special-base-classes-decorators-etc>`_

* `Categories and functorial constructions <https://doc.sagemath.org/html/en/reference/categories/index.html>`_

* `Sets <https://doc.sagemath.org/html/en/reference/sets/index.html>`_

* Basic Combinatorial and Data Structures: `Binary trees <https://doc.sagemath.org/html/en/reference/data_structures/sage/misc/binary_tree.html>`_, `Bitsets <https://doc.sagemath.org/html/en/reference/data_structures/sage/data_structures/bitset.html>`_, `Permutations <https://doc.sagemath.org/html/en/reference/combinat/sage/combinat/permutation.html>`_, Combinations

* Basic Rings and Fields: `Integers, Rationals <https://doc.sagemath.org/html/en/reference/rings_standard/index.html>`_, `Double Precision Reals <https://doc.sagemath.org/html/en/reference/rings_numerical/sage/rings/real_double.html>`_, `Z/nZ <https://doc.sagemath.org/html/en/reference/finite_rings/sage/rings/finite_rings/integer_mod_ring.html>`_

* `Commutative Polynomials <https://doc.sagemath.org/html/en/reference/polynomial_rings/index.html>`_, `Power Series and Laurent Series <https://doc.sagemath.org/html/en/reference/power_series/index.html>`_, `Rational Function Fields <https://doc.sagemath.org/html/en/reference/function_fields/index.html>`_

* Arithmetic Functions, `Elementary and Special Functions <https://doc.sagemath.org/html/en/reference/functions/index.html>`_ as generic entry points

* Base classes for Groups, Rings, `Finite Fields <https://doc.sagemath.org/html/en/reference/finite_rings/sage/rings/finite_rings/finite_field_constructor.html>`_, `Number Fields <https://doc.sagemath.org/html/en/reference/number_fields/sage/rings/number_field/number_field_base.html>`_, `Schemes <https://doc.sagemath.org/html/en/reference/schemes/index.html>`_

* Facilities for `Parallel Computing <https://doc.sagemath.org/html/en/reference/parallel/index.html>`_, `Formatted Output <https://doc.sagemath.org/html/en/reference/misc/index.html#formatted-output>`_

Available in other distribution packages
-----------------------------------------------

* `sagemath-combinat <https://pypi.org/project/sagemath-combinat>`_:
  Algebraic combinatorics, combinatorial representation theory

* `sagemath-graphs <https://pypi.org/project/sagemath-graphs>`_:
  Graphs, posets, hypergraphs, designs, abstract complexes, combinatorial polyhedra, abelian sandpiles, quivers

* `sagemath-groups <https://pypi.org/project/sagemath-groups>`_:
  Groups, invariant theory

* `sagemath-modules <https://pypi.org/project/sagemath-modules>`_:
  Vectors, matrices, tensors, vector spaces, affine spaces,
  modules and algebras, additive groups, quadratic forms, root systems, homology, coding theory, matroids

* `sagemath-plot <https://pypi.org/project/sagemath-plot>`_:
  Plotting and graphics with Matplotlib, Three.JS, etc.

* `sagemath-polyhedra <https://pypi.org/project/sagemath-polyhedra>`_:
  Convex polyhedra in arbitrary dimension, triangulations, polyhedral fans, lattice points, geometric complexes, hyperplane arrangements

* `sagemath-repl <https://pypi.org/project/sagemath-repl>`_:
  IPython REPL, the interactive language of SageMath (preparser), interacts, development tools

* `sagemath-schemes <https://pypi.org/project/sagemath-schemes>`_:
  Schemes, varieties, Groebner bases, elliptic curves, algebraic Riemann surfaces, modular forms, arithmetic dynamics

* `sagemath-symbolics <https://pypi.org/project/sagemath-symbolics>`_:
  Symbolic expressions, calculus, differentiable manifolds, asymptotics


Dependencies
------------

When building from source, development packages of `gmp`, `mpfr`, and `mpc` are needed.
