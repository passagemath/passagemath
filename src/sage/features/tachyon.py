# sage_setup: distribution = sagemath-environment
r"""
Feature for testing the presence of Tachyon
"""

# *****************************************************************************
#       Copyright (C) 2025 Matthias Koeppe
#
#  Distributed under the terms of the GNU General Public License (GPL)
#  as published by the Free Software Foundation; either version 2 of
#  the License, or (at your option) any later version.
#                  https://www.gnu.org/licenses/
# *****************************************************************************

from . import Executable, FeatureTestResult, PythonModule
from .join_feature import JoinFeature


class Tachyon(Executable):
    r"""
    A :class:`~sage.features.Feature` describing the presence of :ref:`tachyon <spkg_tachyon>`.

    EXAMPLES::

        sage: from sage.features.tachyon import Tachyon
        sage: Tachyon().is_present()  # optional - tachyon
        FeatureTestResult('tachyon_executable', True)
    """
    def __init__(self):
        r"""
        TESTS::

            sage: from sage.features.tachyon import Tachyon
            sage: isinstance(Tachyon(), Tachyon)
            True
        """
        Executable.__init__(self, "tachyon_executable", executable='tachyon',
                            spkg='tachyon', type='standard')


def all_features():
    return [JoinFeature("tachyon",
                        (Tachyon(),
                         PythonModule('sage.interfaces.tachyon')),
                        spkg='sagemath_tachyon',
                        type='standard')]
