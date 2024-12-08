==========================================================================================
 passagemath: Homfly polynomials of knots/links with libhomfly
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


About this pip-installable distribution
---------------------------------------

This pip-installable distribution ``passagemath-homfly`` provides a Cython interface
to the `libhomfly <https://github.com/miguelmarco/libhomfly>`_ library.


What is included
----------------

* `sage.libs.homfly <https://github.com/passagemath/passagemath/blob/main/src/sage/libs/homfly.pyx>`_


Examples
--------

::

    $ pipx run --pip-args="--prefer-binary" --spec "passagemath-homfly[test]" ipython

    In [1]: from sage.libs.homfly import homfly_polynomial_dict

    In [2]: trefoil = '1 6 0 1  1 -1  2 1  0 -1  1 1  2 -1 0 1 1 1 2 1'

    In [3]: homfly_polynomial_dict(trefoil)
    Out[3]: {(-4, 0): -1, (-2, 0): -2, (-2, 2): 1}
