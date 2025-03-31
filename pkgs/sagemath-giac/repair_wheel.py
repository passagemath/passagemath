# Add the giac binary to the wheel

import os
import shlex
import sys

from pathlib import Path

from auditwheel.wheeltools import InWheel

from sage_conf import SAGE_LOCAL

wheel = Path(sys.argv[1])

# SAGE_LOCAL/bin/giac --> sage_wheels/bin/giac
with InWheel(wheel, wheel):
    command = f'(cd {shlex.quote(SAGE_LOCAL)} && tar cf - --dereference bin/giac) | (mkdir -p sage_wheels && cd sage_wheels && tar xvf -)'
    print(f'Running {command}')
    sys.stdout.flush()
    os.system(command)
