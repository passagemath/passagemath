r"""
Feature for the rank-width graph decomposition
"""

from sage.features import PythonModule
from sage.features.join_feature import JoinFeature


class RankWidth(JoinFeature):
    r"""
    A :class:`~sage.features.Feature` indicating whether or not the
    rank-width graph decomposition is available.

    This is a proxy for the build-time availability of the rankwidth
    (librw) library from the "rw" package; the associated module
    :mod:`sage.graphs.graph_decompositions.rankwidth` is built if and
    only if the library is detected, usable, and enabled.

    EXAMPLES::

        sage: from sage.features.rankwidth import RankWidth
        sage: RankWidth().is_present()  # needs rankwidth
        FeatureTestResult('rankwidth', True)
        sage: RankWidth().is_present()  # needs !rankwidth
        FeatureTestResult('sage.graphs.graph_decompositions.rankwidth', False)

    """
    def __init__(self):
        r"""
        EXAMPLES::

            sage: from sage.features.rankwidth import RankWidth
            sage: RankWidth()
            Feature('rankwidth')

        """
        f = PythonModule("sage.graphs.graph_decompositions.rankwidth")
        JoinFeature.__init__(self, "rankwidth", [f], spkg="rw", type="standard")


def all_features():
    return [RankWidth()]
