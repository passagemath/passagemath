# Add Maxima data to the wheel

import os
import shlex
import sys

from pathlib import Path

from sage_conf import SAGE_LOCAL

wheel = sys.argv[1]

# SAGE_LOCAL/bin/gfan --> sage_wheels/bin/gfan
# Do not include the symlinks -- they are expanded to copies in the wheel.
command = f'ln -sf {shlex.quote(SAGE_LOCAL)} sage_wheels && zip -r {shlex.quote(wheel)} sage_wheels/bin/gfan'
print(f'Running {command}')
sys.stdout.flush()
os.system(command)
