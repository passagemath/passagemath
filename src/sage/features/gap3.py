r"""
Feature for testing the presence of ``gap3``.
"""

from . import Executable, Feature, FeatureTestResult


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
            type="optional",
        )


class Gap3Package(Feature):
    r"""
    A :class:`~sage.features.Feature` describing the presence of a GAP3 package.

    A GAP3 package is "present" if it *can be* loaded, not if it *has
    been* loaded.

    .. SEEALSO::

        :class:`Feature sage.libs.gap <~sage.features.sagemath.sage__libs__gap>`

    EXAMPLES::

        sage: from sage.features.gap3 import Gap3Package
        sage: Gap3Package("chevie", spkg='gap3')
        Feature('gap3_package_chevie')
    """
    def __init__(self, package, spkg='gap3', **kwds):
        r"""
        TESTS::

            sage: from sage.features.gap3 import Gap3Package
            sage: isinstance(Gap3Package("chevie", spkg='gap3'), Gap3Package)
            True
        """
        Feature.__init__(self, f"gap3_package_{package}", spkg=spkg, **kwds)
        self.package = package

    def _is_present(self):
        r"""
        Return whether or not the GAP3 package is present.

        If the package is installed but not yet loaded, it is loaded
        first. This does *not* check that the package is functional.

        EXAMPLES::

            sage: from sage.features.gap3 import Gap3Package
            sage: Gap3Package("chevie", spkg='gap3')._is_present()  # optional - gap3_package_chevie
            FeatureTestResult('gap3_package_chevie', True)
        """
        try:
            from sage.interfaces.gap3 import gap3
            gap3._start()
            gap3.load_package(self.package)
            return FeatureTestResult(self, True)
        except Exception as exception:
            return FeatureTestResult(self, False,
                                     reason="Loading the GAP3 package raised an error: {exception}.".format(
                                         exception=exception))


def all_features():
    return [Gap3()]
