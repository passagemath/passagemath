****************
Interface Issues
****************

.. index::
   single: background, running Sage in

.. _section-background:

Background jobs
===============

Yes, a Sage job can be run in the background on a
UNIX system. The canonical thing to do is type

.. CODE-BLOCK:: shell-session

    $ nohup sage < command_file  > output_file &

The advantage of nohup is that Sage will continue running after you
log out.

Currently Sage will appear as "sage-ipython" or "python" in the output
of the (unix) ``top`` command, but in future versions of Sage it will
appears as ``sage``.

.. index::
   pair: referencing; Sage

Logging your Sage session
=========================

Yes you can log your sessions.

(a) You can write the output to a file, by running Sage in the
background ( :ref:`section-background` ).

(b) Start in a KDE konsole (this only work in linux). Go to
``Settings`` :math:`\rightarrow` ``History ...`` and select
unlimited. Start your session. When ready, go to ``edit``
:math:`\rightarrow` ``save history as ...``.

Some interfaces (such as the interface to Singular or that to GAP)
allow you to create a log file. For Singular, there is a logfile
option (in ``singular.py``). In GAP, use the command ``LogTo``.

.. index:: LaTeX output

LaTeX conversion
================

Yes, you can output some of your results into LaTeX.

::

    sage: M = MatrixSpace(RealField(),3,3)
    sage: A = M([1,2,3, 4,5,6, 7,8,9])
    sage: print(latex(A))
    \left(\begin{array}{rrr}
        1.00000000000000 & 2.00000000000000 & 3.00000000000000 \\
        4.00000000000000 & 5.00000000000000 & 6.00000000000000 \\
        7.00000000000000 & 8.00000000000000 & 9.00000000000000
        \end{array}\right)

.. skip

::

    sage: view(A)

At this point a dvi preview should automatically be called to
display in a separate window the LaTeX output produced.

LaTeX previewing for multivariate polynomials and rational functions
is also available:

::

    sage: x = PolynomialRing(QQ,3, 'x').gens()
    sage: f = x[0] + x[1] - 2*x[1]*x[2]
    sage: h = f /(x[1] + x[2])
    sage: print(latex(h))
    \frac{-2 x_{1} x_{2} + x_{0} + x_{1}}{x_{1} + x_{2}}

Sage and other computer algebra systems
=======================================

If ``foo`` is a Pari, GAP ( without ending semicolon), Singular,
Maxima command, resp., enter ``gp("foo")`` for Pari,
``libgap.eval("foo")}`` ``singular.eval("foo")``, ``maxima("foo")``, resp..
These programs merely send the command string to the external
program, execute it, and read the result back into Sage. Therefore,
these will not work if the external program is not installed and in
your PATH.

.. index:: help in Sage

Command-line Sage help
======================

If you know only part of the name of a Sage command and want to
know where it occurs in Sage, just type
``sage -grep <string>`` to find all occurrences of ``<string>`` in the
Sage source code. For example,

.. CODE-BLOCK:: shell-session

    $ sage -grep berlekamp_massey
    matrix/all.py:from berlekamp_massey import berlekamp_massey
    matrix/berlekamp_massey.py:def berlekamp_massey(a):
    matrix/matrix.py:import berlekamp_massey
    matrix/matrix.py:            g =
    berlekamp_massey.berlekamp_massey(cols[i].list())

Type ``help(foo)`` or ``foo??`` for help and ``foo.[tab]`` for searching
of Sage commands. Type ``help()`` for Python commands.

For example

.. CODE-BLOCK:: python

    help(Matrix)

returns

.. skip

.. CODE-BLOCK:: text

    Help on cython_function_or_method in module sage.matrix.constructor:

    matrix(*args, **kwds)
        matrix(*args, **kwds)
        File: sage/matrix/constructor.pyx (starting at line 21)

            Create a matrix.

            This implements the ``matrix`` constructor::

                sage: matrix([[1,2],[3,4]])
                [1 2]
                [3 4]

            It also contains methods to create special types of matrices, see
            ``matrix.[tab]`` for more options. For example::
    --More--

in a new screen. Type q to return to the Sage screen.

.. index:: importing into Sage

Reading and importing files into Sage
=====================================

A file imported into Sage must end in ``.py``, e.g., ``foo.py`` and
contain legal Python syntax. For a simple example see :ref:`section-permutation`
with the Rubik's cube group example above.

Another way to read a file in is to use the ``load`` or ``attach``
command. Create a file called ``example.sage`` (located in the home
directory of Sage) with the following content:

.. skip

.. CODE-BLOCK:: python

    print("Hello World")
    print(2^3)

.. index:: load into Sage

Read in and execute ``example.sage`` file using the ``load`` command.

.. skip

::

    sage: load("example.sage")
    Hello World
    8

.. index:: attach into Sage

You can also ``attach`` a Sage file to a running session:

.. skip

::

    sage: attach("example.sage")
    Hello World
    8

Now if you change ``example.sage`` and enter one blank line into
Sage, then the contents of ``example.sage`` will be automatically
reloaded into Sage:

.. skip

::

    sage: !emacs example.sage&     #change 2^3 to 2^4
    sage:                          #hit return
    ***************************************************
                    Reloading 'example.sage'
    ***************************************************
    Hello World
    16

.. index:: Python and Sage

Python language program code for Sage commands
==============================================

Let's say you want to know what the Python program is for the Sage
command to compute the center of a permutation group. Use Sage's
help interface to find the file name:

.. skip

::

    sage: PermutationGroup.center?
    Type:           instancemethod
    Base Class:     <class 'instancemethod'>
    String Form:    <unbound method PermutationGroup.center>
    Namespace:      Interactive
    File:           /home/wdj/sage/local/lib/python2.4/site-packages/sage/groups/permgroup.py
    Definition:     PermutationGroup.center(self)

Now you know that the command is located in the ``permgroup.py`` file
and you know the directory to look for that Python module. You can
use an editor to read the code itself.

.. index:: special functions in Sage

"Special functions" in Sage
===========================

Sage has many special functions (see the reference
manual at http://doc.sagemath.org/html/en/reference/functions/),
and most of them can be
manipulated symbolically. Where this is not implemented,
it is possible that other symbolic packages have the
functionality.

Via Maxima, some symbolic manipulation is allowed:

::

    sage: maxima.eval("f:bessel_y (v, w)")
    'bessel_y(v,w)'
    sage: maxima.eval("diff(f,w)")
    '(bessel_y(v-1,w)-bessel_y(v+1,w))/2'
    sage: maxima.eval("diff (jacobi_sn (u, m), u)")
    'jacobi_cn(u,m)*jacobi_dn(u,m)'
    sage: jsn = lambda x: jacobi("sn",x,1)
    sage: P = plot(jsn,0,1, plot_points=20); Q = plot(lambda x:bessel_Y( 1, x), 1/2,1)
    sage: show(P)
    sage: show(Q)

In addition to ``maxima``, ``pari`` and ``octave`` also have special
functions (in fact, some of ``pari``'s special functions are wrapped
in Sage).

Here's an example using Sage's interface (located in
sage/interfaces/octave.py) with ``octave``
(https://www.gnu.org/software/octave/doc/latest).

::

    sage: octave("atanh(1.1)")   ## optional - octave
    (1.52226,1.5708)

Here's an example using Sage's interface to ``pari``'s special
functions.

::

    sage: pari('2+I').besselk(3)
    0.0455907718407551 + 0.0289192946582081*I
    sage: pari('2').besselk(3)
    0.0615104584717420
