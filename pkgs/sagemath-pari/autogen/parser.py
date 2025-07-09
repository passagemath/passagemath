"""
Read and parse the file pari.desc
"""

#*****************************************************************************
#       Copyright (C) 2015 Jeroen Demeyer <jdemeyer@cage.ugent.be>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 2 of the License, or
# (at your option) any later version.
#                  http://www.gnu.org/licenses/
#*****************************************************************************

import io
import os
import re

from .args import pari_arg_types
from .ret import pari_ret_types
from .paths import pari_share

paren_re = re.compile(r"[(](.*)[)]")
argname_re = re.compile(r"[ {]*&?([A-Za-z_][A-Za-z0-9_]*)")

def read_pari_desc():
    """
    Read and parse the file ``pari.desc``.

    The output is a dictionary where the keys are GP function names
    and the corresponding values are dictionaries containing the
    ``(key, value)`` pairs from ``pari.desc``.

    EXAMPLES::

        >>> from autogen.parser import read_pari_desc
        >>> D = read_pari_desc()
        >>> Dcos = D["cos"]
        >>> if "description" in Dcos: _ = Dcos.pop("description")
        >>> Dcos.pop("doc").startswith('cosine of $x$.')
        True
        >>> Dcos == { 'class': 'basic',
        ...   'cname': 'gcos',
        ...   'function': 'cos',
        ...   'help': 'cos(x): cosine of x.',
        ...   'prototype': 'Gp',
        ...   'section': 'transcendental'}
        True
    """
    pari_desc = os.path.join(pari_share(), 'pari.desc')
    with io.open(pari_desc, encoding="utf-8") as f:
        lines = f.readlines()

    n = 0
    N = len(lines)

    functions = {}
    while n < N:
        fun = {}
        while True:
            L = lines[n]
            n += 1
            if L == "\n":
                break
            # As long as the next lines start with a space, append them
            while lines[n].startswith(" "):
                L += (lines[n])[1:]
                n += 1
            key, value = L.split(":", 1)
            # Change key to an allowed identifier name
            key = key.lower().replace("-", "")
            fun[key] = value.strip()

        name = fun["function"]
        functions[name] = fun

    return functions

def parse_prototype(proto, help, initial_args=[]):
    """
    Parse arguments and return type of a PARI function.

    INPUT:

    - ``proto`` -- a PARI prototype like ``"GD0,L,DGDGDG"``

    - ``help`` -- a PARI help string like
      ``"qfbred(x,{flag=0},{d},{isd},{sd})"``

    - ``initial_args`` -- other arguments to this function which come
      before the PARI arguments, for example a ``self`` argument.

    OUTPUT: a tuple ``(args, ret)`` where

    - ``args`` is a list consisting of ``initial_args`` followed by
      :class:`PariArgument` instances with all arguments of this
      function.

    - ``ret`` is a :class:`PariReturn` instance with the return type of
      this function.

    EXAMPLES::

        >>> from autogen.parser import parse_prototype
        >>> proto = 'GD0,L,DGDGDG'
        >>> help = 'qfbred(x,{flag=0},{d},{isd},{sd})'
        >>> parse_prototype(proto, help)
        ([GEN x, long flag=0, GEN d=NULL, GEN isd=NULL, GEN sd=NULL], GEN)
        >>> proto = "GD&"
        >>> help = "sqrtint(x,{&r})"
        >>> parse_prototype(proto, help)
        ([GEN x, GEN* r=NULL], GEN)
        >>> parse_prototype("lp", "foo()", [str("TEST")])
        (['TEST', prec precision=DEFAULT_BITPREC], long)
    """
    # Use the help string just for the argument names.
    # "names" should be an iterator over the argument names.
    m = paren_re.search(help)
    if m is None:
        names = iter([])
    else:
        s = m.groups()[0]
        matches = [argname_re.match(x) for x in s.split(",")]
        names = (m.groups()[0] for m in matches if m is not None)

    # First, handle the return type
    try:
        c = proto[0]
        t = pari_ret_types[c]
        n = 1  # index in proto
    except (IndexError, KeyError):
        t = pari_ret_types[""]
        n = 0  # index in proto
    ret = t()

    # Go over the prototype characters and build up the arguments
    args = list(initial_args)
    have_default = False  # Have we seen any default argument?
    while n < len(proto):
        c = proto[n]
        n += 1

        # Parse default value
        if c == "D":
            default = ""
            if proto[n] not in pari_arg_types:
                while True:
                    c = proto[n]
                    n += 1
                    if c == ",":
                        break
                    default += c
            c = proto[n]
            n += 1
        else:
            default = None

        try:
            t = pari_arg_types[c]
            if t is None:
                raise NotImplementedError('unsupported prototype character %r' % c)
        except KeyError:
            if c == ",":
                continue  # Just skip additional commas
            else:
                raise ValueError('unknown prototype character %r' % c)

        arg = t(names, default, index=len(args))
        if arg.default is not None:
            have_default = True
        elif have_default:
            # We have a non-default argument following a default
            # argument, which means trouble...
            #
            # A syntactical wart of Python is that it does not allow
            # that: something like def foo(x=None, y) is a SyntaxError
            # (at least with Python-2.7.13, Python-3.6.1 and Cython-0.25.2)
            #
            # A small number of GP functions (nfroots() for example)
            # wants to do this anyway. Luckily, this seems to occur only
            # for arguments of type GEN (prototype code "G")
            #
            # To work around this, we add a "fake" default value and
            # then raise an error if it was not given...
            if c != "G":
                raise NotImplementedError("non-default argument after default argument is only implemented for GEN arguments")
            arg.default = False
        args.append(arg)

    return (args, ret)
