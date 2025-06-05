# sage_setup: distribution = sagemath-environment
r"""
Feature for testing the presence of ``giac``
"""

from . import Executable, FeatureTestResult, PythonModule
from .join_feature import JoinFeature


class Giac(Executable):
    r"""
    A :class:`~sage.features.Feature` describing the presence of :ref:`giac <spkg_giac>`.

    EXAMPLES::

        sage: from sage.features.giac import Giac
        sage: Giac().is_present()  # needs giac
        FeatureTestResult('giac_executable', True)
    """
    def __init__(self):
        r"""
        TESTS::

            sage: from sage.features.giac import Giac
            sage: isinstance(Giac(), Giac)
            True
        """
        Executable.__init__(self, 'giac_executable', executable='giac',
                            spkg='giac', type='optional')


def all_features():
    return [JoinFeature("giac",
                        (Giac(),
                         PythonModule('sage.interfaces.giac')),
                        spkg='sagemath_giac', type='optional')]
