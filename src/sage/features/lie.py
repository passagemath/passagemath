# sage_setup: distribution = sagemath-environment
r"""
Feature for testing the presence of LiE
"""

from . import Executable


class LiE(Executable):
    r"""
    A :class:`~sage.features.Feature` describing the presence of :ref:`LiE <spkg_lie>`.

    EXAMPLES::

        sage: from sage.features.lie import LiE
        sage: LiE()
        Feature('lie')
    """
    def __init__(self):
        r"""
        TESTS::

            sage: from sage.features.lie import LiE
            sage: isinstance(LiE(), LiE)
            True
        """
        Executable.__init__(self, 'lie', executable='lie',
                            spkg='lie', type='optional')


def all_features():
    return [LiE()]
