# sage_setup: distribution = sagemath-environment
r"""
Feature for testing the presence of lcalc
"""

# *****************************************************************************
#       Copyright (C) 2026 Matthias Koeppe
#
#  Distributed under the terms of the GNU General Public License (GPL)
#  as published by the Free Software Foundation; either version 2 of
#  the License, or (at your option) any later version.
#                  https://www.gnu.org/licenses/
# *****************************************************************************

import subprocess
from . import Executable, FeatureTestResult, PythonModule
from .join_feature import JoinFeature


class lcalc(Executable):
    r"""
    A :class:`~sage.features.Feature` describing the presence of :ref:`lcalc <spkg_lcalc>`.

    EXAMPLES::

        sage: from sage.features.lcalc import lcalc
        sage: lcalc().is_present()                              # needs lcalc
        FeatureTestResult('lcalc', True)
    """
    def __init__(self):
        r"""
        TESTS::

            sage: from sage.features.lcalc import lcalc
            sage: isinstance(lcalc(), lcalc)
            True
        """
        Executable.__init__(self, "lcalc_executable", executable='lcalc')


def all_features():
    return [JoinFeature("lcalc",
                        (lcalc(),
                         PythonModule('sage.libs.lcalc')),
                        spkg='sagemath_lcalc')]
