"""
This file gathers together all the tables in Sage.

    * ConwayPolynomials() -- database of selected Conway polynomials.

    * CremonaDatabase() - Cremona's tables of elliptic curves and related data.

    * findstat -- The FindStat database (https://www.findstat.org/).

    * JonesDatabase() -- returns the John Jones table of number fields
      with bounded ramification and degree <= 6.

    * oeis -- The On-Line Encyclopedia of Integer Sequences (https://oeis.org/).

    * SloaneEncyclopedia -- Local copy of Sloane On-Line Encyclopedia of
      Integer Sequences.

    * SteinWatkinsAllData() and SteinWatkinsPrimeData() - The
      Stein-Watkins tables of elliptic curves and related data.

    * SymbolicData() -- many benchmark and testing ideals

EXAMPLES::

    sage: ConwayPolynomials()
    Frank Lübeck's database of Conway polynomials

    sage: CremonaDatabase()
    Cremona's database of elliptic curves with conductor...

    sage: JonesDatabase()                                       # optional - database_jones_numfield
    John Jones's table of number fields with bounded ramification and degree <= 6

    sage: oeis
    The On-Line Encyclopedia of Integer Sequences (https://oeis.org/)

    sage: SymbolicData()                                        # optional - database_symbolic_data
    SymbolicData with ... ideals
"""

# ****************************************************************************
#       Copyright (C) 2005 William Stein <wstein@gmail.com>
#
#  Distributed under the terms of the GNU General Public License (GPL)
#  as published by the Free Software Foundation; either version 2 of
#  the License, or (at your option) any later version.
#                  https://www.gnu.org/licenses/
# ****************************************************************************

from sage.databases.all__sagemath_combinat import *
from sage.databases.all__sagemath_graphs import *
from sage.databases.all__sagemath_pari import *
from sage.databases.all__sagemath_schemes import *

try:
    from sage.databases.all__sagemath_database_cunningham import *
except ImportError:
    pass

try:
    from sage.databases.all__sagemath_database_kohel import *
except ImportError:
    pass

try:
    from sage.databases.all__sagemath_database_jones_numfield import *
except ImportError:
    pass

try:
    from sage.databases.all__sagemath_database_odlyzko_zeta import *
except ImportError:
    pass

try:
    from sage.databases.all__sagemath_database_symbolic_data import *
except ImportError:
    pass
