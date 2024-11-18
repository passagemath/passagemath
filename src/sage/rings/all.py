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

<<<<<<< HEAD
||||||| merged common ancestors
<<<<<<<<< Temporary merge branch 1
# Following will go to all__sagemath_categories.py in #36566
||||||||| ab24dac430e
# Finite residue fields
from sage.rings.finite_rings.residue_field import ResidueField

# p-adic field
from sage.rings.padics.all import *
from sage.rings.padics.padic_printing import _printer_defaults as padic_printing

# valuations
from sage.rings.valuation.all import *
=========
# Finite residue fields
from sage.rings.finite_rings.residue_field import ResidueField

# p-adic field
from sage.rings.padics.all import *
from sage.rings.padics.padic_printing import _printer_defaults as padic_printing

# Pseudo-ring of PARI objects.
from sage.rings.pari_ring import PariRing, Pari

# valuations
from sage.rings.valuation.all import *
>>>>>>>>> Temporary merge branch 2

# Semirings
from sage.rings.semirings.all import *

<<<<<<<<< Temporary merge branch 1
# Double precision floating point numbers
from sage.rings.real_double import RealDoubleField, RDF, RealDoubleElement
||||||||| ab24dac430e
# Real numbers
from sage.rings.real_mpfr import (RealField, RR,
                       create_RealNumber as RealNumber)   # this is used by the preparser to wrap real literals -- very important.
Reals = RealField

from sage.rings.real_double import RealDoubleField, RDF, RealDoubleElement
=========
# Real numbers
from sage.rings.real_mpfr import (RealField, RR,
                                  create_RealNumber as RealNumber)   # this is used by the preparser to wrap real literals -- very important.

# Lazy Laurent series ring
lazy_import('sage.rings.lazy_series_ring', ['LazyLaurentSeriesRing', 'LazyPowerSeriesRing',
                                            'LazySymmetricFunctions', 'LazyDirichletSeriesRing'])

# Tate algebras
from sage.rings.tate_algebra import TateAlgebra

Reals = RealField

# Number field
from sage.rings.number_field.all import *
>>>>>>>>> Temporary merge branch 2

<<<<<<<<< Temporary merge branch 1
# Lazy reals
from sage.rings.real_lazy import RealLazyField, RLF, ComplexLazyField, CLF
||||||||| ab24dac430e
from sage.rings.real_lazy import RealLazyField, RLF, ComplexLazyField, CLF
=========
>>>>>>>>> Temporary merge branch 2

# up to here (#36566)

=======
# Semirings
from sage.rings.semirings.all import *

# Double precision floating point numbers
from sage.rings.real_double import RealDoubleField, RDF, RealDoubleElement


# up to here (#36566)

>>>>>>> main
# Polynomial Rings and Polynomial Quotient Rings
from sage.rings.polynomial.all import *

<<<<<<< HEAD
||||||| merged common ancestors
# Following will go to all__sagemath_categories.py in #36566

<<<<<<<<< Temporary merge branch 1
# Power series rings
from sage.rings.power_series_ring import PowerSeriesRing

# Laurent series ring in one variable
from sage.rings.laurent_series_ring import LaurentSeriesRing

# Puiseux series ring
from sage.rings.puiseux_series_ring import PuiseuxSeriesRing

# Big-oh notation
from sage.rings.big_oh import O

# Fraction field
from sage.rings.fraction_field import FractionField
Frac = FractionField

# Localization
from sage.rings.localization import Localization

# up to here (#36566)

||||||||| ab24dac430e
# Power series rings
from sage.rings.power_series_ring import PowerSeriesRing

# Laurent series ring in one variable
from sage.rings.laurent_series_ring import LaurentSeriesRing

# Lazy Laurent series ring
lazy_import('sage.rings.lazy_series_ring', ['LazyLaurentSeriesRing', 'LazyPowerSeriesRing',
                                            'LazySymmetricFunctions', 'LazyDirichletSeriesRing'])

# Tate algebras
from sage.rings.tate_algebra import TateAlgebra

# Puiseux series ring
from sage.rings.puiseux_series_ring import PuiseuxSeriesRing

# Pseudo-ring of PARI objects.
from sage.rings.pari_ring import PariRing, Pari

# Big-oh notation
from sage.rings.big_oh import O

# Fraction field
from sage.rings.fraction_field import FractionField
Frac = FractionField

# Localization
from sage.rings.localization import Localization

=========
>>>>>>>>> Temporary merge branch 2
=======
# Following will go to all__sagemath_categories.py in #36566

>>>>>>> main
# c-finite sequences
from sage.rings.cfinite_sequence import CFiniteSequence, CFiniteSequences

from sage.rings.fast_arith import prime_range

# asymptotic ring
# from sage.rings.asymptotic.all import *
lazy_import('sage.rings.asymptotic.asymptotic_ring', 'AsymptoticRing')
lazy_import('sage.rings.asymptotic.asymptotic_expansion_generators',
            'asymptotic_expansions')

# Register classes in numbers abc
from sage.rings import numbers_abc
del lazy_import
