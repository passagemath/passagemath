# Add Maxima data to the wheel

import os
import shlex
import sys

from pathlib import Path

from auditwheel.wheeltools import InWheel

from sage_conf import SAGE_LOCAL

wheel = Path(sys.argv[1])

with InWheel(wheel, wheel):
    # SAGE_LOCAL/bin/maxima --> sage_wheels/bin/maxima
    command = f'(cd {shlex.quote(SAGE_LOCAL)} && tar cf - --dereference bin/maxima share/maxima share/info/*maxima*) | (mkdir -p sage_wheels && cd sage_wheels && tar xvf -)'
    print(f'Running {command}')
    sys.stdout.flush()
    os.system(command)

    # Remove the sage-conf dependency; it is not needed because our wheels ship what is needed.
    command = f'sed -i.bak "/^Requires-Dist: passagemath-conf/d" *.dist-info/METADATA'
    print(f'Running {command}')
    sys.stdout.flush()
    os.system(command)
