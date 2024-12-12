# Add Maxima data to the wheel

import os
import shlex
import sys

from pathlib import Path

from sage_conf import MAXIMA_FAS, SAGE_LOCAL

wheel = sys.argv[1]

# SAGE_LOCAL/lib/ecl/maxima.fas --> ecl/maxima.fas
parent = Path(MAXIMA_FAS).parent.parent
name = Path(MAXIMA_FAS).parent.name
command = f'cd {shlex.quote(str(parent))} && zip -r {shlex.quote(wheel)} {name}'
print(f'Running {command}')
sys.stdout.flush()
os.system(command)

# SAGE_LOCAL/bin/maxima --> sage_wheels/bin/maxima
command = f'ln -sf {shlex.quote(SAGE_LOCAL)} sage_wheels && zip -r {shlex.quote(wheel)} sage_wheels/bin/maxima sage_wheels/share/maxima sage_wheels/share/info/*maxima*'
print(f'Running {command}')
sys.stdout.flush()
os.system(command)
