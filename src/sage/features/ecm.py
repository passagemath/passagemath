# sage_setup: distribution = sagemath-environment
r"""
Feature for testing the presence of ``ecm`` or ``gmp-ecm``
"""
# ****************************************************************************
#       Copyright (C) 2024 Dima Pasechnik <dima@pasechnik.info>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 2 of the License, or
# (at your option) any later version.
#                  https://www.gnu.org/licenses/
# ****************************************************************************

from . import Executable, PythonModule
from .join_feature import JoinFeature
from sage.env import SAGE_ECMBIN


class Ecm(Executable):
    r"""
    A :class:`~sage.features.Feature` describing the presence of :ref:`GMP-ECM <spkg_ecm>`.

    EXAMPLES::

        sage: from sage.features.ecm import Ecm
        sage: Ecm().is_present()                                                        # needs ecm
        FeatureTestResult('ecm_executable', True)
    """
    def __init__(self):
        r"""
        TESTS::

            sage: from sage.features.ecm import Ecm
            sage: isinstance(Ecm(), Ecm)
            True
        """
        Executable.__init__(self, name='ecm_executable', executable=SAGE_ECMBIN,
                            spkg='ecm', type='standard')


def all_features():
    return [JoinFeature("ecm",
                        (Ecm(),
                         PythonModule('sage.interfaces.ecm')),
                        spkg='sagemath_libecm', type='standard')]
