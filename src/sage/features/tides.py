# sage_setup: distribution = sagemath-environment
r"""
Feature for testing the presence of the TIDES runtime library.
"""

# *****************************************************************************
#       Copyright (C) 2026 The Sage Developers
#
#  Distributed under the terms of the GNU General Public License (GPL)
#  as published by the Free Software Foundation; either version 2 of
#  the License, or (at your option) any later version.
#                  https://www.gnu.org/licenses/
# *****************************************************************************

import os
from pathlib import Path

from . import Feature, FeatureTestResult


class Tides(Feature):
    r"""
    A :class:`~sage.features.Feature` describing the presence of the
    :ref:`TIDES <spkg_tides>` headers and static library.

    EXAMPLES::

        sage: from sage.features.tides import Tides
        sage: isinstance(Tides(), Tides)
        True
    """
    def __init__(self):
        r"""
        TESTS::

            sage: from sage.features.tides import Tides
            sage: isinstance(Tides(), Tides)
            True
        """
        Feature.__init__(
            self,
            "tides",
            spkg="tides",
            url="https://github.com/joang/tides",
        )

    def _is_present(self):
        r"""
        Return whether the TIDES compile-time runtime files are usable.
        """
        candidates = []

        from sage.env import SAGE_LOCAL

        if SAGE_LOCAL:
            prefix = Path(SAGE_LOCAL)
            candidates.append(
                (prefix / "include", prefix / "lib" / "libTIDES.a")
            )

        if not candidates:
            return FeatureTestResult(
                self,
                False,
                reason=(
                    "TIDES runtime files are not available"
                ),
            )

        required_headers = ("minc_tides.h", "mp_tides.h")
        missing = []
        for include, library in candidates:
            missing = [
                os.fspath(include / header)
                for header in required_headers
                if not (include / header).is_file()
            ]
            if not library.is_file():
                missing.append(os.fspath(library))
            if not missing:
                return FeatureTestResult(self, True)

        return FeatureTestResult(
            self,
            False,
            reason="TIDES runtime is incomplete; missing " + ", ".join(missing),
        )


def all_features():
    return [Tides()]
