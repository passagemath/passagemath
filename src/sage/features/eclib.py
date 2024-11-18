# sage_setup: distribution = sagemath-environment
r"""
Feature for testing the presence of eclib
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
from . import Executable, FeatureTestResult, PythonModule
from .join_feature import JoinFeature


class Mwrank(Executable):
    r"""
    A :class:`~sage.features.Feature` describing the presence of mwrank.

    EXAMPLES::

        sage: from sage.features.eclib import Mwrank
        sage: Mwrank().is_present()                             # needs eclib
        FeatureTestResult('mwrank', True)
    """
    def __init__(self):
        r"""
        TESTS::

            sage: from sage.features.eclib import Mwrank
            sage: isinstance(Mwrank(), Mwrank)
            True
        """
        Executable.__init__(self, "mwrank", executable='mwrank',
                            spkg='eclib', type='standard')


def all_features():
    return [JoinFeature("eclib",
                        (Mwrank(),
                         PythonModule('sage.libs.eclib')),
                        spkg='sagemath_eclib', type='standard')]
