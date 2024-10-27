=============================================================================
 passagemath: Computational Group Theory with GAP
=============================================================================

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

This pip-installable source distribution ``sagemath-gap`` is a small
distribution that provides modules that depend on the GAP system, see
https://www.gap-system.org


Examples
--------

A quick way to try it out interactively::

    $ pipx run --pip-args="--prefer-binary" --spec "passagemath-gap[test]" IPython

    In [1]: from sage.all__sagemath_gap import *

    In [2]: G = libgap.eval("Group([(1,2,3), (1,2)(3,4), (1,7)])")

    In [3]: CG = G.ConjugacyClasses()

    In [4]: gamma = CG[2]

    In [5]: g = gamma.Representative()

    In [6]: CG; gamma; g
    [ ()^G, (4,7)^G, (3,4,7)^G, (2,3)(4,7)^G, (2,3,4,7)^G, (1,2)(3,4,7)^G, (1,2,3,4,7)^G ]
    (3,4,7)^G
    (3,4,7)
