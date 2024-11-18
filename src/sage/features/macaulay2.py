# sage_setup: distribution = sagemath-environment
r"""
Feature for testing the presence of MACAULAY2
"""

# *****************************************************************************
#       Copyright (C) 2024 Matthias Koeppe
#
#  Distributed under the terms of the GNU General Public License (GPL)
#  as published by the Free Software Foundation; either version 2 of
#  the License, or (at your option) any later version.
#                  https://www.gnu.org/licenses/
# *****************************************************************************

import subprocess
from . import Executable, PythonModule
from . import FeatureTestResult
from .join_feature import JoinFeature

class Macaulay2(Executable):
    r"""
    A :class:`~sage.features.Feature` describing the presence of :ref:`macaulay2 <spkg_macaulay2>`.

    EXAMPLES::

        sage: from sage.features.macaulay2 import Macaulay2
        sage: Macaulay2().is_present()  # optional - macaulay2
        FeatureTestResult('macaulay2_executable', True)
    """
    def __init__(self):
        r"""
        TESTS::

            sage: from sage.features.macaulay2 import Macaulay2
            sage: isinstance(Macaulay2(), Macaulay2)
            True
        """
        Executable.__init__(self, "macaulay2_executable", executable='M2',
                            spkg='macaulay2')


def all_features():
    return [JoinFeature("macaulay2",
                        (Macaulay2(),
                         PythonModule('sage.interfaces.macaulay2')),
                        spkg='sagemath_macaulay2')]
