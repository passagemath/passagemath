# Add data to the wheel

import os
import shlex
import sys

from pathlib import Path

from sage_conf import SAGE_LOCAL

wheel = sys.argv[1]

# SAGE_LOCAL/lib/ecl/kenzo.fas --> sage_wheels/lib/ecl/kenzo.fas
command = f'ln -sf {shlex.quote(SAGE_LOCAL)} sage_wheels && zip -r {shlex.quote(wheel)} sage_wheels/lib/ecl/kenzo*'
print(f'Running {command}')
sys.stdout.flush()
os.system(command)
