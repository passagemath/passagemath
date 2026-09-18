# sage_setup: distribution = sagemath-tides
"""
Runtime helpers for the optional TIDES integrator.
"""

import os
import shlex


def _tides_compile_flags():
    """
    Return compiler flags for TIDES.
    """
    sage_local = os.environ.get("SAGE_LOCAL", "$SAGE_LOCAL")
    return (
        os.path.join(sage_local, "lib", "libTIDES.a"),
        os.path.join("-L" + sage_local, "lib "),
        os.path.join("-I" + sage_local, "include "),
    )
