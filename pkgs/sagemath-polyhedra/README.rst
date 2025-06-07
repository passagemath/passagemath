====================================================================================================================
 passagemath: Convex polyhedra in arbitrary dimension, mixed integer linear optimization
====================================================================================================================

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

This pip-installable distribution ``passagemath-polyhedra`` is a distribution of a part of the Sage Library.  It provides a small subset of the modules of the Sage library ("sagelib", `passagemath-standard`), sufficient for computations with convex polyhedra in arbitrary dimension (in exact rational arithmetic), and linear and mixed integer linear optimization (in floating point arithmetic).


What is included
----------------

* `Combinatorial and Discrete Geometry <https://doc.sagemath.org/html/en/reference/discrete_geometry/index.html>`_: Polyhedra, lattice polyhedra, lattice points in polyhedra, triangulations, fans, polyhedral complexes, hyperplane arrrangements

* `Parma Polyhedra Library (PPL) backends for rational polyhedra <https://doc.sagemath.org/html/en/reference/discrete_geometry/sage/geometry/polyhedron/backend_ppl.html>`_, `lattice polygons <https://doc.sagemath.org/html/en/reference/discrete_geometry/sage/geometry/polyhedron/ppl_lattice_polygon.html>`_, `lattice polytopes <https://doc.sagemath.org/html/en/reference/discrete_geometry/sage/geometry/polyhedron/ppl_lattice_polytope.html>`_; via `pplpy <https://doc.sagemath.org/html/en/reference/spkg/pplpy.html#spkg-pplpy>`_

* `Python backend for polyhedra over general ordered fields <https://doc.sagemath.org/html/en/reference/discrete_geometry/sage/geometry/polyhedron/backend_field.html>`_

* `Linear, Mixed Integer Linear, and Semidefinite Optimization frontends <https://doc.sagemath.org/html/en/reference/numerical/index.html#numerical-optimization>`_

* `GNU Linear Programming Kit (GLPK) backend for large-scale linear and mixed integer linear optimization (floating point arithmetic) <https://doc.sagemath.org/html/en/reference/numerical/sage/numerical/backends/glpk_backend.html>`_

* `Interactive Simplex Method <https://doc.sagemath.org/html/en/reference/numerical/sage/numerical/interactive_simplex_method.html>`_

* see https://github.com/passagemath/passagemath/blob/main/pkgs/sagemath-polyhedra/MANIFEST.in


Examples
--------

A quick way to try it out interactively::

    $ pipx run --pip-args="--prefer-binary" --spec "passagemath-polyhedra[test]" ipython

    In [1]: from sage.all__sagemath_polyhedra import *

    In [2]: P = Polyhedron(ieqs=[[0, 1, 0, 0, 0, 0, 0], [0, 0, 1, 0, 0, 0, 0], [0, 0, 0, 1, 0, 0, 0], [0, 0, 0, 0, 1, 0, 0], [0, 0, 0, 0, 0, 1, 0], [0, 0, 0, 0, 0, 0, 1], [0, 0, 1, -1, -1, 1, 0], [0, 0, -1, 1, -1, 1, 0]], eqns=[[-31, 1, 1, 1, 1, 1, 1]]); P
    Out[2]: A 5-dimensional polyhedron in QQ^6 defined as the convex hull of 7 vertices

    In [3]: P.Vrepresentation()
    Out[4]:
    (A vertex at (31, 0, 0, 0, 0, 0),
     A vertex at (0, 0, 0, 0, 0, 31),
     A vertex at (0, 0, 0, 0, 31, 0),
     A vertex at (0, 0, 31/2, 0, 31/2, 0),
     A vertex at (0, 31/2, 31/2, 0, 0, 0),
     A vertex at (0, 31/2, 0, 0, 31/2, 0),
     A vertex at (0, 0, 0, 31/2, 31/2, 0))


Available as extras, from other distributions
---------------------------------------------

Additional features
~~~~~~~~~~~~~~~~~~~

`pip install "passagemath-polyhedra[graphs]"`
 Face lattices, combinatorial polyhedra, graph-theoretic constructions

 ::

    $ pipx run --pip-args="--prefer-binary" --spec "passagemath-polyhedra[graphs,test]" ipython

    In [1]: from sage.all__sagemath_polyhedra import *

    In [2]: c5_10 = Polyhedron(vertices = [[i, i**2, i**3, i**4, i**5] for i in range(1, 11)]); c5_10
    Out[2]: A 5-dimensional polyhedron in ZZ^5 defined as the convex hull of 10 vertices

    In [3]: c5_10_fl = c5_10.face_lattice(); [len(x) for x in c5_10_fl.level_sets()]
    Out[3]: [1, 10, 45, 100, 105, 42, 1]

`pip install "passagemath-polyhedra[graphs,groups]"`
 Constructing symmetric polyhedra, computing automorphisms, lattice point counting modulo group actions

 ::

    $ pipx run --pip-args="--prefer-binary" --spec "passagemath-polyhedra[graphs,groups,test]" ipython

    In [1]: from sage.all__sagemath_polyhedra import *

    In [2]: P24 = polytopes.twenty_four_cell(); P24
    Out[2]: A 4-dimensional polyhedron in QQ^4 defined as the convex hull of 24 vertices

    In [3]: AutP24 = P24.restricted_automorphism_group(); AutP24.order()
    Out[3]: 1152

`pip install "passagemath-polyhedra[toric]"`
 `Toric varieties <https://doc.sagemath.org/html/en/reference/schemes/index.html#toric-varieties>`_

 ::

    $ pipx run --pip-args="--prefer-binary" --spec "passagemath-polyhedra[graphs,toric,test]" ipython

    In [1]: from sage.all__sagemath_polyhedra import *

    In [2]: TV3 = ToricVariety(NormalFan(lattice_polytope.cross_polytope(3))); TV3
    Out[2]: 3-d toric variety covered by 6 affine patches

    In [3]: TV3.is_orbifold()
    Out[3]: False

`pip install "passagemath-polyhedra[latte]"`
 Installs `LattE integrale <https://doc.sagemath.org/html/en/reference/spkg/latte_int.html#spkg-latte-int>`_
 for lattice point counting and volume computation using generating function techniques.

 ::

   $ pipx run --pip-args="--prefer-binary" --spec "passagemath-polyhedra[latte,test]" ipython

   In [1]: from sage.all__sagemath_polyhedra import *

   In [2]: P = polytopes.cube()

   In [3]: P.integral_points_count()
   Out[3]:
   27

   In [4]: (1000000000*P).integral_points_count(verbose=True)
   This is LattE integrale...
   ...
   Total time:...
   Out[4]:
   8000000012000000006000000001


Additional backends for polyhedral computations
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

`pip install "passagemath-polyhedra[normaliz]"`
 `Normaliz <https://doc.sagemath.org/html/en/reference/spkg/normaliz.html#spkg-normaliz>`_, via `PyNormaliz <https://doc.sagemath.org/html/en/reference/spkg/pynormaliz.html#spkg-pynormaliz>`_,
 provides very fast computations in particular for polyhedra with data in algebraic number fields.

 ::

    $ pipx run --pip-args="--prefer-binary" --spec "passagemath-polyhedra[normaliz,test]" ipython

    In [1]: from sage.all__sagemath_polyhedra import *

    In [2]: gap_norm = polytopes.grand_antiprism(backend='normaliz'); gap_norm

    In [3]: gap_norm.f_vector()

`pip install "passagemath-polyhedra[cddlib]"`
 cddlib provides support for computations with polyhedra in floating-point arithmetic.

 ::

    $ pipx run --pip-args="--prefer-binary" --spec "passagemath-polyhedra[cddlib,test]" ipython

    In [1]: from sage.all__sagemath_polyhedra import *

    In [2]: P1 = polytopes.regular_polygon(5, exact=False); P1
    Out[2]: A 2-dimensional polyhedron in RDF^2 defined as the convex hull of 5 vertices

`pip install "passagemath-polyhedra[lrslib]"`
 `lrslib <https://doc.sagemath.org/html/en/reference/spkg/lrslib.html#spkg-lrslib>`_
 can be used for polytope volume computations and for enumerating Nash equilibria.

 ::

    $ pipx run --pip-args="--prefer-binary" --spec "passagemath-polyhedra[flint,lrslib,test]" ipython

    In [1]: from sage.all__sagemath_polyhedra import *

    In [2]: A = matrix([[2, 1], [1, 5/2]]); B = matrix([[-1, 3], [2, 1]])

    In [3]: g = NormalFormGame([A, B]); g.obtain_nash(algorithm='lrs')
    Out[3]: [[(1/5, 4/5), (3/5, 2/5)]]

`pip install "passagemath-polyhedra[polymake]"`
 `Polymake <https://doc.sagemath.org/html/en/reference/spkg/polymake.html#spkg-polymake>`_, via `JuPyMake <https://pypi.org/project/JuPyMake/>`_

 This currently requires a separate installation of polymake.

Optional backends for optimization
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

`pip install "passagemath-polyhedra[cbc]"`
 `COIN/OR CBC <https://doc.sagemath.org/html/en/reference/spkg/cbc.html#spkg-cbc>`_ Mixed Integer Linear Optimization solver,
 via `sage_numerical_backends_coin <https://doc.sagemath.org/html/en/reference/spkg/sage_numerical_backends_coin.html#spkg-sage-numerical-backends-coin>`_

`pip install "passagemath-polyhedra[cplex]"`
 CPLEX Mixed Integer Optimization solver (proprietary; requires licensed installation),
 via `sage_numerical_backends_cplex <https://doc.sagemath.org/html/en/reference/spkg/sage_numerical_backends_cplex.html#spkg-sage-numerical-backends-cplex>`_

`pip install "passagemath-polyhedra[cvxpy]"`
 `CVXPy <https://doc.sagemath.org/html/en/reference/spkg/cvxpy.html#spkg-cvxpy>`_ as middle-end for `various backends <https://www.cvxpy.org/install/>`_

`pip install "passagemath-polyhedra[gurobi]"`
 Gurobi Mixed Integer Optimization solver (proprietary; requires licensed installation), via `sage_numerical_backends_gurobi <https://doc.sagemath.org/html/en/reference/spkg/sage_numerical_backends_gurobi.html#spkg-sage-numerical-backends-gurobi>`_

`pip install "passagemath-polyhedra[scip]"`
 `SCIP <https://doc.sagemath.org/html/en/reference/spkg/scip.html#spkg-scip>`_ Mixed Integer Optimization solver,
 via `PySCIPOpt <https://doc.sagemath.org/html/en/reference/spkg/pyscipopt.html#spkg-pyscipopt>`_


Development
-----------

::

    $ git clone --origin passagemath https://github.com/passagemath/passagemath.git
    $ cd passagemath
    passagemath $ ./bootstrap
    passagemath $ python3 -m venv polyhedra-venv
    passagemath $ source polyhedra-venv/bin/activate
    (polyhedra-venv) passagemath $ pip install -v -e pkgs/sagemath-polyhedra
