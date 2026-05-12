# sage_setup: distribution = sagemath-symbolics
r"""
Interface to Mathics3

Mathics3 is an open source interpreter for the Wolfram Language.
From the introduction of its reference manual:

.. NOTE::

    Mathics3 — to be pronounced like “Mathematics” without the
    “emat” — is a general-purpose computer algebra system (CAS).
    It is meant to be a free, light-weight alternative to
    Mathematica®. It is free both as in “free beer” and as in
    “freedom”. There are various online mirrors running
    Mathics3 but it is also possible to run Mathics3 locally.
    A list of mirrors can be found at the Mathics3 homepage,
    http://mathics.github.io.

    The programming language of Mathics3 is meant to resemble
    Wolfram’s famous Mathematica® as much as possible. However,
    Mathics3 is in no way affiliated or supported by Wolfram.
    Mathics3 will probably never have the power to compete with
    Mathematica® in industrial applications; yet, it might be
    an interesting alternative for educational purposes.

The Mathics3 interface will only work if the optional Sage package Mathics3
is installed. The interface lets you send certain Sage objects to Mathics3,
run Mathics3 functions, import certain Mathics3 expressions to Sage,
or any combination of the above.

To send a Sage object ``sobj`` to Mathics3, call ``mathics3(sobj)``.
This exports the Sage object to Mathics3 and returns a new Sage object
wrapping the Mathics3 expression/variable, so that you can use the
Mathics3 variable from within Sage. You can then call Mathics3
functions on the new object; for example::

    sage: from sage.interfaces.mathics3 import mathics3
    sage: mobj = mathics3(x^2-1); mobj      # optional - mathics3
    -1 + x ^ 2
    sage: mobj.Factor()                     # optional - mathics3
    (-1 + x) (1 + x)

In the above example the factorization is done using Mathics3's
``Factor[]`` function.

To see Mathics3's output you can simply print the Mathics3 wrapper
object. However if you want to import Mathics3's output back to Sage,
call the Mathics3 wrapper object's ``sage()`` method. This method returns
a native Sage object::

    sage: # optional - mathics3
    sage: mobj = mathics3(x^2-1)
    sage: mobj2 = mobj.Factor(); mobj2
    (-1 + x) (1 + x)
    sage: mobj2.parent()
    Mathics3
    sage: sobj = mobj2.sage(); sobj
    (x + 1)*(x - 1)
    sage: sobj.parent()
    Symbolic Ring


If you want to run a Mathics3 function and don't already have the input
in the form of a Sage object, then it might be simpler to input a string to
``mathics3(expr)``. This string will be evaluated as if you had typed it
into Mathics3::

    sage: mathics3('Factor[x^2-1]')          # optional - mathics3
    (-1 + x) (1 + x)
    sage: mathics3('Range[3]')               # optional - mathics3
    {1, 2, 3}

If you want work with the internal Mathics3 expression, then you can call
``mathics3.eval(expr)``, which returns an instance of
:class:`mathics3.core.expression.Expression`. If you want the result to
be a string formatted like Mathics3's InputForm, call ``repr(mobj)`` on
the wrapper object ``mobj``. If you want a string formatted in Sage style,
call ``mobj._sage_repr()``::

    sage: mathics3.eval('x^2 - 1')           # optional - mathics3
    '-1 + x ^ 2'
    sage: repr(mathics3('Range[3]'))         # optional - mathics3
    '{1, 2, 3}'
    sage: mathics3('Range[3]')._sage_repr()  # optional - mathics3
    '[1, 2, 3]'

Finally, if you just want to use a Mathics3 command line from within
Sage, the function ``mathics3_console()`` dumps you into an interactive
command-line Mathics3 session.

Tutorial
--------

We follow some of the tutorial from
http://library.wolfram.com/conferences/devconf99/withoff/Basic1.html/.


Syntax
~~~~~~

Now make 1 and add it to itself. The result is a Mathics3
object.

::

    sage: m = mathics3
    sage: a = m(1) + m(1); a                # optional - mathics3
    2
    sage: a.parent()                        # optional - mathics3
    Mathics3
    sage: m('1+1')                          # optional - mathics3
    2
    sage: m(3)**m(50)                       # optional - mathics3
    717897987691852588770249

The following is equivalent to ``Plus[2, 3]`` in
Mathics3::

    sage: m = mathics3
    sage: m(2).Plus(m(3))                   # optional - mathics3
    5

We can also compute `7(2+3)`.

::

    sage: m(7).Times(m(2).Plus(m(3)))       # optional - mathics3
    35
    sage: m('7(2+3)')                       # optional - mathics3
    35

Some typical input
~~~~~~~~~~~~~~~~~~

We solve an equation and a system of two equations::

    sage: # optional - mathics3
    sage: eqn = mathics3('3x + 5 == 14')
    sage: eqn
    5 + 3 x == 14
    sage: eqn.Solve('x')
    {{x -> 3}}
    sage: sys = mathics3('{x^2 - 3y == 3, 2x - y == 1}')
    sage: print(sys)
    {x ^ 2 - 3 y == 3, 2 x - y == 1}
    sage: sys.Solve('{x, y}')
    {{x -> 0, y -> -1}, {x -> 6, y -> 11}}

Assignments and definitions
~~~~~~~~~~~~~~~~~~~~~~~~~~~

If you assign the mathics3 `5` to a variable `c`
in Sage, this does not affect the `c` in Mathics3.

::

    sage: c = m(5)                          # optional - mathics3
    sage: print(m('b + c x'))               # optional - mathics3
                 b + c x
    sage: print(m('b') + c*m('x'))          # optional - mathics3
    b + 5 x

The Sage interfaces changes Sage lists into Mathics3 lists::

    sage: m = mathics3
    sage: eq1 = m('x^2 - 3y == 3')          # optional - mathics3
    sage: eq2 = m('2x - y == 1')            # optional - mathics3
    sage: v = m([eq1, eq2]); v              # optional - mathics3
    {x ^ 2 - 3 y == 3, 2 x - y == 1}
    sage: v.Solve(['x', 'y'])               # optional - mathics3
    {{x -> 0, y -> -1}, {x -> 6, y -> 11}}

Function definitions
~~~~~~~~~~~~~~~~~~~~

Define mathics3 functions by simply sending the definition to
the interpreter.

::

    sage: m = mathics3
    sage: _ = mathics3('f[p_] = p^2');       # optional - mathics3
    sage: m('f[9]')                         # optional - mathics3
    81

Numerical Calculations
~~~~~~~~~~~~~~~~~~~~~~

We find the `x` such that `e^x - 3x = 0`.

::

    sage: eqn = mathics3('Exp[x] - 3x == 0') # optional - mathics3
    sage: eqn.FindRoot(['x', 2])            # optional - mathics3
    {x -> 1.51213}

Note that this agrees with what the PARI interpreter gp produces::

    sage: gp('solve(x=1,2,exp(x)-3*x)')
    1.5121345516578424738967396780720387046

Next we find the minimum of a polynomial using the two different
ways of accessing Mathics3::

    sage: mathics3('FindMinimum[x^3 - 6x^2 + 11x - 5, {x,3}]')  # not tested (since not supported, so far)
    {0.6151, {x -> 2.57735}}
    sage: f = mathics3('x^3 - 6x^2 + 11x - 5')                  # optional - mathics3
    sage: f.FindMinimum(['x', 3])                               # not tested (since not supported, so far)
    {0.6151, {x -> 2.57735}}

Polynomial and Integer Factorization
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

We factor a polynomial of degree 200 over the integers.

::

    sage: R.<x> = PolynomialRing(ZZ)
    sage: f = (x**100+17*x+5)*(x**100-5*x+20)
    sage: f
    x^200 + 12*x^101 + 25*x^100 - 85*x^2 + 315*x + 100
    sage: g = mathics3(str(f))               # optional - mathics3
    sage: print(g)                           # optional - mathics3
    100 + 315 x - 85 x ^ 2 + 25 x ^ 100 + 12 x ^ 101 + x ^ 200
    sage: g                                  # optional - mathics3
    100 + 315 x - 85 x ^ 2 + 25 x ^ 100 + 12 x ^ 101 + x ^ 200
    sage: print(g.Factor())                  # optional - mathics3
    (5 + 17 x + x ^ 100) (20 - 5 x + x ^ 100)

We can also factor a multivariate polynomial::

    sage: f = mathics3('x^6 + (-y - 2)*x^5 + (y^3 + 2*y)*x^4 - y^4*x^3')  # optional - mathics3
    sage: print(f.Factor())                  # optional - mathics3
    x ^ 3 (x - y) (-2 x + x ^ 2 + y ^ 3)

We factor an integer::

    sage: # optional - mathics3
    sage: n = mathics3(2434500)
    sage: n.FactorInteger()
    {{2, 2}, {3, 2}, {5, 3}, {541, 1}}
    sage: n = mathics3(2434500)
    sage: F = n.FactorInteger(); F
    {{2, 2}, {3, 2}, {5, 3}, {541, 1}}
    sage: F[1]
    {2, 2}
    sage: F[4]
    {541, 1}


Long Input
----------

The Mathics3 interface reads in even very long input (using
files) in a robust manner.

::

    sage: t = '"%s"'%10^10000   # ten thousand character string.
    sage: a = mathics3(t)        # optional - mathics3
    sage: a = mathics3.eval(t)   # optional - mathics3

Loading and saving
------------------

Mathics3 has an excellent ``InputForm`` function,
which makes saving and loading Mathics3 objects possible. The
first examples test saving and loading to strings.

::

    sage: # optional - mathics3
    sage: x = mathics3(pi/2)
    sage: print(x)
    pi / 2
    sage: loads(dumps(x)) == x
    True
    sage: n = x.N(50)
    sage: print(n)
                  1.5707963267948966192313216916397514420985846996876
    sage: loads(dumps(n)) == n
    True

Complicated translations
------------------------

The ``mobj.sage()`` method tries to convert a Mathics3 object to a Sage
object. In many cases, it will just work. In particular, it should be able to
convert expressions entirely consisting of:

- numbers, i.e. integers, floats, complex numbers;
- functions and named constants also present in Sage, where:

    - Sage knows how to translate the function or constant's name from
      Mathics3's, or
    - the Sage name for the function or constant is trivially related to
      Mathics3's;

- symbolic variables whose names don't pathologically overlap with
  objects already defined in Sage.

This method will not work when Mathics3's output includes:

- strings;
- functions unknown to Sage;
- Mathics3 functions with different parameters/parameter order to
  the Sage equivalent.

A list of Mathics3 mathematical constants that we have Sage equivalents for:

   sage: [mathics3(c).sage() for c in ('Catalan', 'Glaisher', 'GoldenRatio', 'EulerGamma', 'Khinchin', 'Pi')]
   [catalan, glaisher, golden_ratio, euler_gamma, khinchin, pi]

If you want to convert more complicated Mathics3 expressions, you can
instead call ``mobj._sage_()`` and supply a translation dictionary::

    sage: x = var('x')
    sage: m = mathics3('NewFn[x]')                # optional - mathics3
    sage: m._sage_(locals={'NewFn': sin, 'x':x})  # optional - mathics3
    sin(x)

For more details, see the documentation for ``._sage_()``.


OTHER Examples::

    sage: def math_bessel_K(nu, x):
    ....:     return mathics3(nu).BesselK(x).N(20)
    sage: math_bessel_K(2,I)                      # optional - mathics3
    -2.5928861754911969782 + 0.18048997206696202663 I

::

    sage: slist = [[1, 2], 3., 4 + I]
    sage: mlist = mathics3(slist); mlist         # optional - mathics3
    {{1, 2}, 3., 4 + I}
    sage: slist2 = list(mlist); slist2          # optional - mathics3
    [{1, 2}, 3., 4 + I]
    sage: slist2[0]                             # optional - mathics3
    {1, 2}
    sage: slist2[0].parent()                    # optional - mathics3
    Mathics3
    sage: slist3 = mlist.sage(); slist3         # optional - mathics3
    [[1, 2], 3.00000000000000, 4.00000000000000 + 1.00000000000000*I]

::

    sage: mathics3('10.^80')         # optional - mathics3
    1.×10^80
    sage: mathics3('10.^80').sage()  # optional - mathics3
    1.00000000000000e80

AUTHORS:

- Sebastian Oehms (2021): first version from a copy of the Mathematica interface (see :issue:`31778`).
- Rashad Alsharpini (2026): port to Mathics3 10.0.0 (see SAGE pull request 41885).


Thanks to Rocky Bernstein and Juan Mauricio Matera for their support. For further acknowledgments see `this list <https://github.com/Mathics3/mathics-core/blob/master/AUTHORS.txt>`__.

TESTS:

Check that numerical approximations via Mathics3's `N[]` function work
correctly (:issue:`18888`, :issue:`28907`)::

    sage: # optional - mathics3
    sage: mathics3('Pi/2').N(10)
    1.570796327
    sage: mathics3('Pi').N(10)
    3.141592654
    sage: mathics3('Pi').N(50)
    3.1415926535897932384626433832795028841971693993751
    sage: str(mathics3('Pi*x^2-1/2').N())
    '-0.5 + 3.14159 x ^ 2.'

Check that Mathics3's `E` exponential symbol is correctly backtranslated
as Sage's `e` (:issue:`29833`)::

    sage: (e^x)._mathics3_().sage()  # optional -- mathics3
    e^x
    sage: exp(x)._mathics3_().sage() # optional -- mathics3
    e^x
"""

##############################################################################
#       Copyright (C) 2021 Sebastian Oehms <seb.oehms@gmail.com>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 2 of the License, or
# (at your option) any later version.
#                  https://www.gnu.org/licenses/
##############################################################################

from typing import Dict, Final
import os

import sage.symbolic.expression
from mathics.core.symbols import Symbol, SymbolFalse, SymbolTrue
from mathics.core.systemsymbols import (
    SymbolCatalan,
    SymbolE,
    SymbolEulerGamma,
    SymbolGoldenRatio,
    SymbolKhinchin,
    SymbolPi,
)
from sage.all import (
    Integer,
    Rational,
    RealNumber,
    SR,
    catalan,
    e,
    euler_gamma,
    glaisher,
    golden_ratio,
    khinchin,
    pi,
)
from sage.misc.cachefunc import cached_method
from sage.interfaces.abc import Mathics3Element as ABCMathics3Element
from sage.interfaces.interface import Interface, InterfaceElement, InterfaceFunction, InterfaceFunctionElement
from sage.interfaces.tab_completion import ExtraTabCompletion
from sage.misc.instancedoc import instancedoc
from sage.structure.richcmp import rich_to_bool

MATHICS3_TO_SAGE_CONSTANT: Final[Dict[Symbol, sage.symbolic.expression]] = {
    SymbolCatalan: catalan,
    SymbolEulerGamma: euler_gamma,
    SymbolE: e,
    SymbolFalse: False,
    Symbol("System`Glaisher"): glaisher,
    SymbolGoldenRatio: golden_ratio,
    SymbolKhinchin: khinchin,
    SymbolPi: pi,
    SymbolTrue: True,
}


def _mathics3_sympysage_symbol(self):
    r"""
    Convert a Sympy symbol ``self`` to a corresponding element
    in Sage's symbolic ring.

    This function replaces ``_sympysage_symbol`` to
    take care of the special names used in Mathics3.
    It is set to the method ``_sage_`` of the Sympy class
    :class:`sympy.core.symbol.Symbol`.

    EXAMPLES::

        sage: # optional - mathics3
        sage: from sage.interfaces.mathics3 import _mathics3_sympysage_symbol
        sage: mt = mathics3('t')
        sage: st = mt.to_sympy(); st
        _uGlobal_t
        sage: _mathics3_sympysage_symbol(st)
        t
        sage: bool(_ == st._sage_())
        True
        sage: type(st._sage_())
        <class 'sage.symbolic.expression.Expression'>
    """
    from sage.symbolic.ring import SR
    try:
        name = self.name
        if name.startswith('_Mathics_User_'):
            name = name.split('`')[1]
        elif name.startswith("_uGlobal_"):
            name = name[9:]
        if name == mathics3._true_symbol():
            return True
        if name == mathics3._false_symbol():
            return False
        return SR.var(name)
    except ValueError:
        # sympy sometimes returns dummy variables
        # with name = 'None', str rep = '_None'
        # in particular in inverse Laplace and inverse Mellin transforms
        return SR.var(str(self))


class Mathics3(Interface):
    r"""
    Interface to the Mathics3 interpreter.

    Implemented according to the Mathematica interface but avoiding Pexpect
    functionality.

    EXAMPLES::

        sage: # optional - mathics3
        sage: t = mathics3('Tan[I + 0.5]')
        sage: t.parent()
        Mathics3
        sage: ts = t.sage()
        sage: ts.parent()
        Complex Field with 53 bits of precision
        sage: t == mathics3(ts)
        True
        sage: mtan = mathics3.Tan
        sage: mt = mtan(I+1/2)
        sage: mt == t
        True
        sage: u = mathics3(I+1/2)
        sage: u.Tan() == mt
        True


    More examples can be found in the module header.
    """
    def __init__(self,
                 maxread=None,
                 logfile=None,
                 init_list_length=1024,
                 seed=None):
        r"""
        Python constructor.

        EXAMPLES::

            sage: mathics3._mathics3_init_ == mathics3._mathematica_init_
            True
        """

        Interface.__init__(self, name='mathics3')
        self._seed = seed
        self._initialized = False  # done lazily
        self._session = None
        os.environ['MATHICS_CHARACTER_ENCODING'] = 'ASCII'  # see :issue:`37395`

    def _lazy_init(self):
        r"""
        Initialize the Mathics3 interpreter.

        Implemented according to R interface.

        EXAMPLES::

            sage: mathics3._lazy_init()   # optional - mathics3
        """
        if not self._initialized:
            self._initialized = True
            self._start()

    def _start(self):
        """
        Start up the Mathics3 interpreter and sets the initial prompt and options.

        This is called the first time the Mathics3 interface is actually used.

        EXAMPLES::

            sage: mathics3._start()            # optional - mathics3
            sage: type(mathics3._session)      # optional - mathics3
            <class 'mathics.session.MathicsSession'>
        """
        if not self._session:
            from mathics.session import MathicsSession
            from mathics.core.load_builtin import import_and_load_builtins
            import_and_load_builtins()
            self._session = MathicsSession(add_builtin=True)
            from sage.interfaces.sympy import sympy_init
            sympy_init()
            from sympy import Symbol
            Symbol._sage_ = _mathics3_sympysage_symbol

    def _read_in_file_command(self, filename):
        r"""
        EXAMPLES::

            sage: from sage.misc.temporary_file import tmp_filename
            sage: fn = tmp_filename()
            sage: mathics3('40!>>%s' %fn)                     # optional - mathics3
            815915283247897734345611269596115894272000000000
            sage: mathics3(mathics3._read_in_file_command(fn)) # optional - mathics3
            815915283247897734345611269596115894272000000000
            sage: os.system('rm %s' %fn)                     # optional - mathics3
            0
        """
        return '<<"%s"' % filename

    def _install_hints(self):
        """
        Hints for installing mathics3 on your computer.

        EXAMPLES::

            sage: len(mathics3._install_hints())  # optional - mathics3
            103
        """
        return """
In order to use the Mathics3 interface you need to have the
optional Sage package Mathics3 installed.
"""

    def _eval(self, code):
        """
        Evaluates a command inside the Mathics3 interpreter and returns the output
        as a Mathics3 result.

        EXAMPLES::

            sage: mathics3._eval('1+1').last_eval  # optional - mathics3
            <Integer: 2>
        """
        self._lazy_init()
        S = self._session
        expr = S.evaluate(code)
        from mathics.core.evaluation import Evaluation
        ev = Evaluation(S.definitions)
        return ev.evaluate(expr)

    def eval(self, code, *args, **kwds):
        """
        Evaluates a command inside the Mathics3 interpreter and returns the output
        in printable form.

        EXAMPLES::

            sage: mathics3.eval('1+1')  # optional - mathics3
            '2'
        """
        res = self._eval(code)
        if res.result == 'Null':
            if len(res.out) == 1:
                return str(res.out[0])
        return res.result

    def set(self, var, value):
        """
        Set the variable var to the given value.

        EXAMPLES::

            sage: mathics3.set('u', '2*x +E')         # optional - mathics3
            sage: bool(mathics3('u').sage() == 2*x+e) # optional - mathics3
            True
        """
        cmd = f'{var}={value};'
        _ = self.eval(cmd)

    def get(self, var):
        """
        Get the value of the variable var.

        EXAMPLES::

            sage: mathics3.set('u', '2*x +E')        # optional - mathics3
            sage: mathics3.get('u')                  # optional - mathics3
            '2 x + E'
        """
        return self.eval(var)

    def _function_call_string(self, function, args, kwds):
        """
        Return the string used to make function calls.

        EXAMPLES::

            sage: mathics3._function_call_string('Sin', ['x'], [])
            'Sin[x]'
        """
        return "{}[{}]".format(function, ",".join(args))

    def _left_list_delim(self):
        r"""
        EXAMPLES::

            sage: mathics3._left_list_delim()
            '{'
        """
        return "{"

    def _right_list_delim(self):
        r"""
        EXAMPLES::

            sage: mathics3._right_list_delim()
            '}'
        """
        return "}"

    def _left_func_delim(self):
        r"""
        EXAMPLES::

            sage: mathics3._left_func_delim()
            '['
        """
        return "["

    def _right_func_delim(self):
        r"""
        EXAMPLES::

            sage: mathics3._right_func_delim()
            ']'
        """
        return "]"

    # #########################################
    # System -- change directory, etc.
    # #########################################
    def chdir(self, dir):
        """
        Change Mathics3's current working directory.

        EXAMPLES::

            sage: mathics3.chdir('/')          # optional - mathics3
            sage: mathics3('Directory[]')      # optional - mathics3
            /
        """
        self.eval('SetDirectory["%s"]' % dir)

    def _true_symbol(self):
        r"""
        EXAMPLES::

            sage: mathics3._true_symbol()
            'True'
        """
        return 'True'

    def _false_symbol(self):
        r"""
        EXAMPLES::

            sage: mathics3._false_symbol()
            'False'
        """
        return 'False'

    def _equality_symbol(self):
        r"""
        EXAMPLES::

            sage: mathics3._equality_symbol()
            '=='
        """
        return '=='

    def _assign_symbol(self):
        r"""
        EXAMPLES::

            sage: mathics3._assign_symbol()
            ':='
        """
        return ':='

    def _exponent_symbol(self):
        r"""
        Return the symbol used to denote the exponent of a number in
        Mathics3.

        EXAMPLES::

            sage: mathics3._exponent_symbol()
            '*^'

        ::

            sage: bignum = mathics3('10.^80')      # optional - mathics3
            sage: repr(bignum)                     # optional - mathics3
            '1.×10^80'
            sage: repr(bignum).replace(mathics3._exponent_symbol(), 'e').strip() # optional - mathics3
            '1.×10^80'
        """
        return '*^'

    def _object_class(self):
        r"""
        Return the element class of this parent.
        This is used in the interface class.

        EXAMPLES::

            sage: mathics3._object_class()
            <class 'sage.interfaces.mathics3.Mathics3Element'>
        """
        return Mathics3Element

    def console(self):
        r"""
        Spawn a new Mathics3 command-line session.

        EXAMPLES::

            sage: mathics3.console()  # not tested

            Mathics3 10.0.0
            Running on linux CPython 3.12.3 (main, Mar 23 2026, 19:04:32) [GCC 13.3.0]
            using SymPy 1.14.0, mpmath 1.3.0, numpy 2.4.3, cython 3.2.4, scipy 1.17.1, skimage Not installed

            Copyright (C) 2011-2026 The Mathics3 Team.
            This program comes with ABSOLUTELY NO WARRANTY.
            This is free software, and you are welcome to redistribute it
            under certain conditions.
            See the documentation for the full license.

            Quit by evaluating Quit[] or by pressing CONTROL-D.

            In[1]:= Sin[0.5]
            Out[1]= 0.479426

            Goodbye!

            sage:
        """
        mathics3_console()

    def help(self, cmd, long=False):
        r"""
        Return the Mathics3 documentation of the given command.

        EXAMPLES::

            sage: mathics3.help('Sin')                   # optional - mathics3
            'sine function\n'

            sage: print(_)                              # optional - mathics3
            sine function
            <BLANKLINE>

            sage: print(mathics3.help('Sin', long=True)) # optional - mathics3
            sine function
            <BLANKLINE>
            Attributes[Sin] = {Listable, NumericFunction, Protected}
            <BLANKLINE>

            sage: print(mathics3.Factorial.__doc__)  # optional - mathics3
            factorial
            <BLANKLINE>

            sage: u = mathics3('Pi')                 # optional - mathics3
            sage: print(u.Cos.__doc__)               # optional - mathics3
            cosine function
            <BLANKLINE>
        """
        if long:
            return self.eval('Information[%s]' % cmd)
        return self.eval('? %s' % cmd)

    def __getattr__(self, attrname):
        r"""
        EXAMPLES::

            sage: msin = mathics3.Sin          # optional - mathics3
            sage: msin(0.2)                    # optional - mathics3
            0.19866933079506123
            sage: _ == sin(0.2)                # optional - mathics3
            True
        """
        if attrname[:1] == "_":
            raise AttributeError
        return InterfaceFunction(self, attrname)


def mathics3_to_sage(m_node, locals=None):
    import mathics.core.atoms as m_atoms
    import mathics.core.symbols as m_symbols
    import mathics.core.expression as m_expr

    if locals is None:
        locals = {}

    if isinstance(m_node, m_atoms.Integer):
        return Integer(str(m_node))
    if isinstance(m_node, m_atoms.Rational):
        return Rational(str(m_node))
    if isinstance(m_node, m_atoms.Real):
        return RealNumber(str(m_node))
    if isinstance(m_node, m_symbols.Symbol):
        if m_node in MATHICS3_TO_SAGE_CONSTANT:
            return MATHICS3_TO_SAGE_CONSTANT[m_node]

        name = m_node.get_name()
        name_short = name.split("`")[-1]
        if name_short in locals:
            return locals[name_short]
        return SR.var(name_short)

    if isinstance(m_node, m_atoms.String):
        return str(m_node.value)

    if isinstance(m_node, m_expr.Expression):
        head = m_node.get_head()
        elements = [mathics3_to_sage(el, locals) for el in m_node.get_elements()]
        head_name = head.get_name()

        if head_name == "System`Plus":
            return sum(elements) if elements else Integer(0)
        if head_name == "System`Times":
            import operator
            from functools import reduce

            return reduce(operator.mul, elements) if elements else Integer(1)
        if head_name == "System`Power":
            return elements[0] ** elements[1]
        if head_name == "System`List":
            return elements
        if head_name == "System`Rule":
            return (elements[0], elements[1])

        head_name_short = head_name.split("`")[-1]
        if head_name_short in locals:
            func = locals[head_name_short]
            return func(*elements) if callable(func) else func

        # Try finding the function in Sage
        try:
            import sage.all

            func = getattr(sage.all, head_name_short.lower())
            if callable(func):
                return func(*elements)
        except AttributeError:
            pass

        return getattr(SR.var(head_name_short), "__call__")(*elements)

    raise ValueError(f"Unknown node type: {type(m_node)}")


@instancedoc
class Mathics3Element(ExtraTabCompletion, InterfaceElement, ABCMathics3Element):
    r"""
    Element class of the Mathics3 interface.

    Its instances are usually constructed via the instance call of its parent.
    It wraps the Mathics3 library for this object. In a session Mathics3 methods
    can be obtained using tab completion.

    EXAMPLES::

        sage: # optional - mathics3
        sage: me=mathics3(e); me.sage()
        e
        sage: me=mathics3('E'); me.sage()
        e
        sage: type(me)
        <class 'sage.interfaces.mathics3.Mathics3Element'>
        sage: P = me.parent(); P
        Mathics3
        sage: type(P)
        <class 'sage.interfaces.mathics3.Mathics3'>

    Access to the Mathics3 expression objects::

        sage: # optional - mathics3
        sage: res = me._mathics3_result
        sage: type(res)
        <class 'mathics.core.evaluation.Result'>
        sage: expr = res.last_eval; expr
        <Symbol: System`E>
        sage: type(expr)
        <class 'mathics.core.symbols.Symbol'>

    Applying Mathics3 methods::

        sage: # optional - mathics3
        sage: me.to_sympy()
        E
        sage: me.get_name()
        'System`E'
        sage: me.is_inexact()
        False

    Conversion to Sage::

        sage: bool(me.sage() == e)             # optional - mathics3
        True
    """

    def _tab_completion(self):
        r"""
        Return a list of all methods of this object.

        .. NOTE::

           Currently returns all methods of :class:`mathics3.expression.Expression`.

        EXAMPLES::

            sage: a = mathics3(5*x)            # optional - mathics3
            sage: t = a._tab_completion()      # optional - mathics3
            sage: len(t) > 100                 # optional - mathics3
            True
        """
        return dir(self._mathics3_result.last_eval)

    def __getitem__(self, n):
        r"""
        EXAMPLES::

            sage: l = mathics3('{1, x, .15}')  # optional - mathics3
            sage: l[0]                         # optional - mathics3
            List
            sage: for i in l: print(i)         # optional - mathics3
            1
            x
            0.15
        """
        return self.parent().new(f'{self._name}[[{n}]]')

    def __getattr__(self, attrname):
        r"""
        EXAMPLES::

            sage: # optional - mathics3
            sage: a = mathics3(5*x)
            sage: res = a._mathics3_result
            sage: str(a) == res.result
            True
            sage: t = mathics3._eval('5*x')
            sage: t.last_eval  == res.last_eval
            True
        """
        P = self._check_valid()
        if attrname == '_mathics3_result':
            self._mathics3_result = P._eval(self.name())
            return self._mathics3_result
        if attrname[:1] == "_":
            raise AttributeError
        else:
            expr = self._mathics3_result.last_eval
            if hasattr(expr, attrname):
                return expr.__getattribute__(attrname)
        return InterfaceFunctionElement(self, attrname)

    def __float__(self, precision=16):
        r"""
        EXAMPLES::

            sage: float(mathics3('Pi')) == float(pi)  # optional - mathics3
            True
        """
        P = self.parent()
        return float(P._eval(f'N[{self.name()},{precision}]').last_eval.to_mpmath())

    def _reduce(self):
        r"""
        EXAMPLES::

            sage: slist = [[1, 2], 3., 4 + I]
            sage: mlist = mathics3(slist)   # optional - mathics3
            sage: mlist._reduce()           # optional - mathics3
            '{{1, 2}, 3., 4 + I}'
        """
        return str(self)

    def __reduce__(self):
        r"""
        EXAMPLES::

            sage: mpol = mathics3('x + y*z')    # optional - mathics3
            sage: loads(dumps(mpol)) == mpol    # optional - mathics3
            True
        """
        return reduce_load, (self._reduce(), )

    def _latex_(self):
        r"""
        EXAMPLES::

            sage: Q = mathics3('Sin[x Cos[y]]/Sqrt[1-x^2]')   # optional - mathics3
            sage: latex(Q)                                    # optional - mathics3
            \frac{\text{Sin}\left[x \text{Cos}\left[y\right]\right]}{\sqrt{1-x^2}}
        """
        z = str(self.parent()('TeXForm[%s]' % self.name()))
        i = z.find('=')
        return z[i + 1:]

    def _repr_(self):
        r"""
        EXAMPLES::

            sage: Q = mathics3('Sin[x Cos[y]]/Sqrt[1-x^2]')   # optional - mathics3
            sage: repr(Q)                                     # optional - mathics3
            'Sin[x Cos[y]] / Sqrt[1 - x ^ 2]'
        """
        return self._mathics3_result.result

    def _sage_(self, locals={}):
        r"""
        Attempt to return a Sage version of this object.

        This method works successfully when Mathics3 returns a result
        or list of results that consist only of:

        - numbers, i.e. integers, floats, complex numbers;
        - functions and named constants also present in Sage, where:
            - Sage knows how to translate the function or constant's name
              from Mathics3's naming scheme, or
            - you provide a translation dictionary `locals`, or
            - the Sage name for the function or constant is simply the
              Mathics3 name in lower case;

        - symbolic variables whose names do not pathologically overlap with
          objects already defined in Sage.

        This method will not work when Mathics3's output includes:

        - strings;
        - functions unknown to Sage;
        - Mathics3 functions with different parameters/parameter order to
          the Sage equivalent. In this case, define a function to do the
          parameter conversion, and pass it in via the locals dictionary.

        EXAMPLES:

        Mathics3 lists of numbers/constants become Sage lists of
        numbers/constants::

            sage: # optional - mathics3
            sage: m = mathics3('{{1., 4}, Pi, 3.2e100, I}')
            sage: s = m.sage(); s
            [[1.00000000000000, 4], pi, 3.20000000000000*e100, 1.00000000000000*I]
            sage: s[1].n()
            3.14159265358979
            sage: s[3]^2
            -1.00000000000000

        ::

            sage: m = mathics3('x^2 + 5*y')      # optional - mathics3
            sage: m.sage()                       # optional - mathics3
            x^2 + 5*y

        ::

            sage: m = mathics3('Sin[Sqrt[1-x^2]] * (1 - Cos[1/x])^2')  # optional - mathics3
            sage: m.sage()                          # optional - mathics3
            (cos(1/x) - 1)^2*sin(sqrt(-x^2 + 1))

        ::

            sage: m = mathics3('NewFn[x]')                 # optional - mathics3
            sage: m._sage_(locals={'NewFn': sin, 'x':x})   # optional - mathics3
            sin(x)

        ::

            sage: var('bla')                        # optional - mathics3
            bla
            sage: m = mathics3('bla^2')             # optional - mathics3
            sage: bla^2 - m.sage()                  # optional - mathics3
            0

        ::

            sage: # optional - mathics3
            sage: m = mathics3('bla^2')
            sage: mb = m.sage()
            sage: var('bla')
            bla
            sage: bla^2 - mb
            0
        """
        if locals:
            # if locals are given we use `_sage_repr`
            # surely this only covers simple cases
            from sage.misc.sage_eval import sage_eval
            return sage_eval(self._sage_repr(), locals=locals)

        self._check_valid()
        m_node = self._mathics3_result.last_eval
        if m_node is not None:
            try:
                return mathics3_to_sage(m_node, locals=locals)
            except Exception:
                pass

        if self.is_inexact():
            m = self.to_mpmath()
            if self is not m and m is not None:
                from sage.libs.mpmath.utils import mpmath_to_sage
                return mpmath_to_sage(m, self.get_precision())
        s = self.to_sympy()
        if self is not s and s is not None:
            import sympy

            if s is sympy.S.true:
                return True
            if s is sympy.S.false:
                return False
            if hasattr(s, '_sage_'):
                try:
                    return s._sage_()
                except NotImplementedError:  # see :issue:`33584`
                    pass
        p = self.to_python()
        if self is not p and p is not None:
            def conv(i):
                return self.parent()(i).sage()
            if isinstance(p, list):
                return [conv(i) for i in p]
            elif isinstance(p, tuple):
                return [conv(i) for i in p]
            elif type(p) is dict:
                return {conv(k): conv(v) for k, v in p.items()}
            return p
        return s

    def __len__(self):
        """
        Return the object's length, evaluated by mathics3.

        EXAMPLES::

            sage: len(mathics3([1,1.,2]))    # optional - mathics3
            3
        """
        return int(self.Length())

    @cached_method
    def _is_graphics(self):
        """
        Test whether the mathics3 expression is graphics.

        OUTPUT: boolean

        EXAMPLES::

            sage: P = mathics3('Plot[Sin[x],{x,-2Pi,4Pi}]')  # optional - mathics3
            sage: P._is_graphics()                           # optional - mathics3
            True
        """
        return str(self).startswith('-Graphics-')

    def save_image(self, filename, ImageSize=600):
        r"""
        Save a mathics3 graphics.

        INPUT:

        - ``filename`` -- string; the filename to save as. The
          extension determines the image file format

        - ``ImageSize`` -- integer; the size of the resulting image

        EXAMPLES::

            sage: P = mathics3('Plot[Sin[x],{x,-2Pi,4Pi}]')   # optional - mathics3
            sage: filename = tmp_filename(ext=".svg")         # optional - mathics3
            sage: P.save_image(filename, ImageSize=800)       # optional - mathics3
        """
        P = self._check_valid()
        if not self._is_graphics():
            raise ValueError('mathics3 expression is not graphics')
        filename = os.path.abspath(filename)
        s = f'Export["{filename}", {self.name()}, ImageSize->{ImageSize}]'
        P.eval(s)

    def _rich_repr_(self, display_manager, **kwds):
        """
        Rich Output Magic Method.

        See :mod:`sage.repl.rich_output` for details.

        EXAMPLES::

            sage: from sage.repl.rich_output import get_display_manager
            sage: dm = get_display_manager()
            sage: P = mathics3('Plot[Sin[x],{x,-2Pi,4Pi}]')       # optional - mathics3

        The following test requires a working X display on Linux so that the
        Mathics3 frontend can do the rendering (:issue:`23112`)::

            sage: P._rich_repr_(dm)                               # optional - mathics3
            OutputImageSvg container
        """
        if self._is_graphics():
            OutputImageSvg = display_manager.types.OutputImageSvg
            if display_manager.preferences.graphics == 'disable':
                return
            if OutputImageSvg in display_manager.supported_output():
                return display_manager.graphics_from_save(
                    self.save_image, kwds, '.svg', OutputImageSvg)
        else:
            OutputLatex = display_manager.types.OutputLatex
            dmp = display_manager.preferences.text
            if dmp is None or dmp == 'plain':
                return
            if dmp == 'latex' and OutputLatex in display_manager.supported_output():
                return OutputLatex(self._latex_())

    def show(self, ImageSize=600):
        r"""
        Show a mathics3 expression immediately.

        This method attempts to display the graphics immediately,
        without waiting for the currently running code (if any) to
        return to the command line. Be careful, calling it from within
        a loop will potentially launch a large number of external
        viewer programs.

        INPUT:

        - ``ImageSize`` -- integer; the size of the resulting image

        OUTPUT:

        This method does not return anything. Use :meth:`save` if you
        want to save the figure as an image.

        EXAMPLES::

            sage: Q = mathics3('Sin[x Cos[y]]/Sqrt[1-x^2]')   # optional - mathics3
            sage: show(Q)                                     # optional - mathics3
            Sin[x Cos[y]] / Sqrt[1 - x ^ 2]

            sage: P = mathics3('Plot[Sin[x],{x,-2Pi,4Pi}]')   # optional - mathics3
            sage: show(P)                                     # optional - mathics3
            sage: P.show(ImageSize=800)                       # optional - mathics3
        """
        from sage.repl.rich_output import get_display_manager
        dm = get_display_manager()
        dm.display_immediately(self, ImageSize=ImageSize)

    def _richcmp_(self, other, op):
        r"""
        EXAMPLES::

            sage: # optional - mathics3
            sage: mobj1 = mathics3([x^2-1, 2])
            sage: mobj2 = mathics3('{x^2-1, 2}')
            sage: mobj3 = mathics3('5*x + y')
            sage: mobj1 == mobj2
            True
            sage: mobj1 < mobj2
            False
            sage: mobj1 == mobj3
            False
        """
        P = self.parent()
        if str(P(f"{self.name()} < {other.name()}")) == P._true_symbol():
            return rich_to_bool(op, -1)
        if str(P(f"{self.name()} > {other.name()}")) == P._true_symbol():
            return rich_to_bool(op, 1)
        if str(P(f"{self.name()} == {other.name()}")) == P._true_symbol():
            return rich_to_bool(op, 0)
        return NotImplemented

    def __bool__(self):
        """
        Return whether this Mathics3 element is not identical to ``False``.

        EXAMPLES::

            sage: bool(mathics3(True))   # optional - mathics3
            True
            sage: bool(mathics3(False))  # optional - mathics3
            False

        In Mathics3, `0` cannot be used to express falsity::

            sage: bool(mathics3(0))     # optional - mathics3
            True
        """
        P = self._check_valid()
        cmd = f'{self._name}==={P._false_symbol()}'
        return not str(P(cmd)) == P._true_symbol()

    def n(self, *args, **kwargs):
        r"""
        Numerical approximation by converting to Sage object first.

        Convert the object into a Sage object and return its numerical
        approximation. See documentation of the function
        :func:`sage.misc.functional.n` for details.

        EXAMPLES::

            sage: mathics3('Pi').n(10)    # optional -- mathics3
            3.1
            sage: mathics3('Pi').n()      # optional -- mathics3
            3.14159265358979
            sage: mathics3('Pi').n(digits=10)   # optional -- mathics3
            3.141592654
        """
        return self._sage_().n(*args, **kwargs)


# An instance
mathics3 = Mathics3()


def reduce_load(X):
    """
    Used in unpickling a Mathics3 element.

    This function is just the ``__call__`` method of the interface instance.

    EXAMPLES::

        sage: sage.interfaces.mathics3.reduce_load('Denominator[a / b]')  # optional -- mathics3
        b
    """

    return mathics3(X)


def mathics3_console():
    r"""
    Spawn a new Mathics3 command-line session.

    EXAMPLES::

        sage: mathics3_console()  # not tested

        Mathics3 10.0.0
        Running on linux CPython 3.14.3 (main, Mar 30 2026, 06:42:16) [GCC 13.3.0]
        using SymPy 1.13.3, mpmath 1.3.0, numpy 2.4.4, cython 3.2.4, scipy 1.17.1, skimage 0.26.0

        Copyright (C) 2011-2026 The Mathics3 Team.
        This program comes with ABSOLUTELY NO WARRANTY.
        This is free software, and you are welcome to redistribute it
        under certain conditions.
        See the documentation for the full license.

        Quit by evaluating Quit[] or by pressing CONTROL-D.

        In[1]:= Sin[0.5]
        Out[1]= 0.479426

        Goodbye!
    """
    from sage.repl.rich_output.display_manager import get_display_manager
    if not get_display_manager().is_in_terminal():
        raise RuntimeError('Can use the console only in the terminal. Try %%mathics3 magics instead.')
    from mathics import __main__ as main
    main.main()
