# -*- coding: utf-8 -*-
"""
Test the installation records written by sage-spkg
"""

import json
import os
import re
import shutil
import subprocess
import tempfile
import unittest

SAGE_SPKG = os.path.join(
    os.path.dirname(os.path.dirname(__file__)),
    'bin',
    'sage-spkg',
)


def write_installation_record_function():
    """
    Return the source code of the shell function ``write_installation_record``
    of ``sage-spkg``.
    """
    with open(SAGE_SPKG, 'rb') as f:
        source = f.read().decode('utf-8')
    match = re.search(r'^write_installation_record\(\) \{.*?'
                      r'^\} #+ write_installation_record$',
                      source, re.DOTALL | re.MULTILINE)
    return match.group(0)


class SpkgInstallationRecordTestCase(unittest.TestCase):

    def write_record(self, file_list):
        """
        Run ``write_installation_record`` with the given list of file names
        and return the installation record that it writes.
        """
        tmp = tempfile.mkdtemp()
        self.addCleanup(shutil.rmtree, tmp)
        with open(os.path.join(tmp, 'VERSION.txt'), 'w') as f:
            f.write('1.0\n')
        env = dict(os.environ,
                   SAGE_ROOT=tmp,
                   SAGE_SPKG_INST=tmp,
                   PKG_NAME='demo-1.0',
                   PKG_BASE='demo',
                   PKG_VER='1.0',
                   TEST_SUITE_RESULT='not available',
                   FILE_LIST='\n'.join(file_list))
        script = write_installation_record_function() + '\nwrite_installation_record\n'
        subprocess.check_call(['bash', '-c', script], env=env)
        with open(os.path.join(tmp, 'demo-1.0'), 'rb') as f:
            return json.loads(f.read().decode('utf-8'))

    def check_files(self, file_list):
        record = self.write_record(file_list)
        self.assertEqual(record['package_name'], 'demo')
        self.assertEqual(record['files'], file_list)

    def test_no_files(self):
        self.check_files([])

    def test_one_file(self):
        self.check_files(['lib/libdemo.so'])

    def test_spaces(self):
        # https://github.com/passagemath/passagemath/issues/1584
        self.check_files([
            'lib/gap/pkg/walrus/Polynomial-time proofs that groups are hyperbolic.ipynb',
            'lib/gap/pkg/walrus/README.md',
            'share/demo/  leading and trailing spaces  ',
            'share/demo/   ',
            '   ',
        ])

    def test_quotes_and_backslashes(self):
        self.check_files([
            'share/demo/quote"name.txt',
            'share/demo/back\\slash.txt',
            'share/demo/\\"',
        ])

    def test_control_characters(self):
        self.check_files([
            'share/demo/tab\tname.txt',
            'share/demo/carriage\rreturn.txt',
            'share/demo/\x01\x1b\x1f\x7f',
        ])

    def test_non_ascii(self):
        self.check_files([
            u'share/demo/caf\xe9.txt',
            u'share/demo/caf\xe9\ttab.txt',
        ])


if __name__ == '__main__':
    unittest.main()
