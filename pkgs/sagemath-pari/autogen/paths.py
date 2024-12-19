"""
Find out installation paths of PARI/GP
"""

#*****************************************************************************
#       Copyright (C) 2017 Jeroen Demeyer <jdemeyer@cage.ugent.be>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 2 of the License, or
# (at your option) any later version.
#                  http://www.gnu.org/licenses/
#*****************************************************************************

from __future__ import absolute_import, unicode_literals

import os
import shutil

from glob import glob


gppath = shutil.which("gp")

if gppath is None:
    # This almost certainly won't work, but we need to put something here
    prefix = "."
else:
    # Assume gppath is ${prefix}/bin/gp
    prefix = os.path.dirname(os.path.dirname(gppath))


def pari_share():
    r"""
    Return the directory where the PARI data files are stored.

    EXAMPLES::

        >>> import os
        >>> from autogen.parser import pari_share
        >>> os.path.isfile(os.path.join(pari_share(), "pari.desc"))
        True
    """
    if "PARI_SHARE" in os.environ:
        return os.environ["PARI_SHARE"]
    from subprocess import Popen, PIPE
    if not gppath:
        raise EnvironmentError("cannot find an installation of PARI/GP: make sure that the 'gp' program is in your $PATH")
    # Ignore GP_DATA_DIR environment variable
    env = dict(os.environ)
    env.pop("GP_DATA_DIR", None)
    gp = Popen([gppath, "-f", "-q"], stdin=PIPE, stdout=PIPE, env=env)
    out = gp.communicate(b"print(default(datadir))")[0]
    # Convert out to str if needed
    if not isinstance(out, str):
        from sys import getfilesystemencoding
        out = out.decode(getfilesystemencoding(), "surrogateescape")
    datadir = out.strip()
    if not os.path.isdir(datadir):
        # As a fallback, try a path relative to the prefix
        datadir = os.path.join(prefix, "share", "pari")
        if not os.path.isdir(datadir):
            raise EnvironmentError("PARI data directory {!r} does not exist".format(datadir))
    return datadir


def include_dirs():
    """
    Return a list of directories containing PARI include files.
    """
    dirs = [os.path.join(prefix, "include")]
    return [d for d in dirs if os.path.isdir(os.path.join(d, "pari"))]


def library_dirs():
    """
    Return a list of directories containing PARI library files.
    """
    dirs = [os.path.join(prefix, s) for s in ("lib", "lib32", "lib64")]
    return [d for d in dirs if glob(os.path.join(d, "libpari*"))]
