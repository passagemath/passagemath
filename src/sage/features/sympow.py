# sage_setup: distribution = sagemath-environment
r"""
Feature for testing the presence of ``sympow``
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


class Sympow(Executable):
    r"""
    A :class:`~sage.features.Feature` describing the presence of the ``sympow``
    binary.

    EXAMPLES::

        sage: from sage.features.sympow import Sympow
        sage: Sympow().is_present()                                # needs sympow
        FeatureTestResult('sympow', True)
    """
    def __init__(self):
        r"""
        TESTS::

            sage: from sage.features.sympow import Sympow
            sage: isinstance(Sympow(), Sympow)
            True
        """
        Executable.__init__(self, "sympow", executable='sympow', spkg='sympow')


def all_features():
    return [Sympow()]
