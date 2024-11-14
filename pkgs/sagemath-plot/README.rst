===============================================================================================
 passagemath: Plotting and graphics with Matplotlib, Three.JS, etc.
===============================================================================================

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


About this pip-installable distribution
---------------------------------------

This pip-installable distribution ``passagemath-plot`` is a distribution of a part of the Sage Library.

It provides the namespace packages ``sage.plot`` and ``sage.plot.plot3d``, which provide functions for plotting that are very similar to Mathematica's plotting functions.  This is analogous to how matplotlib's ``pyplot`` package provides a UI on top of the core ``matplotlib`` library that is similar to matlab's plotting UI.

What is included
----------------

* `2D Graphics <https://doc.sagemath.org/html/en/reference/plotting/index.html>`_

* Backend for 2D graphics: `matplotlib <https://doc.sagemath.org/html/en/reference/spkg/matplotlib.html>`_

* `3D Graphics <https://doc.sagemath.org/html/en/reference/plot3d/index.html>`_

* Backend for 3D graphics: `three.js <https://doc.sagemath.org/html/en/reference/spkg/threejs.html>`_

* Interfaces: `Gnuplot <https://doc.sagemath.org/html/en/reference/interfaces/sage/interfaces/gnuplot.html>`_, `Jmol <https://doc.sagemath.org/html/en/reference/interfaces/sage/interfaces/jmoldata.html>`_, `POV-Ray <https://doc.sagemath.org/html/en/reference/interfaces/sage/interfaces/povray.html>`_, `Tachyon <https://doc.sagemath.org/html/en/reference/interfaces/sage/interfaces/tachyon.html>`_

Examples
--------

::

   $ pipx run --pip-args="--prefer-binary" --spec "passagemath-plot[test]" ipython

   In [1]: from sage.all__sagemath_plot import *

   In [2]: scatter_plot([[0,1],[2,2],[4.3,1.1]], marker='s').save('output.png')

   In [3]: G = tetrahedron((0,-3.5,0), color='blue') + cube((0,-2,0), color=(.25,0,.5))

   In [4]: G.show(aspect_ratio=[1,1,1])
   Graphics3d Object

Available as extras, from other distributions
---------------------------------------------

`pip install "passagemath-plot[jsmol]"`
 Alternative backend for 3D graphics: `jupyter-jsmol <https://doc.sagemath.org/html/en/reference/spkg/jupyter_jsmol.html>`_

`pip install "passagemath-plot[polyhedra]"`
 Polyhedra in arbitrary dimension, plotting in dimensions 2, 3, 4: `passagemath-polyhedra <https://pypi.org/project/passagemath-polyhedra/>`_

`pip install "passagemath-plot[graphs]"`
 Graphs and networks: `sagemath-graphs <https://pypi.org/project/passagemath-graphs/>`_

`pip install "passagemath-plot[symbolics]"`
 Defining and plotting symbolic functions and manifolds: `passagemath-symbolics <https://pypi.org/project/passagemath-symbolics/>`_
