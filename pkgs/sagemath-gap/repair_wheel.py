# Add GAP data to the wheel

import os
import shlex
import sys

from pathlib import Path

from auditwheel.wheeltools import InWheel

from sage_conf import GAP_ROOT_PATHS

wheel = Path(sys.argv[1])

with InWheel(wheel, wheel):
    for dir in GAP_ROOT_PATHS.split(';'):
        print(f'Adding {dir}')
        sys.stdout.flush()
        parent = Path(dir).parent
        name = Path(dir).name
        command = f'(cd {shlex.quote(str(parent))} && tar cf - {name}) | tar xvf -'
        print(f'Running {command}')
        sys.stdout.flush()
        os.system(command)

    # Remove the sage-conf dependency; it is not needed because our wheels ship what is needed.

    command = f'sed -i.bak "/^Requires-Dist: passagemath-conf/d" *.dist-info/METADATA'
    print(f'Running {command}')
    sys.stdout.flush()
    os.system(command)
