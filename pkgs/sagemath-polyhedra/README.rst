====================================================================================================================
 passagemath: Convex polyhedra in arbitrary dimension, mixed integer linear optimization
====================================================================================================================

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


About this pip-installable source distribution
----------------------------------------------

This pip-installable source distribution `passagemath-polyhedra` is a distribution of a part of the Sage Library.  It provides a small subset of the modules of the Sage library ("sagelib", `passagemath-standard`), sufficient for computations with convex polyhedra in arbitrary dimension (in exact rational arithmetic), and linear and mixed integer linear optimization (in floating point arithmetic).


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


Available as extras, from other distributions
---------------------------------------------

Additional features:

`pip install "passagemath-polyhedra[graphs]"`
 Face lattices, combinatorial polyhedra, graph-theoretic constructions

`pip install "passagemath-polyhedra[groups]"`
 Constructing symmetric polyhedra, computing automorphisms, lattice point counting modulo group actions

`pip install "passagemath-polyhedra[toric]"`
 `Toric Varieties <https://doc.sagemath.org/html/en/reference/schemes/index.html#toric-varieties>`_

Other backends for polyhedral computations can be installed:

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

`passagemath-polyhedra` also provides integration with other packages for additional functionality:

`pip install "passagemath-polyhedra[latte]"` installs `LattE integrale <https://doc.sagemath.org/html/en/reference/spkg/latte_int.html#spkg-latte-int>`_ for lattice point counting and volume computation using generating functions.

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

`pip install "passagemath-polyhedra[polymake]"`
 `Polymake <https://doc.sagemath.org/html/en/reference/spkg/polymake.html#spkg-polymake>`_, via `JuPyMake <https://pypi.org/project/JuPyMake/>`_

`lrslib <https://doc.sagemath.org/html/en/reference/spkg/lrslib.html#spkg-lrslib>`_

Optional backends for optimization:

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
