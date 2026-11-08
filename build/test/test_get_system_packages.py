# -*- coding: utf-8 -*-
"""
Test sage-get-system-packages commandline utility and get_system_packages module
"""

# ****************************************************************************
#       Copyright (C) 2026 Deepak Kambala <deepakkambala21@gmail.com>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 2 of the License, or
# (at your option) any later version.
#                  https://www.gnu.org/licenses/
# ****************************************************************************

import os
import sys
import unittest
import subprocess
import tempfile

from sage_bootstrap.env import SAGE_ROOT
from sage_bootstrap.get_system_packages import get_system_packages, main

PATH = os.path.join(
    os.path.dirname(os.path.dirname(os.path.abspath(__file__))),
    'bin'
)

EXECUTABLE = os.path.join(PATH, 'sage-get-system-packages')


class GetSystemPackagesTestCase(unittest.TestCase):

    def run_command(self, *args, **kwds):
        env = dict(os.environ)
        env.update(kwds.get('env', {}))
        env['PATH'] = PATH + os.pathsep + env.get('PATH', '')
        kwds['env'] = env
        kwds['stdout'] = subprocess.PIPE
        kwds['stderr'] = subprocess.PIPE
        kwds['universal_newlines'] = True
        proc = subprocess.Popen([EXECUTABLE] + list(args), **kwds)
        stdout, stderr = proc.communicate()
        return proc.returncode, stdout, stderr

    def test_usage_no_args(self):
        rc, stdout, stderr = self.run_command()
        self.assertEqual(rc, 1)
        self.assertIn("usage: sage-get-system-packages", stderr)

    def test_debian_texlive(self):
        rc, stdout, stderr = self.run_command('debian', 'texlive')
        self.assertEqual(rc, 0)
        self.assertIn('texlive-latex-extra', stdout)
        self.assertIn('latexmk', stdout)

    def test_fedora_texlive(self):
        rc, stdout, stderr = self.run_command('fedora', 'texlive')
        self.assertEqual(rc, 0)
        self.assertIn('latexmk', stdout)
        self.assertIn('texlive-collection-latexextra', stdout)

    def test_debian_multiple(self):
        rc, stdout, stderr = self.run_command('debian', 'curl', 'gmp')
        self.assertEqual(rc, 0)
        self.assertIn('curl', stdout)
        self.assertIn('libcurl4-openssl-dev', stdout)
        self.assertIn('libgmp-dev', stdout)

    def test_pip(self):
        rc, stdout, stderr = self.run_command('pip', 'numpy')
        self.assertEqual(rc, 0)
        self.assertIn('numpy>=2.1', stdout)

    def test_install_requires(self):
        rc, stdout, stderr = self.run_command('install-requires', 'numpy')
        self.assertEqual(rc, 0)
        self.assertIn('numpy >=2.1', stdout)

    def test_install_requires_toml(self):
        rc, stdout, stderr = self.run_command('install-requires-toml', 'numpy')
        self.assertEqual(rc, 0)
        self.assertIn("'numpy >=2.1',", stdout)

    def test_install_requires_toml_with_comment(self):
        rc, stdout, stderr = self.run_command('install-requires-toml', 'pynormaliz')
        self.assertEqual(rc, 0)
        self.assertIn("'pynormaliz >=2.18;", stdout)

    def test_versions(self):
        rc, stdout, stderr = self.run_command('versions', 'numpy')
        self.assertEqual(rc, 0)
        self.assertIn('package-version.txt::', stdout)
        self.assertIn('pyproject.toml::', stdout)
        self.assertIn('numpy >=2.1', stdout)

    def test_site_packages_filter(self):
        # Without ENABLE_SYSTEM_SITE_PACKAGES, dateutil (which has SAGE_PYTHON_PACKAGE_CHECK) is skipped
        env_without = dict(os.environ)
        env_without.pop('ENABLE_SYSTEM_SITE_PACKAGES', None)
        rc, stdout, stderr = self.run_command('debian', 'dateutil', env=env_without)
        self.assertEqual(rc, 0)
        self.assertNotIn('python3-dateutil', stdout)

        # With ENABLE_SYSTEM_SITE_PACKAGES=yes, dateutil is included
        rc, stdout, stderr = self.run_command('debian', 'dateutil', env={'ENABLE_SYSTEM_SITE_PACKAGES': 'yes'})
        self.assertEqual(rc, 0)
        self.assertIn('python3-dateutil', stdout)

    def test_variable_substitution(self):
        # Test ${PYTHON_MINOR}
        rc, stdout, stderr = self.run_command(
            'opensuse', 'dateutil',
            env={'ENABLE_SYSTEM_SITE_PACKAGES': 'yes', 'PYTHON_MINOR': '11'}
        )
        self.assertEqual(rc, 0)
        self.assertIn('python311-python-dateutil', stdout)

        # Test ${MINGW_PACKAGE_PREFIX}
        rc, stdout, stderr = self.run_command(
            'mingw', 'dateutil',
            env={'ENABLE_SYSTEM_SITE_PACKAGES': 'yes', 'MINGW_PACKAGE_PREFIX': 'mingw-w64-x86_64'}
        )
        self.assertEqual(rc, 0)
        self.assertIn('mingw-w64-x86_64-python-dateutil', stdout)

    def test_purl_resolution(self):
        rc, stdout, stderr = self.run_command('debian', 'generic/gmp', 'pkg:generic/gap')
        self.assertEqual(rc, 0)
        self.assertIn('libgmp-dev', stdout)
        self.assertIn('libgap-dev', stdout)

    def test_bogus_sage_root_fallback(self):
        # Running with SAGE_ROOT pointing to an invalid directory (e.g. /content as in issue #2867)
        # should fall back to resolving SAGE_ROOT correctly without crashing.
        bogus_dir = tempfile.mkdtemp()
        try:
            rc, stdout, stderr = self.run_command('debian', 'texlive', env={'SAGE_ROOT': bogus_dir})
            self.assertEqual(rc, 0)
            self.assertIn('texlive-latex-extra', stdout)
        finally:
            try:
                os.rmdir(bogus_dir)
            except OSError:
                pass


if __name__ == '__main__':
    unittest.main()
