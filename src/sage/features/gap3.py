r"""
Feature for testing the presence of ``gap3``.
"""

from . import Executable


class Gap3(Executable):
    r"""
    A :class:`~sage.features.Feature` describing the presence of GAP3.

    EXAMPLES::

        sage: from sage.features.gap3 import Gap3
        sage: isinstance(Gap3(), Gap3)
        True
    """

    def __init__(self):
        r"""
        TESTS::

            sage: from sage.features.gap3 import Gap3
            sage: Gap3()
            Feature('gap3')
        """
        Executable.__init__(
            self,
            "gap3",
            executable="gap3",
            spkg="gap3",
            type="experimental",
        )


def all_features():
    return [Gap3()]
