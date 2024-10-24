======================================================================================================
 passagemath: Algebraic combinatorics, combinatorial representation theory
======================================================================================================

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

This pip-installable source distribution ``passagemath-combinat`` is a distribution of a part of the Sage library.  It provides a small subset of the modules of the Sage library ("sagelib", ``sagemath-standard``).


What is included
----------------

* `Enumerative Combinatorics <https://doc.sagemath.org/html/en/reference/combinat/sage/combinat/enumerated_sets.html#sage-combinat-enumerated-sets>`_: `Partitions, Tableaux <https://doc.sagemath.org/html/en/reference/combinat/sage/combinat/catalog_partitions.html>`_

* `Combinatorics on Words <https://doc.sagemath.org/html/en/reference/combinat/sage/combinat/words/all.html#sage-combinat-words-all>`_, `Free Monoids <https://doc.sagemath.org/html/en/reference/monoids/index.html>`_, `Automatic Semigroups <https://doc.sagemath.org/html/en/reference/monoids/sage/monoids/automatic_semigroup.html>`_

* `Symmetric Functions <https://doc.sagemath.org/html/en/reference/combinat/sage/combinat/sf/all.html#sage-combinat-sf-all>`_, other `Algebras with combinatorial bases <https://doc.sagemath.org/html/en/reference/algebras/index.html>`_


Examples
--------

A quick way to try it out interactively:

```
    $ pipx run --pip-args="--prefer-binary" --spec "passagemath-combinat[test]" IPython
```

```
    In [1]: from sage.all__sagemath_combinat import *



```


Available as extras, from other distribution packages
-----------------------------------------------------

* `sagemath-graphs <https://pypi.org/project/sagemath-graphs>`_:
  Graphs, posets, finite state machines, combinatorial designs, incidence structures, quivers

* `sagemath-modules <https://pypi.org/project/sagemath-modules>`_:
  Modules and algebras, root systems, coding theory

* `sagemath-polyhedra <https://pypi.org/project/sagemath-polyhedra>`_:
  Polyhedra, lattice points, hyperplane arrangements
