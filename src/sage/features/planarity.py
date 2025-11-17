# sage_setup: distribution = sagemath-environment
r"""
Features for testing the presence of ``planarity``
"""

# *****************************************************************************
#       Copyright (C) 2025 Matthias Koeppe
#
#  Distributed under the terms of the GNU General Public License (GPL)
#  as published by the Free Software Foundation; either version 2 of
#  the License, or (at your option) any later version.
#                  https://www.gnu.org/licenses/
# *****************************************************************************

from . import PythonModule
from .join_feature import JoinFeature


class Planarity(JoinFeature):
    r"""
    A :class:`~sage.features.Feature` describing the presence of the :mod:`~sage.graphs.planarity` module,
    which is the SageMath interface to the :ref:`planarity <spkg_planarity>` library

    EXAMPLES::

        sage: from sage.features.planarity import Planarity
        sage: Planarity().is_present()  # optional - planarity
        FeatureTestResult('planarity', True)
    """

    def __init__(self):
        """
        TESTS::

            sage: from sage.features.planarity import Planarity
            sage: isinstance(Planarity(), Planarity)
            True
        """
        JoinFeature.__init__(self, 'planarity',
                             [PythonModule('sage.graphs.planarity',
                                           spkg='sagemath_planarity',
                                           type='standard')])


def all_features():
    return [Planarity()]
