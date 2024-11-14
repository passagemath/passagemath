# Add Maxima data to the wheel

import os
import shlex
import sys

from pathlib import Path

from sage_conf import SAGE_LOCAL

wheel = sys.argv[1]

# SAGE_LOCAL/bin/M2 --> sage_wheels/bin/M2 etc.
command = f'ln -sf {shlex.quote(SAGE_LOCAL)} sage_wheels && zip -r {shlex.quote(wheel)} sage_wheels/bin/M2* sage_wheels/{{share,lib,libexec}}/Macaulay2'
print(f'Running {command}')
sys.stdout.flush()
os.system(command)
