"""
Rings
"""
# ****************************************************************************
#       Copyright (C) 2005 William Stein <wstein@gmail.com>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 2 of the License, or
# (at your option) any later version.
#                  https://www.gnu.org/licenses/
# ****************************************************************************
from sage.misc.lazy_import import lazy_import

from sage.rings.all__sagemath_categories import *

# Finite fields
from sage.rings.finite_rings.all import *

from sage.rings.all__sagemath_combinat import *
from sage.rings.all__sagemath_flint import *
from sage.rings.all__sagemath_gap import *
from sage.rings.all__sagemath_modules import *

try:
    from sage.rings.all__sagemath_symbolics import *
except ImportError:
    pass

# Function field
from sage.rings.function_field.all import *

# Semirings
from sage.rings.semirings.all import *

# Double precision floating point numbers
from sage.rings.real_double import RealDoubleField, RDF, RealDoubleElement

# Polynomial Rings and Polynomial Quotient Rings
from sage.rings.polynomial.all import *

# Following will go to all__sagemath_categories.py in #36566

from sage.rings.fast_arith import prime_range

# Register classes in numbers abc
from sage.rings import numbers_abc
del lazy_import
