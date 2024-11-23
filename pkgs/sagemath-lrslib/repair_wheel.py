# Add data to the wheel

import os
import shlex
import sys

from pathlib import Path

from sage_conf import SAGE_LOCAL

wheel = sys.argv[1]

# SAGE_LOCAL/bin/lrslib --> sage_wheels/bin/lrslib
command = f'ln -sf {shlex.quote(SAGE_LOCAL)} sage_wheels && zip -r {shlex.quote(wheel)} sage_wheels/bin/{{*lrs*,*nash*,redund*}}'
print(f'Running {command}')
sys.stdout.flush()
os.system(command)
