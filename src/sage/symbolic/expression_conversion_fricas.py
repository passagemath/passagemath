# sage_setup: distribution = sagemath-fricas
r"""
Conversion of symbolic expressions to FriCAS
"""
# ****************************************************************************
#       Copyright (C) 2018-2021 Martin Rubey
#                     2021      Marius Gerbershagen
#                     2024      Dima Pasechnik
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 2 of the License, or
# (at your option) any later version.
#                  https://www.gnu.org/licenses/
# ****************************************************************************

from sage.rings.number_field.number_field_element_base import NumberFieldElement_base
from sage.structure.element import Expression
from sage.symbolic.expression_conversions import InterfaceInit
from sage.symbolic.ring import SR


class FriCASConverter(InterfaceInit):
    """
    Convert any expression to FriCAS.

    EXAMPLES::

        sage: var('x,y')
        (x, y)
        sage: f = exp(x^2) - arcsin(pi+x)/y
        sage: f._fricas_()                                                      # optional - fricas
             2
            x
        y %e   - asin(x + %pi)
        ----------------------
                   y
    """
    def __init__(self):
        import sage.interfaces.fricas
        super().__init__(sage.interfaces.fricas.fricas)

    def pyobject(self, ex, obj):
        r"""
        Return a string which, when evaluated by FriCAS, returns the
        object as an expression.

        We explicitly add the coercion to the FriCAS domains
        `Expression Integer` and `Expression Complex Integer` to make
        sure that elements of the symbolic ring are translated to
        these.  In particular, this is needed for integration, see
        :issue:`28641` and :issue:`28647`.

        EXAMPLES::

            sage: 2._fricas_().domainOf()                                       # optional - fricas
            PositiveInteger...

            sage: (-1/2)._fricas_().domainOf()                                  # optional - fricas
            Fraction(Integer...)

            sage: SR(2)._fricas_().domainOf()                                   # optional - fricas
            Expression(Integer...)

            sage: (sqrt(2))._fricas_().domainOf()                               # optional - fricas
            Expression(Integer...)

            sage: pi._fricas_().domainOf()                                      # optional - fricas
            Pi...

            sage: asin(pi)._fricas_()                                           # optional - fricas
            asin(%pi)

            sage: I._fricas_().domainOf()                                   # optional - fricas
            Complex(Integer...)

            sage: SR(I)._fricas_().domainOf()                                   # optional - fricas
            Expression(Complex(Integer...))

            sage: ex = (I+sqrt(2)+2)
            sage: ex._fricas_().domainOf()                                      # optional - fricas
            Expression(Complex(Integer...))

            sage: ex._fricas_()^2                                               # optional - fricas
                       +-+
            (4 + 2 %i)\|2  + 5 + 4 %i

            sage: (ex^2)._fricas_()                                             # optional - fricas
                       +-+
            (4 + 2 %i)\|2  + 5 + 4 %i

        Check that :issue:`40101` is fixed::

            sage: SR(-oo)._fricas_().domainOf()                                 # optional - fricas
            OrderedCompletion(Integer)
        """
        try:
            result = getattr(obj, self.name_init)()
        except AttributeError:
            result = repr(obj)
        else:
            if isinstance(obj, NumberFieldElement_base):
                from sage.rings.number_field.number_field_element_quadratic import NumberFieldElement_gaussian
                if isinstance(obj, NumberFieldElement_gaussian):
                    return "((%s)::EXPR COMPLEX INT)" % result
            elif isinstance(obj, InfinityElement):
                # in this case, we leave the decision about the domain best to FriCAS
                return result
        return "((%s)::EXPR INT)" % result

    def symbol(self, ex):
        """
        Convert the argument, which is a symbol, to FriCAS.

        In this case, we do not return an `Expression Integer`,
        because FriCAS frequently requires elements of domain
        `Symbol` or `Variable` as arguments, for example to
        `integrate`.  Moreover, FriCAS is able to do the conversion
        itself, whenever the argument should be interpreted as a
        symbolic expression.

        EXAMPLES::

            sage: x._fricas_().domainOf()                                       # optional - fricas
            Variable(x)

            sage: (x^2)._fricas_().domainOf()                                   # optional - fricas
            Expression(Integer...)

            sage: (2*x)._fricas_().integrate(x)                                 # optional - fricas
             2
            x
        """
        return repr(ex)

    def derivative(self, ex, operator):
        """
        Convert the derivative of ``self`` in FriCAS.

        INPUT:

        - ``ex`` -- a symbolic expression

        - ``operator`` -- operator

        Note that ``ex.operator() == operator``.

        EXAMPLES::

            sage: var('x,y,z')
            (x, y, z)
            sage: f = function("F")
            sage: f(x)._fricas_()                                               # optional - fricas
            F(x)
            sage: diff(f(x,y,z), x, z, x)._fricas_()                            # optional - fricas
            F      (x,y,z)
             ,1,1,3

        Check that :issue:`25838` is fixed::

            sage: var('x')
            x
            sage: F = function('F')
            sage: integrate(F(x), x, algorithm='fricas')                        # optional - fricas
            integral(F(x), x)

            sage: integrate(diff(F(x), x)*sin(F(x)), x, algorithm='fricas')     # optional - fricas
            -cos(F(x))

        Check that :issue:`27310` is fixed::

            sage: f = function("F")
            sage: var("y")
            y
            sage: ex = (diff(f(x,y), x, x, y)).subs(y=x+y); ex
            D[0, 0, 1](F)(x, x + y)
            sage: fricas(ex)                                                    # optional - fricas
            F      (x,y + x)
             ,1,1,2
        """
        args = ex.operands()  # the arguments the derivative is evaluated at
        params = operator.parameter_set()
        params_set = set(params)
        mult = ",".join(str(params.count(i)) for i in params_set)
        if (not all(isinstance(v, Expression) and v.is_symbol() for v in args) or
                len(args) != len(set(args))):
            # An evaluated derivative of the form f'(1) is not a
            # symbolic variable, yet we would like to treat it like
            # one. So, we replace the argument `1` with a temporary
            # variable e.g. `_symbol0` and then evaluate the
            # derivative f'(_symbol0) symbolically at _symbol0=1. See
            # trac #12796. Note that we cannot use SR.temp_var here
            # since two conversions of the same expression have to be
            # equal.
            temp_args = [SR.symbol("_symbol%s" % i) for i in range(len(args))]
            f = operator.function()(*temp_args)
            vars = ",".join(temp_args[i]._fricas_init_() for i in params_set)
            subs = ",".join("%s = %s" % (t._fricas_init_(), a._fricas_init_())
                            for t, a in zip(temp_args, args))
            outstr = "eval(D(%s, [%s], [%s]), [%s])" % (f._fricas_init_(), vars, mult, subs)
        else:
            f = operator.function()(*args)
            vars = ",".join(args[i]._fricas_init_() for i in params_set)
            outstr = "D(%s, [%s], [%s])" % (f._fricas_init_(), vars, mult)

        return outstr


fricas_converter = FriCASConverter()
