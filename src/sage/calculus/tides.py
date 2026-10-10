# sage_setup: distribution = sagemath-tides
"""
Runtime helpers for the optional TIDES integrator.
"""

import os
import shlex

from sage.env import SAGE_LOCAL


def _tides_compile_flags():
    """
    Return compiler flags for TIDES.
    """
    # FIXME: This should really go through sage.features.tides
    sage_local = SAGE_LOCAL or "$SAGE_LOCAL"
    return (
        os.path.join(sage_local, "lib", "libTIDES.a"),
        os.path.join("-L" + sage_local, "lib "),
        os.path.join("-I" + sage_local, "include "),
    )
