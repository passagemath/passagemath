# -*- coding: utf-8 -*-
"""
Map Sage packages (spkgs) to native system packages across target distributions
and packaging formats.
"""

# ****************************************************************************
#       Copyright (C) 2017-2026 Matthias Koeppe <mkoeppe@math.ucdavis.edu>
#                     2026 Deepak Kambala <deepakkambala21@gmail.com>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 2 of the License, or
# (at your option) any later version.
#                  https://www.gnu.org/licenses/
# ****************************************************************************

from __future__ import print_function, unicode_literals

import os
import sys
import re
import shutil
import subprocess
from io import open

from sage_bootstrap.env import SAGE_ROOT
from sage_bootstrap.package import Package


def guess_package_system(sage_root=None):
    """
    Guess the system package manager (e.g. debian, fedora, arch, homebrew, conda).
    """
    if sage_root is None:
        sage_root = SAGE_ROOT

    # First try the external sage-guess-package-system script if found
    cmd = shutil.which('sage-guess-package-system')
    if not cmd and sage_root:
        local_cmd = os.path.join(sage_root, 'build', 'bin', 'sage-guess-package-system')
        if os.path.isfile(local_cmd) and os.access(local_cmd, os.X_OK):
            cmd = local_cmd

    if cmd:
        try:
            proc = subprocess.run([cmd], stdout=subprocess.PIPE, stderr=subprocess.PIPE, universal_newlines=True)
            out = proc.stdout.strip()
            if out and out != 'unknown':
                return out
        except Exception:
            pass

    # Built-in fallback detection logic
    if shutil.which('conda') and os.environ.get('CONDA_DEFAULT_ENV'):
        return 'conda'
    if shutil.which('nix-env'):
        return 'nix'
    if shutil.which('emerge'):
        return 'gentoo'
    if shutil.which('apt-get'):
        return 'debian'
    if shutil.which('dnf5') or shutil.which('dnf'):
        return 'fedora'
    if shutil.which('pacman'):
        import platform
        if platform.system().startswith('MINGW'):
            return 'mingw'
        return 'arch'
    if shutil.which('slackpkg'):
        return 'slackware'
    if shutil.which('zypper'):
        return 'opensuse'
    if shutil.which('apk'):
        return 'alpine'
    if shutil.which('xbps-install'):
        return 'void'
    if shutil.which('brew'):
        return 'homebrew'
    if shutil.which('port'):
        return 'macports'
    if shutil.which('pkg'):
        return 'freebsd'
    return 'unknown'


def resolve_purl_or_name(spkg):
    """
    Resolve a PURL or package name into an SPKG base name.
    """
    if any(spkg.startswith(prefix) for prefix in ('pkg:', 'pypi/', 'generic/')):
        try:
            return Package(spkg).name
        except Exception:
            pass
    return spkg


def extract_from_pyproject_toml(sage_root, pkg_base):
    """
    Extract matching requirements from pyproject.toml in sage_root.
    """
    pyproject_path = os.path.join(sage_root, 'pyproject.toml')
    if not os.path.isfile(pyproject_path):
        return []

    pkg_pattern = re.sub(r'[-_]', '[-_]', re.escape(pkg_base))
    line_re = re.compile(r"^\s*['\"](" + pkg_pattern + r".*?)['\"],?\s*$")

    matches = set()
    in_section = False
    try:
        with open(pyproject_path, 'r', encoding='utf-8', errors='replace') as f:
            for line in f:
                if re.search(r'(requires|dependencies|R)\s*=\s*\[', line):
                    in_section = True
                    continue
                if in_section:
                    if line.strip().startswith(']'):
                        in_section = False
                        continue
                    m = line_re.match(line)
                    if m:
                        matches.add(m.group(1))
    except (IOError, OSError):
        return []
    return sorted(matches)


def process_package(pkg_base, system, sage_root, enable_system_site_packages):
    """
    Extract system package mappings or requirement lines for a single package.
    """
    if system not in ('versions', 'install-requires', 'install-requires-toml', 'pip'):
        if not enable_system_site_packages:
            spkg_configure = os.path.join(sage_root, 'build', 'pkgs', pkg_base, 'spkg-configure.m4')
            if os.path.isfile(spkg_configure):
                try:
                    with open(spkg_configure, 'rt', encoding='utf-8', errors='replace') as f:
                        if 'SAGE_PYTHON_PACKAGE_CHECK' in f.read():
                            return []
                except (IOError, OSError):
                    pass

    if system in ('install-requires', 'install-requires-toml'):
        file_names = ['pyproject.toml', 'version_requirements.txt', 'requirements.txt']
    elif system == 'pip':
        file_names = ['requirements.txt', 'pyproject.toml', 'version_requirements.txt']
    elif system == 'versions':
        file_names = ['package-version.txt', 'requirements.txt', 'pyproject.toml', 'version_requirements.txt']
    else:
        file_names = ['distros/{0}.txt'.format(system)]

    output_lines = []

    for name in file_names:
        raw_lines = []
        if name == 'pyproject.toml':
            pyproject_matches = extract_from_pyproject_toml(sage_root, pkg_base)
            if pyproject_matches:
                raw_lines = pyproject_matches
        else:
            filepath = os.path.join(sage_root, 'build', 'pkgs', pkg_base, name)
            if os.path.isfile(filepath):
                try:
                    with open(filepath, 'r', encoding='utf-8', errors='replace') as f:
                        raw_lines = f.readlines()
                except (IOError, OSError):
                    pass

        if not raw_lines:
            continue

        if system == 'install-requires':
            processed = []
            for line in raw_lines:
                line = re.sub(r'#.*', '', line).strip()
                if line:
                    line = line.replace('"', "'")
                    processed.append(line)
            if processed:
                output_lines.extend(processed)
                break

        elif system == 'install-requires-toml':
            processed = []
            for line in raw_lines:
                line = re.sub(r'#.*', '', line).strip()
                if line:
                    line = line.replace("'", '"')
                    processed.append("'{0}',".format(line))
            if processed:
                output_lines.extend(processed)
                break

        elif system == 'pip':
            tokens = []
            for line in raw_lines:
                line = re.sub(r'#.*', '', line)
                line = re.sub(r'\s+', '', line)
                if line:
                    tokens.append(line)
            if tokens:
                output_lines.append(' '.join(tokens))
                break

        elif system == 'versions':
            processed = []
            for line in raw_lines:
                line = re.sub(r'#.*', '', line).strip()
                if line:
                    line = line.replace('"', "'")
                    processed.append('    ' + line)
            if processed:
                text = '\n'.join(processed)
                output_lines.append("{0}::\n\n{1}\n".format(name, text))

        else:
            python_minor = os.environ.get('PYTHON_MINOR', '')
            mingw_prefix = os.environ.get('MINGW_PACKAGE_PREFIX', '')
            tokens = []
            for line in raw_lines:
                line = re.sub(r'#.*', '', line)
                line = line.replace('${PYTHON_MINOR}', python_minor)
                line = line.replace('${MINGW_PACKAGE_PREFIX}', mingw_prefix)
                tokens.extend(line.split())
            if tokens:
                output_lines.append(' '.join(tokens))
                break

    return output_lines


def get_system_packages(system, spkgs, sage_root=None, enable_system_site_packages=None):
    """
    Get system packages or requirements for a list of packages.
    """
    if sage_root is None:
        sage_root = SAGE_ROOT
    if enable_system_site_packages is None:
        enable_system_site_packages = os.environ.get('ENABLE_SYSTEM_SITE_PACKAGES')

    if system == 'auto':
        system = guess_package_system(sage_root)
        if system == 'unknown' or not system:
            raise ValueError('unknown package system')

    expanded = []
    for s in spkgs:
        expanded.extend(s.split())

    results = []
    for spkg in expanded:
        pkg_base = resolve_purl_or_name(spkg)
        res = process_package(pkg_base, system, sage_root, enable_system_site_packages)
        results.extend(res)
    return results


def main(argv=None):
    if argv is None:
        argv = sys.argv[1:]

    if not argv:
        sys.stderr.write("usage: sage-get-system-packages {auto|debian|arch|conda|pip|...} SPKGS...\n")
        return 1

    system = argv[0]
    spkgs = argv[1:]

    try:
        lines = get_system_packages(system, spkgs)
        for line in lines:
            print(line)
        return 0
    except ValueError as e:
        sys.stderr.write("{0}\n".format(e))
        return 1
