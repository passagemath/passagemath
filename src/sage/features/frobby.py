# sage_setup: distribution = sagemath-environment
r"""
Feature for testing the presence of FROBBY
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


class Frobby(Executable):
    r"""
    A :class:`~sage.features.Feature` describing the presence of :ref:`frobby <spkg_frobby>`.

    EXAMPLES::

        sage: from sage.features.frobby import Frobby
        sage: Frobby().is_present()  # optional - frobby
        FeatureTestResult('frobby_executable', True)
    """
    def __init__(self):
        r"""
        TESTS::

            sage: from sage.features.frobby import Frobby
            sage: isinstance(Frobby(), Frobby)
            True
        """
        Executable.__init__(self, "frobby_executable", executable='frobby',
                            spkg='frobby')


def all_features():
    return [JoinFeature("frobby",
                        (Frobby(),
                         PythonModule('sage.interfaces.frobby')),
                        spkg='sagemath_frobby')]
