# sage_setup: distribution = sagemath-environment
r"""
Feature for testing the presence of PARI/GP.
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

from . import Executable


class Gp(Executable):
    r"""
    A :class:`~sage.features.Feature` describing the presence of the ``gp``
    executable.

    EXAMPLES::

        sage: from sage.features.pari import Gp
        sage: Gp().is_present()                                # needs sage.libs.pari
        FeatureTestResult('gp_executable', True)
    """
    def __init__(self):
        r"""
        TESTS::

            sage: from sage.features.pari import Gp
            sage: isinstance(Gp(), Gp)
            True
        """
        Executable.__init__(self, "gp_executable", executable='gp',
                            spkg='pari', type='standard')
