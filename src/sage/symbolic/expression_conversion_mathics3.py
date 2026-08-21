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

from operator import eq, ge, gt, le, lt, ne

# Unused operators:
# from operator import add, mul, neg, pow, truediv
from mathics.core.atoms import IntegerM1
from mathics.core.atoms.numerics import Complex as Mathics3Complex
from mathics.core.atoms.numerics import Rational as Mathics3Rational
from mathics.core.atoms.numerics import Real as Mathics3Real
from mathics.core.convert.python import from_python
from mathics.core.convert.sympy import sympy_to_mathics
from mathics.core.expression import Expression as Mathics3Expression
from mathics.core.list import ListExpression
from mathics.core.symbols import (
    Symbol as Mathics3Symbol,
)
from mathics.core.symbols import (
    SymbolDivide,
    SymbolPlus,
    SymbolPower,
    SymbolTimes,
)
from mathics.core.systemsymbols import (
    SymbolEqual,
    SymbolFunction,
    SymbolGreater,
    SymbolGreaterEqual,
    SymbolLess,
    SymbolLessEqual,
    SymbolQuotient,
    SymbolUnequal,
)

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

SAGE_RELATION_TO_MATHICS3_SYMBOL = {
    eq: SymbolEqual,
    ne: SymbolUnequal,
    gt: SymbolGreater,
    lt: SymbolLess,
    ge: SymbolGreaterEqual,
    le: SymbolLessEqual,
}


class Mathics3Converter(Converter):
    """
    Convert Sage expressions to Mathics3

    EXAMPLES::

        sage: eqn = mathics3('3x + 5 == 14')
        sage: eqn
        5 + 3 x == 14
        sage: eqn.sage()
        3*x + 5 == 14
        sage: f = mathics3('E^x!')
        sage: f
        E ^ x!
        sage: f.sage()
        e^factorial(x)

    TESTS:

    Make sure we can convert I::

        sage: bool(I._mathics3_() == I)
        True
        sage: (x+I)._mathics3_()
        I + x
    """

    def __init__(self):
        """
        TESTS::

            sage: from sage.symbolic.expression_conversions import Mathics3Converter
            sage: m3 = Mathics3Converter()  # indirect doctest
            sage: TestSuite(m3).run(skip='_test_pickling')
        """
        self.mathics3 = Mathics3()

    def __call__(self, ex=None):
        #     EXAMPLES::
        # sage: from sage.symbolic.expression_conversions import Mathics3Converter
        # sage: m3 = Mathics3Converter()  # indirect doctest
        # sage: f(x, y) = x^2 + y^2; f
        # (x, y) |--> x^2 + y^2
        # sage: m3(f)
        # Function[{x, y}, x^ + y^2]
        """
        """
        if isinstance(ex, Expression):
            if ex.is_callable():
                # FIXME should get the function name. And then run in Mathics3
                # f[x, y] := f(x, y) = x^2 + y^2
                arguments = self.tuple(ex)
                operator = self.convert_object_to_mathics3(ex.operator())
                return Mathics3Expression(SymbolFunction, arguments, operator)
            elif ex.is_numeric() and ex.is_rational_expression():
                return self.convert_object_to_mathics3(ex)
            elif ex.is_constant():
                # Note: testing for constant should be done after testing for a numeric rational.
                return SAGE_CONSTANT_TO_MATHICS3.get(ex, ex)
            elif (operands := ex.operands()
                and (sympy_func := ex._sympy_())
            ):
                # FIXME: Figure out how to get function body.
                # When this is corrected, it may be similar to
                # composition. So use that when possible after correction.
                if not sympy_to_mathics:
                    from mathics.core.load_builtin import import_and_load_builtins

                    import_and_load_builtins()

                sympy_name = sympy_func.__class__.__name__
                if not sympy_name:
                    raise NotImplementedError
                mathics3_class = sympy_to_mathics.get(sympy_name)
                if not mathics3_class:
                    raise NotImplementedError
                mathics3_name = mathics3_class.__class__.__name__
                elements = [self.convert_object_to_mathics3(arg) for arg in operands]
                return Mathics3Expression(Mathics3Symbol(mathics3_name), *elements)

        if (value := self.convert_object_to_mathics3(ex)) is not None:
            return value
        raise NotImplementedError

    def pyobject(self, ex, obj):
        """
        EXAMPLES::

            sage: from sage.symbolic.expression_conversions import Mathics3Converter
            sage: m3 = Mathics3Converter()
            sage: x = SR(2)
            sage: m3.pyobject(x, x.pyobject())
            <Integer: 2>
            sage: type(_)
            <class 'mathics.core.atoms.numerics.Integer'>
            sage: x = SR(2.0)
            sage: m3.pyobject(x, x.pyobject())
            <MachineReal: 2.0>
            sage: type(_)
            <class 'mathics.core.atoms.numerics.MachineReal'>
            sage: x = SR(2/3)
            sage: x = SR(2 + 3j)
            sage: m3.pyobject(x, x.pyobject())
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
            sage: m3 = Mathics3Converter()
            sage: f = x + 2
            sage: m3.arithmetic(f, f.operator())
            <Expression: <Symbol: System`Plus>[<Integer: 2>, <Symbol: System`x>]>
        """
        operator = arithmetic_operators[operator]
        elements = [self.convert_object_to_mathics3(arg) for arg in ex.operands()]
        match operator:
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
            case "//":
                mathics3_expr = Mathics3Expression(SymbolQuotient, *elements)
            case "^":
                mathics3_expr = Mathics3Expression(SymbolPower, *elements)
            case _:
                raise NotImplementedError
        value = self.evaluate(mathics3_expr)
        return value

    def composition(self, ex, operator):
        """
        EXAMPLES::

            sage: from sage.symbolic.expression_conversions import Mathics3Converter
            sage: m3 = Mathics3Converter()  # indirect doctest
            sage: f = sin(2)
            sage: m3.composition(f, f.operator())
            <Expression: <Symbol: System`Sin>[<Integer: 2>]>
            sage: type(_)
            <class 'mathics.core.expression.Expression'>
            sage: f = arcsin(2)
            sage: m3.composition(f, f.operator())
            <Expression: <Symbol: System`ArcSin>[<Integer: 2>]>
        """
        if not (sympy_func := ex._sympy_()):
            raise NotImplementedError
        if not sympy_to_mathics:
            from mathics.core.load_builtin import import_and_load_builtins

            import_and_load_builtins()

        elements = []
        for arg in ex.operands():
            if arg.is_numeric():
                element = self.convert_object_to_mathics3(arg)
            elif isinstance(arg, Expression):
                element = arg._mathics3_()
            else:
                element = self.convert_object_to_mathics3(arg)
            elements.append(element)

        # if operator == exp:
        #     (arg,) = ex.operands()
        #     return self(arg).__rpow__(self.parent()('E'))  # or E^self(arg)

        # Convert via SymPy. However in the future, we can contemplate
        # Having Sage to Mathics3 correspondences listed, or for those
        # that do not have Sage to SymPy correspondences.
        sympy_name = sympy_func.__class__.__name__
        if not sympy_name:
            raise NotImplementedError
        mathics3_class = sympy_to_mathics.get(sympy_name)
        if not mathics3_class:
            raise NotImplementedError
        mathics3_name = mathics3_class.__class__.__name__

        return Mathics3Expression(Mathics3Symbol(mathics3_name), *elements)

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
        elif hasattr(obj, "is_symbol") and obj.is_symbol():
            return self.symbol(obj)

    # FIXME: for later.
    # def derivative(self, ex, operator):
    #     """
    #     Convert the derivative of ``self`` in sympy.

    #     INPUT:

    #     - ``ex`` -- a symbolic expression

    #     - ``operator`` -- operator

    #     TESTS::

    #         sage: var('x','y','z')
    #         (x, y, z)
    #         sage: f = function("F")
    #         f = function("F"))
    #         sage: f(x)._mathics3_()
    #         F[x]
    #         sage: diff(f(x,y,z), x, z, x)._mathics3_()
    #         diff(f_sage(x, y), x, x, y)
    #         sage: df_mathics3 = df_sage._mathics3_(); df_mathics3
    #         Derivative(f_sage(x, y), (x, 2), y)
    #         sage: df_sympy == f_sympy.diff(x, 2, y, 1)
    #         True

    #     Check that :issue:`28964` is fixed::

    #         sage: f = function('f')
    #         sage: _ = var('x,t')
    #         sage: diff(f(x, t), x)._sympy_(), diff(f(x, t), t)._sympy_()
    #         (Derivative(f(x, t), x), Derivative(f(x, t), t))

    #     Check differentiating by variables with multiple occurrences
    #     (:issue:`28964`)::

    #         sage: f = function('f')
    #         sage: _ = var('x1,x2,x3,x,t')
    #         sage: f(x, x, t).diff(x)._sympy_()._sage_()
    #         D[0](f)(x, x, t) + D[1](f)(x, x, t)

    #         sage: g = f(x1, x2, x3, t).diff(x1, 2, x2).subs(x1==x, x2==x, x3==x); g
    #         D[0, 0, 1](f)(x, x, x, t)
    #         sage: g._sympy_()
    #         Subs(Derivative(f(_xi_1, _xi_2, x, t), (_xi_1, 2), _xi_2),
    #              (_xi_1, _xi_2), (x, x))
    #         sage: assert g._sympy_()._sage_() == g

    #     Check that the use of dummy variables does not cause a collision::

    #         sage: f = function('f')
    #         sage: _ = var('x1,x2,x,xi_1')
    #         sage: g = f(x1, x2, xi_1).diff(x1).subs(x1==x, x2==x); g
    #         D[0](f)(x, x, xi_1)
    #         sage: assert g._sympy_()._sage_() == g
    #     """
    #     import sympy

    #     # retrieve derivated function
    #     f = operator.function()

    #     # retrieve order
    #     order = operator._parameter_set
    #     # arguments
    #     _args = [a._mathics3_() for a in ex.operands()]

    #     # when differentiating by a variable that occurs multiple times,
    #     # substitute it by a dummy variable
    #     subs_new = []
    #     subs_old = []
    #     sympy_arg = []
    #     for idx in order:
    #         a = _args[idx]
    #         if _args.count(a) > 1:
    #             D = sympy.Dummy("xi_%i" % (idx + 1))
    #             # to avoid collisions with ordinary symbols when converting
    #             # back to Sage, we pick an unused variable name for the dummy
    #             while D._sage_() in ex.variables():
    #                 D = sympy.Dummy(D.name + "_0")
    #             subs_old.append(a)
    #             subs_new.append(D)
    #             _args[idx] = D
    #             sympy_arg.append(D)
    #         else:
    #             sympy_arg.append(a)

    #     f_sympy = f._sympy_()(*_args)
    #     result = f_sympy.diff(*sympy_arg)
    #     if subs_new:
    #         return sympy.Subs(result, subs_new, subs_old)
    #     else:
    #         return result

    def evaluate(self, ex):
        if self.mathics3._session is None:
            self.mathics3._start()
        return ex.evaluate(self.mathics3._session.evaluation)

    def relation(self, ex, op):
        """
        EXAMPLES::

            sage: import operator
            sage: from sage.symbolic.expression_conversions import Mathics3Converter
            sage: m3 = Mathics3Converter()
            sage: m3.relation(x == 3, operator.eq)
            <Expression: <Symbol: System`Equal>[<Symbol: System`x>, <Integer: 3>]>
            sage: m3.relation(pi < 3, operator.lt)
            <Expression: <Symbol: System`Less>[<Symbol: System`Pi>, <Integer: 3>]>
            sage: m3.relation(x != pi, operator.ne)
            <Expression: <Symbol: System`Unequal>[<Symbol: System`x>, <Symbol: System`Pi>]>
            sage: m3.relation(x > 0, operator.gt)
            <Expression: <Symbol: System`Greater>[<Symbol: System`x>, <Integer: 0>]>
        """
        lhs = self(ex.lhs())
        rhs = self(ex.rhs())
        return Mathics3Expression(SAGE_RELATION_TO_MATHICS3_SYMBOL[op], lhs, rhs)

    def symbol(self, ex):
        """
        EXAMPLES::

            sage: from sage.symbolic.expression_conversions import Mathics3Converter
            sage: m3 = Mathics3Converter()  # indirect doctest
            sage: m3.symbol(x)
            <Symbol: System`x>
            sage: type(_)
            <class 'mathics.core.symbols.Symbol'>
        """
        # FIXME: we should figure out the context, e.g. System or Global.
        return Mathics3Symbol(repr(ex))

    # FIXME: This not getting called. I don't know why not though.
    def tuple(self, ex):
        """
        Conversion of tuples to Mathics3 ListExpressions.

        """
        # EXAMPLES::

        #     sage: t = SR._force_pyobject((3, 4, e^x))
        #     sage: t._mathics3_()
        #     {3, 4, E^x}
        #     sage: t = SR._force_pyobject((cos(x),))
        #     sage: t._mathics3_()
        #     {Cos[x]}
        return ListExpression(
            *[
                self.convert_object_to_mathics3(argument)
                for argument in ex.arguments()
             ]
            )


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
