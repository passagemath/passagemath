=====================================================================================
passagemath: Triangulations of point configurations and oriented matroids with TOPCOM
=====================================================================================

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

This pip-installable distribution ``passagemath-topcom`` provides an interface to
`TOPCOM <https://www.wm.uni-bayreuth.de/de/team/rambau_joerg/TOPCOM/>`_,
a package for computing triangulations of point configurations and
oriented matroids by Jörg Rambau.


What is included
----------------

- Raw access to all executables from Python using `sage.features.topcom <https://doc.sagemath.org/html/en/reference/spkg/sage/features/topcom.html>`_

- The binary wheels published on PyPI include a prebuilt copy of TOPCOM.


Examples
--------

Using TOPCOM programs on the command line::

    $ pipx run --pip-args="--prefer-binary" --spec "passagemath-topcom" sage -sh -c 'cube 4 | points2facets'
    Evaluating Commandline Options ...
    ... done.
    16,5:
    {
    {0,1,2,3,4,5,6,7}
    {0,1,2,3,8,9,10,11}
    {0,1,4,5,8,9,12,13}
    {0,2,4,6,8,10,12,14}
    {1,3,5,7,9,11,13,15}
    {2,3,6,7,10,11,14,15}
    {4,5,6,7,12,13,14,15}
    {8,9,10,11,12,13,14,15}
    }

Finding the installation location of a TOPCOM program::

    $ pipx run --pip-args="--prefer-binary" --spec "passagemath-topcom[test]" ipython

    In [1]: from sage.features.topcom import TOPCOMExecutable

    In [2]: TOPCOMExecutable('points2allfinetriangs').absolute_filename()
    Out[2]: '/Users/mkoeppe/.local/pipx/.cache/cef1668ecbdb8cf/lib/python3.11/site-packages/sage_wheels/bin/points2allfinetriangs'

Using `sage.geometry.triangulation.point_configuration <https://doc.sagemath.org/html/en/reference/discrete_geometry/sage/geometry/triangulation/point_configuration.html>`_::

    $ pipx run --pip-args="--prefer-binary" --spec "passagemath-topcom[test]" ipython

    In [1]: from sage.all__sagemath_topcom import *

    In [2]: p = PointConfiguration([[-1,QQ('-5/9')], [0,QQ('10/9')], [1,QQ('-5/9')], [-2,QQ('-10/9')], [0,QQ('20/9')], [2,QQ('-10/9')]])

    In [3]: PointConfiguration.set_engine('topcom')

    In [4]: p_regular = p.restrict_to_regular_triangulations(True)

    In [5]: regular = p_regular.triangulations_list()

    In [6]: len(regular)
    Out[6]: 16
