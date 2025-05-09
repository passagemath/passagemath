# sage_setup: distribution = sagemath-environment
r"""
Features for testing the presence of ``gfan``
"""

# *****************************************************************************
#       Copyright (C) 2022 Matthias Koeppe
#
#  Distributed under the terms of the GNU General Public License (GPL)
#  as published by the Free Software Foundation; either version 2 of
#  the License, or (at your option) any later version.
#                  https://www.gnu.org/licenses/
# *****************************************************************************

from . import Executable, PythonModule
from .join_feature import JoinFeature


class GfanExecutable(Executable):
    r"""
    A :class:`~sage.features.Feature` for the :ref:`gfan <spkg_gfan>` executables.
    """
    def __init__(self, cmd=None):
        r"""
        TESTS::

            sage: from sage.features.gfan import GfanExecutable
            sage: isinstance(GfanExecutable('groebnercone'), GfanExecutable)
            True
        """
        if cmd is None:
            name = "gfan_executable"
            executable = "gfan"
        else:
            executable = name = f"gfan_{cmd}"
        Executable.__init__(self, name, executable=executable, spkg='gfan', type='optional')


def all_features():
    return [JoinFeature("gfan",
                        (GfanExecutable(),
                         PythonModule('sage.interfaces.gfan')),
                        spkg='sagemath_gfan', type='optional')]
