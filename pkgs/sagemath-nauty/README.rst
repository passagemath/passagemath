==========================================================================================
passagemath: Find automorphism groups of graphs, generate non-isomorphic graphs with nauty
==========================================================================================

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


About this pip-installable distribution package
-----------------------------------------------

This pip-installable distribution ``passagemath-nauty`` provides an interface to
`nauty and traces <https://pallini.di.uniroma1.it/>`_, the programs for computing
automorphism groups of graphs and digraphs by Brendan McKay and Adolfo Piperno.


What is included
----------------

- Graph generators `graphs.nauty_genbg <https://doc.sagemath.org/html/en/reference/graphs/sage/graphs/graph_generators.html#sage.graphs.graph_generators.GraphGenerators.nauty_genbg>`_, `graphs.nauty_geng <https://doc.sagemath.org/html/en/reference/graphs/sage/graphs/graph_generators.html#sage.graphs.graph_generators.GraphGenerators.nauty_geng>`_, `graphs.nauty_genktreeg <https://doc.sagemath.org/html/en/reference/graphs/sage/graphs/graph_generators.html#sage.graphs.graph_generators.GraphGenerators.nauty_genktreeg>`_

- Hypergraph generator `hypergraphs.nauty <https://doc.sagemath.org/html/en/reference/graphs/sage/graphs/hypergraph_generators.html#sage.graphs.hypergraph_generators.HypergraphGenerators.nauty>`_

- Raw access to all gtools from Python

- The binary wheels published on PyPI include a prebuilt copy of nauty and traces.


Examples
--------

Using the gtools on the command line::

    $ pipx run --pip-args="--prefer-binary" --spec "passagemath-nauty" sage -sh -c 'geng 4'
    >A geng -d0D3 n=4 e=0-6
    C?
    CC
    CE
    CF
    CQ
    CU
    CT
    CV
    C]
    C^
    C~
    >Z 11 graphs generated in 0.00 sec

Finding the installation location of a gtools program::

    $ pipx run --pip-args="--prefer-binary" --spec "passagemath-nauty[test]" ipython

    In [1]: from sage.features.nauty import NautyExecutable

    In [2]: NautyExecutable('geng').absolute_filename()
    Out[2]: '/Users/mkoeppe/.local/pipx/.cache/535c90a22321f64/lib/python3.11/site-packages/sage_wheels/bin/geng'

Use with sage.graphs::

    $ pipx run --pip-args="--prefer-binary" --spec "passagemath-nauty[test]" ipython

    In [1]: from sage.all__sagemath_graphs import *

    In [2]: gen = graphs.nauty_geng("7 -c")  # connected graphs on 7 vertices

    In [3]: len(list(gen))
    Out[3]: 853
