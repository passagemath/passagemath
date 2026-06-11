"""
Runtime helpers for the optional TIDES integrator.
"""

import os
import shlex


def _tides_compile_flags():
    """
    Return compiler flags for TIDES.

    Normal Sage installations use ``SAGE_LOCAL``. Installed wheels can provide
    the same redistributable headers and static library through the optional
    ``sagelite-tides-runtime`` companion package.
    """
    try:
        from sagelite_tides.runtime import include_dir, library_path
    except ImportError:
        pass
    else:
        include = include_dir()
        library = library_path()
        if include.is_dir() and library.is_file():
            return (
                shlex.quote(os.fspath(library)),
                "-L" + shlex.quote(os.fspath(library.parent)) + " ",
                "-I" + shlex.quote(os.fspath(include)) + " ",
            )

    sage_local = os.environ.get("SAGE_LOCAL", "$SAGE_LOCAL")
    return (
        os.path.join(sage_local, "lib", "libTIDES.a"),
        os.path.join("-L" + sage_local, "lib "),
        os.path.join("-I" + sage_local, "include "),
    )
