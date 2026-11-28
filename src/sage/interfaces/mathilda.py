# sage_setup: distribution = sagemath-mathilda
# delvewheel: patch
r"""
Interface to the Mathilda computer algebra system

Mathilda runs *inside* the Sage process: :mod:`sage.libs.mathilda` links its C
API (``mathilda_ffi.h``) directly, so this interface is closer to
:mod:`sage.interfaces.polymake` — which calls JuPyMake functions — than to
:class:`sage.interfaces.mathematica.Mathematica`, which drives an external
process through ``Expect``.  Nothing is started, nothing can time out, and the
kernel is a singleton per process, so definitions made through one handle are
visible through every other.

EXPECTATIONS:

- Expression syntax is Mathematica's: ``f[x]`` for application, ``{a, b}`` for
  lists, 1-based ``[[i]]`` for parts.
- Results come back as Mathilda's output text.  :meth:`MathildaElement._sage_` translates the simple forms (numbers, lists and
  arithmetic) back into Sage objects; it does not translate general symbols.

EXAMPLES::

    sage: from sage.interfaces.mathilda import mathilda
    sage: mathilda('FactorInteger[360]')
    {{2, 3}, {3, 2}, {5, 1}}
    sage: mathilda(1/3)
    1/3
    sage: x = var('x')
    sage: e = mathilda('Expand[(x - 1)^3]')
    sage: e
    -1 + 3 x - 3 x^2 + x^3
    sage: e.sage()
    x^3 - 3*x^2 + 3*x - 1
    sage: latex(e)
    -1+3\,x-3\,x^{2}+x^{3}

Elements are live handles on the kernel: each one names a kernel variable, so
arithmetic goes back through Mathilda.  Indexing and length are sent to the
kernel too (1-based, like Mathematica)::

    sage: L = mathilda('FactorInteger[100]')
    sage: L
    {{2, 2}, {5, 2}}
    sage: L[1]
    {2, 2}
    sage: L[1][1]
    2
    sage: len(L)
    2

Called functions are built as text and evaluated in the same kernel::

    sage: mathilda.Sin('Pi/6')
    1/2
    sage: mathilda.Expand('(x + 1)^2')
    1 + 2 x + x^2
    sage: mathilda.Factor('x^4 - 1')
    (-1 + x) (1 + x) (1 + x^2)

Argument groups are Mathilda lists, not parenthesised tuples — an argument is
bound to a fresh kernel variable before the call is made, so it has to be
something Mathilda can assign::

    sage: mathilda.Integrate('x^2', 'x')
    1/3 x^3
    sage: mathilda.Integrate('Exp[-x^2]', '{x, -Infinity, Infinity}')
    Sqrt[Pi]

Assignment and clearing go through the interface::

    sage: mathilda.set('u', '2*x + 1')
    sage: mathilda.get('u')
    '1 + 2 x'
    sage: mathilda.clear('u')
    sage: mathilda.get('u')
    'u'

The kernel is shared with :mod:`sage.libs.mathilda`, so both spellings address
the same state::

    sage: from sage.libs.mathilda import mathilda as kernel
    sage: kernel().eval('v = 11')
    '11'
    sage: mathilda('v + 1')
    12

Errors are reported the way the FFI reports them::

    sage: mathilda.eval('1+')
    Traceback (most recent call last):
    ...
    MathildaError: Parse error: 1+
"""

import os
import re

from sage.interfaces.interface import (Interface, InterfaceElement,
                                       InterfaceFunction,
                                       InterfaceFunctionElement)
from sage.interfaces.tab_completion import ExtraTabCompletion
from sage.misc.sage_eval import sage_eval

#: Names Mathilda prints as function applications that Sage spells differently.
_FUNCTION_NAMES = {
    'Sqrt': 'sqrt', 'Abs': 'abs', 'Exp': 'exp', 'Log': 'log',
    'Sin': 'sin', 'Cos': 'cos', 'Tan': 'tan', 'Cot': 'cot',
    'Sec': 'sec', 'Csc': 'csc',
    'ArcSin': 'asin', 'ArcCos': 'acos', 'ArcTan': 'atan',
    'Sinh': 'sinh', 'Cosh': 'cosh', 'Tanh': 'tanh',
    'ArcSinh': 'asinh', 'ArcCosh': 'acosh', 'ArcTanh': 'atanh',
    'Factorial': 'factorial', 'Binomial': 'binomial', 'Fibonacci': 'fibonacci',
    'GCD': 'gcd', 'LCM': 'lcm', 'Mod': 'mod',
}

#: Constants whose Sage spelling differs from Mathilda's.
_CONSTANTS = {'E': 'e', 'Pi': 'pi', 'I': 'I', 'Infinity': 'oo',
              'True': 'True', 'False': 'False'}

_NUMBER = re.compile(r'[0-9]+(?:\.[0-9]*)?(?:[eE][-+]?[0-9]+)?'
                     r'|\.[0-9]+(?:[eE][-+]?[0-9]+)?')


def _registered_function_names():
    r"""
    Return the functions registered for Mathilda through
    :func:`sage.symbolic.expression.register_symbol`, keyed by the name that
    :func:`_to_sage` emits for them.

    EXAMPLES::

        sage: from sage.interfaces.mathilda import _registered_function_names
        sage: isinstance(_registered_function_names(), dict)
        True

    Names registered with :func:`sage.symbolic.expression.register_symbol` show
    up under the lower-cased name that :func:`_to_sage` emits::

        sage: from sage.symbolic.expression import register_symbol
        sage: _ = register_symbol(lambda t: t + 1, dict(mathilda='SomeOtherName'))
        sage: _registered_function_names()['someothername'](2)
        3
    """
    try:
        from sage.symbolic.expression import symbol_table
    except ImportError:
        return {}
    return {name.lower(): function
            for (name, _arity), function in symbol_table.get('mathilda', {}).items()}


def _to_sage(expr):
    r"""
    Translate Mathilda output into Sage input, as far as the simple forms go.

    Handles the four differences that matter for machine-generated output:
    ``{...}`` becomes a list, ``f[...]`` becomes ``f(...)``, ``^`` becomes
    ``**``, and implicit multiplication is made explicit.  Function names are
    mapped through a short table and otherwise lower-cased (``Factor`` is not
    in the table, so it would become ``factor``).

    EXAMPLES::

        sage: from sage.interfaces.mathilda import _to_sage
        sage: _to_sage('{{2, 3}, {3, 2}}')
        '[[2, 3], [3, 2]]'
        sage: _to_sage('-1 + 3 x - 3 x^2 + x^3')
        '-1+3*x-3*x**2+x**3'
        sage: _to_sage('Sqrt[Pi]')
        'sqrt(pi)'
        sage: _to_sage('E^x')
        'e**x'
        sage: _to_sage('1e+80')
        '1e+80'

    Quoted strings are left alone::

        sage: _to_sage('"a b"')
        '"a b"'
    """
    out = []
    closers = []
    prev_atom = False
    i, n = 0, len(expr)
    while i < n:
        c = expr[i]
        if c.isspace():
            i += 1
            continue
        if c == '"':
            j = i + 1
            while j < n and expr[j] != '"':
                j += 2 if expr[j] == '\\' else 1
            j = min(j + 1, n)
            if prev_atom:
                out.append('*')
            out.append(expr[i:j])
            prev_atom = True
            i = j
            continue
        if c.isdigit() or (c == '.' and i + 1 < n and expr[i + 1].isdigit()):
            match = _NUMBER.match(expr, i)
            if prev_atom:
                out.append('*')
            out.append(match.group())
            prev_atom = True
            i = match.end()
            continue
        if c.isalpha() or c == '$':
            j = i
            while j < n and (expr[j].isalnum() or expr[j] == '$'):
                j += 1
            name = expr[i:j]
            if j < n and expr[j] == '[':
                if prev_atom:
                    out.append('*')
                out.append(_FUNCTION_NAMES.get(name, name.lower()))
                out.append('(')
                closers.append(')')
                prev_atom = False
                i = j + 1
                continue
            if prev_atom:
                out.append('*')
            out.append(_CONSTANTS.get(name, name))
            prev_atom = True
            i = j
            continue
        if c == '{':
            if prev_atom:
                out.append('*')
            out.append('[')
            closers.append(']')
            prev_atom = False
            i += 1
            continue
        if c in '([':
            if prev_atom:
                out.append('*')
            out.append('(')
            closers.append(')')
            prev_atom = False
            i += 1
            continue
        if c in ')]}':
            out.append(closers.pop() if closers else c)
            prev_atom = True
            i += 1
            continue
        if c == '^':
            out.append('**')
            prev_atom = False
            i += 1
            continue
        if c == ',':
            out.append(', ')
            prev_atom = False
            i += 1
            continue
        out.append(c)
        prev_atom = False
        i += 1
    return ''.join(out)


class Mathilda(ExtraTabCompletion, Interface):
    r"""
    Interface to the Mathilda computer algebra system.

    EXAMPLES::

        sage: from sage.interfaces.mathilda import mathilda
        sage: mathilda
        Mathilda
        sage: mathilda('Sin[0.5]')
        0.479426
    """

    def __init__(self, seed=None):
        r"""
        Initialize ``self``.

        TESTS::

            sage: from sage.interfaces.mathilda import Mathilda
            sage: Mathilda()
            Mathilda
        """
        Interface.__init__(self, "mathilda")
        self._seed = seed

    def __reduce__(self):
        r"""
        Return the data needed to pickle ``self``, which is nothing.

        TESTS::

            sage: from sage.interfaces.mathilda import mathilda
            sage: loads(dumps(mathilda)) is mathilda
            True
        """
        return reduce_load_Mathilda, ()

    def _kernel(self):
        r"""
        Return the FFI handle this interface talks to.

        EXAMPLES::

            sage: from sage.interfaces.mathilda import mathilda
            sage: mathilda._kernel().version()
            '0.6764'
        """
        from sage.libs.mathilda import mathilda as kernel
        return kernel()

    def version(self):
        r"""
        Return the version of the linked Mathilda kernel.

        EXAMPLES::

            sage: from sage.interfaces.mathilda import mathilda
            sage: mathilda.version().startswith('0.')
            True
        """
        return self._kernel().version()

    def _eval(self, code):
        r"""
        Evaluate ``code`` and return Mathilda's output text.

        EXAMPLES::

            sage: from sage.interfaces.mathilda import mathilda
            sage: mathilda._eval('2 + 3')
            '5'
        """
        return self._kernel().eval(str(code))

    def eval(self, code, strip=True, **kwds):
        r"""
        Evaluate ``code`` in the kernel and return the output as a string.

        INPUT:

        - ``code`` -- string; Mathilda input
        - ``strip`` -- boolean (default: ``True``); strip surrounding whitespace

        EXAMPLES::

            sage: from sage.interfaces.mathilda import mathilda
            sage: mathilda.eval('1/2 + 1/3')
            '5/6'
            sage: mathilda.eval('  Factor[x^2 - 1]  ')
            '(-1 + x) (1 + x)'
        """
        out = self._eval(code)
        return out.strip() if strip else out

    def is_complete(self, code):
        r"""
        Return whether ``code`` is a complete expression.

        This is the test an interactive front end needs to decide whether to
        offer continuation of a line.

        EXAMPLES::

            sage: from sage.interfaces.mathilda import mathilda
            sage: mathilda.is_complete('Sin[x')
            False
            sage: mathilda.is_complete('Sin[x]')
            True
        """
        return self._kernel().is_complete(str(code))

    def set(self, var, value):
        r"""
        Assign ``value`` to the Mathilda symbol ``var``.

        EXAMPLES::

            sage: from sage.interfaces.mathilda import mathilda
            sage: mathilda.set('w', '3*y - 1')
            sage: mathilda.get('w')
            '-1 + 3 y'
        """
        self._eval('%s = %s' % (var, value))

    def get(self, var):
        r"""
        Return the value of the Mathilda symbol ``var`` as a string.

        EXAMPLES::

            sage: from sage.interfaces.mathilda import mathilda
            sage: mathilda.set('w', '3*y - 1')
            sage: mathilda.get('w')
            '-1 + 3 y'
        """
        return self.eval(var)

    def clear(self, var):
        r"""
        Clear the symbol ``var`` and return its name to the pool.

        EXAMPLES::

            sage: from sage.interfaces.mathilda import mathilda
            sage: mathilda.set('t', '5')
            sage: mathilda.clear('t')
            sage: mathilda.get('t')
            't'
        """
        self._eval('Clear[%s]' % var)
        self._available_vars.append(var)

    def _object_class(self):
        r"""
        Return the class of the elements of this interface.

        EXAMPLES::

            sage: from sage.interfaces.mathilda import mathilda
            sage: mathilda._object_class()
            <class 'sage.interfaces.mathilda.MathildaElement'>
        """
        return MathildaElement

    def _function_class(self):
        r"""
        Return the class of the functions of this interface.

        EXAMPLES::

            sage: from sage.interfaces.mathilda import mathilda
            sage: mathilda._function_class()
            <class 'sage.interfaces.mathilda.MathildaFunction'>
        """
        return MathildaFunction

    def _function_element_class(self):
        r"""
        Return the class of the bound functions of an element.

        EXAMPLES::

            sage: from sage.interfaces.mathilda import mathilda
            sage: mathilda._function_element_class()
            <class 'sage.interfaces.mathilda.MathildaFunctionElement'>
        """
        return MathildaFunctionElement

    def _function_call_string(self, function, args, kwds):
        r"""
        Return the text of a function call.

        Mathilda uses brackets for application and commas to separate
        arguments, exactly as Mathematica does.

        EXAMPLES::

            sage: from sage.interfaces.mathilda import mathilda
            sage: mathilda._function_call_string('Sin', ['x'], [])
            'Sin[x]'
            sage: mathilda._function_call_string('Integrate', ['x^2', 'x'], [])
            'Integrate[x^2, x]'
        """
        return '%s[%s]' % (function, ', '.join(list(args) + list(kwds)))

    def _left_list_delim(self):
        r"""
        Return the opening delimiter for lists.

        EXAMPLES::

            sage: from sage.interfaces.mathilda import mathilda
            sage: mathilda._left_list_delim()
            '{'
        """
        return '{'

    def _right_list_delim(self):
        r"""
        Return the closing delimiter for lists.

        EXAMPLES::

            sage: from sage.interfaces.mathilda import mathilda
            sage: mathilda._right_list_delim()
            '}'
        """
        return '}'

    def _left_func_delim(self):
        r"""
        Return the opening delimiter for function application.

        EXAMPLES::

            sage: from sage.interfaces.mathilda import mathilda
            sage: mathilda._left_func_delim()
            '['
        """
        return '['

    def _right_func_delim(self):
        r"""
        Return the closing delimiter for function application.

        EXAMPLES::

            sage: from sage.interfaces.mathilda import mathilda
            sage: mathilda._right_func_delim()
            ']'
        """
        return ']'

    def _assign_symbol(self):
        r"""
        Return the assignment symbol.

        EXAMPLES::

            sage: from sage.interfaces.mathilda import mathilda
            sage: mathilda._assign_symbol()
            '='
        """
        return '='

    def _equality_symbol(self):
        r"""
        Return the equality symbol.

        EXAMPLES::

            sage: from sage.interfaces.mathilda import mathilda
            sage: mathilda._equality_symbol()
            '=='
        """
        return '=='

    def _true_symbol(self):
        r"""
        Return the symbol Mathilda prints for true.

        EXAMPLES::

            sage: from sage.interfaces.mathilda import mathilda
            sage: mathilda._true_symbol()
            'True'
        """
        return 'True'

    def _false_symbol(self):
        r"""
        Return the symbol Mathilda prints for false.

        EXAMPLES::

            sage: from sage.interfaces.mathilda import mathilda
            sage: mathilda._false_symbol()
            'False'
        """
        return 'False'

    def _exponent_symbol(self):
        r"""
        Return the symbol Mathilda uses for the exponent of a float.

        EXAMPLES::

            sage: from sage.interfaces.mathilda import mathilda
            sage: mathilda._exponent_symbol()
            '*^'
        """
        return '*^'

    def _tab_completion(self):
        r"""
        Return the names the kernel knows, for tab completion.

        EXAMPLES::

            sage: from sage.interfaces.mathilda import mathilda
            sage: 'Sin' in mathilda._tab_completion()
            True
            sage: 'Integrate' in dir(mathilda)
            True
        """
        return self._kernel().complete('')

    def help(self, topic, pager=True):
        r"""
        Return Mathilda's usage message for ``topic``.

        Mathilda emits a ``usage`` record for ``?name``; this returns that
        text, or a message saying the name is unknown.

        INPUT:

        - ``topic`` -- string; the name to ask about
        - ``pager`` -- boolean (default: ``True``); ignored, kept for
          compatibility with the other interfaces

        EXAMPLES::

            sage: from sage.interfaces.mathilda import mathilda
            sage: mathilda.help('Sin').startswith('Sin[z]')
            True
            sage: 'gives the sine of z' in mathilda.help('Sin')
            True
            sage: mathilda.help('NoSuchSymbolOfOurs')
            'No information available for symbol "NoSuchSymbolOfOurs".'
        """
        for record in self._kernel().call('?%s' % topic):
            if record.get('type') == 'usage':
                return record['payload']
        return 'No help available for %s' % topic

    def console(self):
        r"""
        Run the Mathilda command-line session.

        EXAMPLES::

            sage: from sage.interfaces.mathilda import mathilda
            sage: mathilda.console()        # not tested
        """
        mathilda_console()


class MathildaFunction(InterfaceFunction):
    r"""
    A Mathilda function, such as ``mathilda.Sin``.

    EXAMPLES::

        sage: from sage.interfaces.mathilda import mathilda
        sage: mathilda.Sin
        Sin
        sage: mathilda.Sin('Pi/2')
        1
    """

    def _instancedoc_(self):
        r"""
        Return the usage message Mathilda has for this function.

        EXAMPLES::

            sage: from sage.interfaces.mathilda import mathilda
            sage: mathilda.Sin._instancedoc_().startswith('Sin[z]')
            True
        """
        return self._parent.help(self._name)


class MathildaFunctionElement(InterfaceFunctionElement):
    r"""
    A function evaluated on a particular element, such as ``f.Derivative``.

    EXAMPLES::

        sage: from sage.interfaces.mathilda import mathilda
        sage: f = mathilda('x^3')
        sage: f.D('x')
        3 x^2
        sage: f.Integrate('x')
        1/4 x^4
    """
    pass


class MathildaElement(ExtraTabCompletion, InterfaceElement):
    r"""
    An element of the Mathilda interface.

    The element stores the input that produced it, and every operation is sent
    back to the kernel, so it stays consistent with later assignments.

    EXAMPLES::

        sage: from sage.interfaces.mathilda import mathilda
        sage: a = mathilda('2^100')
        sage: a
        1267650600228229401496703205376
        sage: a.sage()
        1267650600228229401496703205376
    """

    def _repr_(self):
        r"""
        Return Mathilda's output for this element.

        EXAMPLES::

            sage: from sage.interfaces.mathilda import mathilda
            sage: mathilda('D[Sin[x] Exp[x], x]')
            E^x Cos[x] + E^x Sin[x]
        """
        return self.parent().get(self._name)

    def _latex_(self):
        r"""
        Return the LaTeX form of this element, from the kernel.

        EXAMPLES::

            sage: from sage.interfaces.mathilda import mathilda
            sage: latex(mathilda('Integrate[x^2, x]'))
            \frac{1}{3}\,x^{3}
        """
        return self.parent()._kernel().latex(self._name)

    def __getitem__(self, i):
        r"""
        Return the ``i``-th part of this element, 1-based.

        EXAMPLES::

            sage: from sage.interfaces.mathilda import mathilda
            sage: L = mathilda('FactorInteger[100]')
            sage: L[1]
            {2, 2}
            sage: L[2]
            {5, 2}
        """
        return self.parent().new('%s[[%s]]' % (self._name, i))

    def __len__(self):
        r"""
        Return the number of elements Mathilda reports for this object.

        EXAMPLES::

            sage: from sage.interfaces.mathilda import mathilda
            sage: len(mathilda('{a, b, c}'))
            3
        """
        return int(self.parent().eval('Length[%s]' % self._name))

    def n(self, *args, **kwargs):
        r"""
        Return the numerical value of this element.

        EXAMPLES::

            sage: from sage.interfaces.mathilda import mathilda
            sage: mathilda('Sqrt[2]').n()
            1.41421
        """
        return self.parent()('N[%s]' % self._name)

    def _tab_completion(self):
        r"""
        Return an empty list: an element has no completable members.

        EXAMPLES::

            sage: from sage.interfaces.mathilda import mathilda
            sage: mathilda('2')._tab_completion()
            []
        """
        return []

    def _sage_(self, locals={}):
        r"""
        Convert this element into a Sage object, as far as the simple forms go.

        Numbers, rationals, lists and arithmetic translate; a general symbol
        name or an untranslated function call raises a :exc:`TypeError` rather
        than returning something that only looks right.

        INPUT:

        - ``locals`` -- dictionary (default: ``{}``); symbols to bind while
          evaluating the translated expression

        EXAMPLES::

            sage: from sage.interfaces.mathilda import mathilda
            sage: mathilda('FactorInteger[360]').sage()
            [[2, 3], [3, 2], [5, 1]]
            sage: mathilda('1/2 + 1/3').sage()
            5/6
            sage: x = var('x')
            sage: mathilda('Expand[(x + 1)^2]').sage()
            x^2 + 2*x + 1

        Names registered with :func:`~sage.symbolic.expression.register_symbol`
        are recognised::

            sage: from sage.symbolic.expression import register_symbol
            sage: foo = lambda t: t^2 + 1
            sage: _ = register_symbol(foo, dict(mathilda='Foo'))
            sage: mathilda('Foo[x]').sage()
            x^2 + 1

        Without a binding, a free symbol cannot be converted::

            sage: mathilda('z^2 + 1').sage()
            Traceback (most recent call last):
            ...
            TypeError: cannot convert Mathilda output '1 + z^2' to a Sage object ...
        """
        text = str(self)
        bound = _registered_function_names()
        bound.update(locals)
        try:
            return sage_eval(_to_sage(text), locals=bound)
        except Exception as error:
            raise TypeError('cannot convert Mathilda output %r to a Sage '
                            'object (%s); pass locals=... to bind symbols'
                            % (text, error))


def reduce_load_Mathilda():
    r"""
    Return the Mathilda interface, for unpickling.

    EXAMPLES::

        sage: from sage.interfaces.mathilda import reduce_load_Mathilda
        sage: reduce_load_Mathilda()
        Mathilda
    """
    return mathilda


def mathilda_console():
    r"""
    Run the Mathilda command-line session.

    The interpreter is looked up as ``$SAGE_MATHILDA_CONSOLE``, falling back to
    ``Mathilda`` on the ``PATH``.

    EXAMPLES::

        sage: from sage.interfaces.mathilda import mathilda_console
        sage: mathilda_console()        # not tested
    """
    from shutil import which
    executable = os.environ.get('SAGE_MATHILDA_CONSOLE') or which('Mathilda')
    if not executable:
        raise RuntimeError('no Mathilda executable found; a distribution '
                           'prefix has one in bin/Mathilda, or set '
                           '$SAGE_MATHILDA_CONSOLE')
    os.execv(executable, [executable])


mathilda = Mathilda()
