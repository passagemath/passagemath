# sage.doctest: optional - mathics3
# sage_setup: distribution = sagemath-symbolics
"""
Conversion of symbolic expressions to Mathics3
"""

# ****************************************************************************
# Copyright (C) 2026 Rocky Bernstein
# This program is based on SymPy conversion.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 2 of the License, or
# (at your option) any later version.
#                  https://www.gnu.org/licenses/
# ****************************************************************************

from operator import add, eq, ge, gt, le, lt, mul, ne, neg, pow, truediv

from mathics.core.atoms import IntegerM1
from mathics.core.atoms.numerics import Complex as Mathics3Complex
from mathics.core.atoms.numerics import Rational as Mathics3Rational
from mathics.core.atoms.numerics import Real as Mathics3Real
from mathics.core.convert.python import from_python
from mathics.core.expression import Expression as Mathics3Expression
from mathics.core.symbols import Symbol as Mathics3Symbol
from mathics.core.symbols import SymbolDivide, SymbolPlus, SymbolPower, SymbolTimes
from sage.all import RDF, ZZ, Rational
from sage.interfaces.mathics3 import MATHICS3_TO_SAGE_CONSTANT, Mathics3
from sage.rings.complex_double import ComplexDoubleElement
from sage.rings.complex_mpfr import ComplexNumber
from sage.rings.real_mpfr import RealField_class
from sage.structure.element import Expression
from sage.symbolic.constants import Constant
from sage.symbolic.expression_conversions import Converter
from sage.symbolic.operators import arithmetic_operators

SAGE_CONSTANT_TO_MATHICS3 = {
    value: key for key, value in MATHICS3_TO_SAGE_CONSTANT.items()
}


class Mathics3Converter(Converter):
    """
    Convert any expression to Mathics3

    EXAMPLES::

        sage: import mathics3
        sage: f = Exp(x^2) - ArcSin[pi+x]/y
        sage: f._sympy_()
        exp(x**2) - asin(x + pi)/y
        sage: _._sage_()
        -arcsin(pi + x)/y + e^(x^2)

    TESTS:

    Make sure we can convert I (:issue:`6424`)::

        sage: bool(I._sympy_() == I)
        True
        sage: (x+I)._sympy_()
        x + I
    """

    def __init__(self):
        """
        TESTS::

            sage: from sage.symbolic.expression_conversions import Mathics3Converter
            sage: s = Mathics3Converter()  # indirect doctest
            sage: TestSuite(s).run(skip='_test_pickling')
        """
        self.mathics3 = Mathics3()

    def __call__(self, ex=None):
        """
        EXAMPLES::

            sage: from sage.symbolic.expression_conversions import Mathics3Converter
            sage: s = Mathics3Converter()  # indirect doctest
            sage: f(x, y) = x^2 + y^2; f
            (x, y) |--> x^2 + y^2
            sage: s(f)
            ??? Expression? Lambda((x, y), x**2 + y**2)
        """
        if isinstance(ex, Expression) and ex.is_callable():
            # FIXME should get the function name. And then run in Mathics3
            # f[x, y] := f(x, y) = x^2 + y^2
            elements = [self.convert_object_to_mathics3(arg) for arg in ex.arguments()]
            # FIXME: not right.
            return Mathics3Expression(elements[0], *elements[1:])
        return super().__call__(ex)

    def pyobject(self, ex, obj):
        """
        EXAMPLES::

            sage: from sage.symbolic.expression_conversions import Mathics3Converter
            sage: s = Mathics3Converter()
            sage: x = SR(2)
            sage: s.pyobject(x, x.pyobject())
            <Integer: 2>
            sage: type(_)
            <class 'mathics.core.atoms.numerics.Integer'>
            sage: x = SR(2.0)
            sage: s.pyobject(x, x.pyobject())
            <MachineReal: 2.0>
            sage: type(_)
            <class 'mathics.core.atoms.numerics.MachineReal'>>
            sage: x = SR(2/3)
            sage: s.pyobject(x, x.pyobject())
            <Rational: 2/3>
            sage: type(_)
            <class 'mathics.core.atoms.numerics.Rational'>
            sage: x = SR(2 + 3j))
            sage: s.pyobject(x, x.pyobject())
            <Complex: 2.0 + 3.0*I>
            sage: type(_)
            <class 'mathics.core.atoms.numerics.Complex'>
        """
        try:
            return self.convert_object_to_mathics3(obj)
        except AttributeError:
            return obj

    def arithmetic(self, ex, operator):
        """
        EXAMPLES::

            sage: from sage.symbolic.expression_conversions import Mathics3Converter
            sage: s = Mathics3Converter()
            sage: f = x + 2
            sage: s.arithmetic(f, f.operator())
            <Expression: <Symbol: System`Plus>[<Integer: 2>, <Symbol: System`x>]>
        """
        operator = arithmetic_operators[operator]
        elements = [self.convert_object_to_mathics3(arg) for arg in ex.operands()]
        match operator:
            # FIXME: Add in floordiv, neg, pos, abs?
            case "+":
                mathics3_expr = Mathics3Expression(SymbolPlus, *elements)
            case "*":
                mathics3_expr = Mathics3Expression(SymbolTimes, *elements)
            case "-":
                mathics3_expr = Mathics3Expression(
                    SymbolPlus, Mathics3Expression(SymbolTimes, *elements, IntegerM1)
                )
            case "/":
                mathics3_expr = Mathics3Expression(SymbolDivide, *elements)
            case "^":
                mathics3_expr = Mathics3Expression(SymbolPower, *elements)
            case _:
                raise NotImplementedError
        value = self.evaluate(mathics3_expr)
        return value

    def convert_object_to_mathics3(self, obj):

        if obj in ZZ:
            if (parent := obj.parent()) is RDF or isinstance(parent, RealField_class):
                # Convert hardware/arbitrary precision reals to Mathics3Real.
                if hasattr(obj, "_mpmath_"):
                    return Mathics3Real(obj._mpmath_())
                return from_python(float(obj))

            return from_python(sage_to_python_int(obj))
        elif isinstance(obj, Rational):
            # Convert Sage Rationals to Mathics3 Rational.
            return Mathics3Rational(
                self.convert_object_to_mathics3(obj.numerator()),
                self.convert_object_to_mathics3(obj.denominator()),
            )
        elif isinstance(obj, (ComplexDoubleElement, ComplexNumber)):
            # Convert hardware/arbitrary precision complex numbers to Mathics3 Complex.
            return Mathics3Complex(
                self.convert_object_to_mathics3(obj.real()),
                self.convert_object_to_mathics3(obj.imag()),
            )
        elif isinstance(obj, Constant):
            return SAGE_CONSTANT_TO_MATHICS3.get(obj.expression(), obj)
        elif obj.is_symbol():
            return self.symbol(obj)

    def derivative(self, ex, operator):
        """
        Convert the derivative of ``self`` in sympy.

        INPUT:

        - ``ex`` -- a symbolic expression

        - ``operator`` -- operator

        TESTS::

            sage: var('x','y')
            (x, y)

            sage: f_sage = function('f_sage')(x, y)
            sage: f_sympy = f_sage._sympy_()

            sage: df_sage = f_sage.diff(x, 2, y, 1); df_sage
            diff(f_sage(x, y), x, x, y)
            sage: df_sympy = df_sage._sympy_(); df_sympy
            Derivative(f_sage(x, y), (x, 2), y)
            sage: df_sympy == f_sympy.diff(x, 2, y, 1)
            True

        Check that :issue:`28964` is fixed::

            sage: f = function('f')
            sage: _ = var('x,t')
            sage: diff(f(x, t), x)._sympy_(), diff(f(x, t), t)._sympy_()
            (Derivative(f(x, t), x), Derivative(f(x, t), t))

        Check differentiating by variables with multiple occurrences
        (:issue:`28964`)::

            sage: f = function('f')
            sage: _ = var('x1,x2,x3,x,t')
            sage: f(x, x, t).diff(x)._sympy_()._sage_()
            D[0](f)(x, x, t) + D[1](f)(x, x, t)

            sage: g = f(x1, x2, x3, t).diff(x1, 2, x2).subs(x1==x, x2==x, x3==x); g
            D[0, 0, 1](f)(x, x, x, t)
            sage: g._sympy_()
            Subs(Derivative(f(_xi_1, _xi_2, x, t), (_xi_1, 2), _xi_2),
                 (_xi_1, _xi_2), (x, x))
            sage: assert g._sympy_()._sage_() == g

        Check that the use of dummy variables does not cause a collision::

            sage: f = function('f')
            sage: _ = var('x1,x2,x,xi_1')
            sage: g = f(x1, x2, xi_1).diff(x1).subs(x1==x, x2==x); g
            D[0](f)(x, x, xi_1)
            sage: assert g._sympy_()._sage_() == g
        """
        import sympy

        # retrieve derivated function
        f = operator.function()

        # retrieve order
        order = operator._parameter_set
        # arguments
        _args = [a._sympy_() for a in ex.operands()]

        # when differentiating by a variable that occurs multiple times,
        # substitute it by a dummy variable
        subs_new = []
        subs_old = []
        sympy_arg = []
        for idx in order:
            a = _args[idx]
            if _args.count(a) > 1:
                D = sympy.Dummy("xi_%i" % (idx + 1))
                # to avoid collisions with ordinary symbols when converting
                # back to Sage, we pick an unused variable name for the dummy
                while D._sage_() in ex.variables():
                    D = sympy.Dummy(D.name + "_0")
                subs_old.append(a)
                subs_new.append(D)
                _args[idx] = D
                sympy_arg.append(D)
            else:
                sympy_arg.append(a)

        f_sympy = f._sympy_()(*_args)
        result = f_sympy.diff(*sympy_arg)
        if subs_new:
            return sympy.Subs(result, subs_new, subs_old)
        else:
            return result

    def evaluate(self, ex):
        if self.mathics3._session is None:
            self.mathics3._start()
        return ex.evaluate(self.mathics3._session.evaluation)

    def relation(self, ex, op):
        """
        EXAMPLES::

            sage: import operator
            sage: from sage.symbolic.expression_conversions import SympyConverter
            sage: s = SympyConverter()
            sage: s.relation(x == 3, operator.eq)
            Eq(x, 3)
            sage: s.relation(pi < 3, operator.lt)
            pi < 3
            sage: s.relation(x != pi, operator.ne)
            Ne(x, pi)
            sage: s.relation(x > 0, operator.gt)
            x > 0
        """
        from sympy import Eq, Ge, Gt, Le, Lt, Ne

        ops = {eq: Eq, ne: Ne, gt: Gt, lt: Lt, ge: Ge, le: Le}
        return ops.get(op)(self(ex.lhs()), self(ex.rhs()), evaluate=False)

    def composition(self, ex, operator):
        """
        EXAMPLES::

            sage: from sage.symbolic.expression_conversions import Mathics3Converter
            sage: s = Mathics3Converter()  # indirect doctest
            sage: f = sin(2)
            sage: s.composition(f, f.operator())
            sin(2)
            sage: type(_)
            sin
            sage: f = arcsin(2)
            sage: s.composition(f, f.operator())
            asin(2)
        """
        g = ex.operands()
        try:
            return operator._sympy_(*g)
        except (AttributeError, TypeError):
            pass
        f = operator._sympy_init_()
        import sympy

        f_sympy = getattr(sympy, f, None)
        if f_sympy:
            return f_sympy(*sympy.sympify(g, evaluate=False))
        else:
            return sympy.Function(str(f))(*g, evaluate=False)

    def symbol(self, ex):
        """
        EXAMPLES::

            sage: from sage.symbolic.expression_conversions import Mathics3Converter
            sage: s = Mathics3Converter()  # indirect doctest
            sage: s.symbol(x)
            <Symbol: System`x>
            sage: type(_)
            <class 'mathics.core.symbols.Symbol'>
        """
        # FIXME: we should figure out the context, e.g. System or Global.
        return Mathics3Symbol(repr(ex))

    def tuple(self, ex):
        """
        Conversion of tuples.

        EXAMPLES::

            sage: t = SR._force_pyobject((3, 4, e^x))
            sage: t._sympy_()
            (3, 4, e^x)
            sage: t = SR._force_pyobject((cos(x),))
            sage: t._sympy_()
            (cos(x),)

        TESTS::

            sage: from sage.symbolic.expression_conversions import sympy_converter
            sage: F = hypergeometric([1/3,2/3],[1,1],x)
            sage: F._sympy_()
            hyper((1/3, 2/3), (1, 1), x)

            sage: F = hypergeometric([1/3,2/3],[1],x)
            sage: F._sympy_()
            hyper((1/3, 2/3), (1,), x)

            sage: var('a,b,c,d')
            (a, b, c, d)
            sage: hypergeometric((a,b,),(c,),d)._sympy_()
            hyper((a, b), (c,), d)
        """
        return tuple(ex.operands())


def sage_to_python_int(val):
    # Reject complex/Gaussian numbers upfront
    if hasattr(val, "imag") and val.imag() != 0:
        raise ValueError(
            f"{val} is a complex/Gaussian integer and cannot become a Python int."
        )

    # Try direct Python int() conversion (Works for Standard, Modular, bounded Intervals)
    try:
        return int(val)
    except (TypeError, ValueError):
        pass

    # Try lifting mathematical context (Works for p-adics, Algebraic Integers)
    if hasattr(val, "lift"):
        return int(val.lift())

    # Fallback coerce through Sage's Integer Ring
    return int(ZZ(val))


mathics3_converter = Mathics3Converter()
