# Add GAP data to the wheel

import os
import shlex
import sys

from pathlib import Path

from sage_conf import GAP_ROOT_PATHS

wheel = sys.argv[1]

for dir in GAP_ROOT_PATHS.split(';'):
    print(f'Adding {dir}')
    parent = Path(dir).parent
    name = Path(dir).name
    command = f'cd {shlex.quote(str(parent))} && zip {shlex.quote(wheel)} {name}'
    print(f'Running {command}')
    os.system(command)

print(GAP_ROOT_PATHS)