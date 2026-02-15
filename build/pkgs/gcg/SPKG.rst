gcg: Generic decomposition solver for mixed-integer programs
============================================================

Description
-----------

GCG is a generic decomposition solver for mixed integer linear
programs that extends the SCIP (Solving Constraint Integer Programs)
framework. It finds structures in models that can be used to apply a
Dantzig-Wolfe reformulation or Benders decomposition. Decompositions
can also be user-given, and explored and evaluated manually. For a
Dantzig-Wolfe reformulated model, a branch-price-and-cut algorithm
solves the problem, which features primal heuristics, generic and
specific pricing solvers, branching rules, dual variable
stabilization, cutting planes, etc. Like SCIP, also GCG can be used as
a framework and extended to suit one's needs.

License
-------

Apache 2.0

Upstream Contact
----------------

https://github.com/scipopt/gcg
