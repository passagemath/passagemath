# Add data to the wheel

import os
import shlex
import sys

from pathlib import Path

from sage_conf import SAGE_LOCAL

wheel = sys.argv[1]

# SAGE_LOCAL/bin/ecl --> sage_wheels/bin/ecl
# Include lib/maxima/5.47.0/binary-ecl/maxima, which is linked through to libecl
command = f'ln -sf {shlex.quote(SAGE_LOCAL)} sage_wheels && zip -r {shlex.quote(wheel)} sage_wheels/bin/ecl sage_wheels/lib/ecl-* sage_wheels/lib/maxima'
print(f'Running {command}')
sys.stdout.flush()
os.system(command)