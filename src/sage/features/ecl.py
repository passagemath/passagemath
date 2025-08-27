# sage_setup: distribution = sagemath-environment
r"""
Feature for testing the presence of ECL
"""

# *****************************************************************************
#       Copyright (C) 2025 Matthias Koeppe
#
#  Distributed under the terms of the GNU General Public License (GPL)
#  as published by the Free Software Foundation; either version 2 of
#  the License, or (at your option) any later version.
#                  https://www.gnu.org/licenses/
# *****************************************************************************

import subprocess
from . import Executable, FeatureTestResult, PythonModule
from .join_feature import JoinFeature


class Ecl(Executable):
    r"""
    A :class:`~sage.features.Feature` describing the presence of :ref:`ecl <spkg_ecl>`.

    EXAMPLES::

        sage: from sage.features.ecl import Ecl
        sage: Ecl().is_present()  # optional - ecl
        FeatureTestResult('ecl', True)
    """
    def __init__(self):
        r"""
        TESTS::

            sage: from sage.features.ecl import Ecl
            sage: isinstance(Ecl(), Ecl)
            True
        """
        Executable.__init__(self, "ecl", executable='ecl',
                            spkg='ecl', type='standard')


def all_features():
    return [JoinFeature("ecl",
                        (Ecl(),
                         PythonModule('sage.interfaces.lisp')),
                        spkg='sagemath_ecl', type='standard')]
