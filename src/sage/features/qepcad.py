# sage_setup: distribution = sagemath-environment
r"""
Feature for testing the presence of QEPCAD
"""

# *****************************************************************************
#       Copyright (C) 2022 Marc Mezzarobba
#
#  Distributed under the terms of the GNU General Public License (GPL)
#  as published by the Free Software Foundation; either version 2 of
#  the License, or (at your option) any later version.
#                  https://www.gnu.org/licenses/
# *****************************************************************************

import subprocess
from . import Executable
from . import FeatureTestResult

class Qepcad(Executable):
    r"""
    A :class:`~sage.features.Feature` describing the presence of :ref:`qepcad <spkg_qepcad>`.

    EXAMPLES::

        sage: from sage.features.qepcad import Qepcad
        sage: Qepcad().is_present()  # optional - qepcad
        FeatureTestResult('qepcad', True)
    """
    def __init__(self):
        r"""
        TESTS::

            sage: from sage.features.qepcad import Qepcad
            sage: isinstance(Qepcad(), Qepcad)
            True
        """
        Executable.__init__(self, "qepcad", executable='qepcad',
                            spkg='qepcad')


def all_features():
    return [Qepcad()]
