# Add data to the wheel

import os
import shlex
import sys

from pathlib import Path

from auditwheel.wheeltools import InWheel

from sage_conf import SAGE_LOCAL

wheel = sys.argv[1]

# SAGE_LOCAL/bin/kissat --> sage_wheels/bin/kissat
with InWheel(wheel, wheel):
    command = f'(cd {shlex.quote(SAGE_LOCAL)} && tar cf - --dereference bin/kissat) | (mkdir -p sage_wheels && cd sage_wheels && tar xvf -)'
    print(f'Running {command}')
    sys.stdout.flush()
    os.system(command)
