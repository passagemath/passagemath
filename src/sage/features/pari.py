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

from . import Executable, Feature, FeatureTestResult


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


class PariFeature(Feature):
    r"""
    A :class:`~sage.features.Feature` describing the presence of a PARI/GP functionality.

    EXAMPLES::

        sage: from sage.features.pari import PariFeature
        sage: F = PariFeature('pari_seadata', 'ellmodulareqn(211)')
        sage: F.is_present()                                   # optional - pari_seadata
        FeatureTestResult('pari_seadata', True)
    """
    def __init__(self, name, command, **kwds):
        Feature.__init__(self, name,
                         spkg=f"pypi/passagemath-{name.replace('_', '-')}",
                         **kwds)
        self.command = command

    def _is_present(self):
        try:
            from sage.libs.pari import pari
        except ImportError as exception:
            return FeatureTestResult(self, False,
                                     reason=f"Interface sage.libs.pari cannot be imported: {exception}")
        try:
            pari(self.command)
        except Exception as exception:
            return FeatureTestResult(self, False,
                                     reason=f"PARI command '{self.command}' failed: {exception}")
        return FeatureTestResult(self, True)


def all_features():
    # Tests according to https://pari.math.u-bordeaux.fr/packages.html
    # and https://pari.math.u-bordeaux.fr/archives/pari-users-2508/msg00041.html
    return [
        PariFeature('pari_elldata', 'ellinit("11a1")'),
        PariFeature('pari_galpol', 'galoisgetname(12,1)'),
        PariFeature('pari_seadata', 'ellmodulareqn(211)'),
        PariFeature('pari_seadata_big', 'ellmodulareqn(521)'),
        PariFeature('pari_seadata_small', 'ellmodulareqn(11)', type='standard'),
        PariFeature('pari_galdata', 'polgalois(x^8-2)', type='standard'),
        PariFeature('pari_nflistdata', 'nflist("A5")'),
        PariFeature('pari_nftables', 'readvec(Str(default(datadir), "/nftables/T77.gp"))'),
    ]
