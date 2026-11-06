# -*- coding: utf-8 -*-
"""
Test sage-flock commandline utility
"""

import os
import unittest
import subprocess


EXECUTABLE = os.path.join(
    os.path.dirname(os.path.dirname(__file__)),
    'bin',
    'sage-flock',
)


class SageFlockTestCase(unittest.TestCase):

    def test_unlock_invalid_fd(self):
        # fd 1000 is not open in the child, so unlocking it fails
        proc = subprocess.Popen(
            [EXECUTABLE, '--unlock', '1000'],
            stdin=None, stdout=subprocess.PIPE, stderr=subprocess.PIPE,
            close_fds=True,
        )
        stdout, stderr = proc.communicate()
        self.assertEqual(proc.returncode, 1)
        self.assertIn('Unexpected error trying to unlock fd',
                      stderr.decode('utf-8'))
