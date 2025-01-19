# Add data to the wheel

import os
import shlex
import sys

from pathlib import Path

from auditwheel.wheeltools import InWheel

from sage_conf import MAXIMA_FAS, SAGE_LOCAL

wheel = sys.argv[1]

with InWheel(wheel, wheel):
    # SAGE_LOCAL/bin/ecl --> sage_wheels/bin/ecl
    # Include lib/maxima/5.47.0/binary-ecl/maxima, which is linked through to libecl
    command = f'(cd {shlex.quote(SAGE_LOCAL)} && tar cf - --dereference bin/ecl lib/ecl-* lib/maxima) | (mkdir -p sage_wheels && cd sage_wheels && tar xvf -)'
    print(f'Running {command}')
    sys.stdout.flush()
    os.system(command)
    # Include maxima.fas, which is linked through to libecl
    # SAGE_LOCAL/lib/ecl/maxima.fas --> ecl/maxima.fas
    parent = Path(MAXIMA_FAS).parent.parent
    name = Path(MAXIMA_FAS).parent.name
    command = f'(cd {shlex.quote(str(parent))} && tar cf - --dereference {name}) | tar xvf -'
    print(f'Running {command}')
    sys.stdout.flush()
    os.system(command)
