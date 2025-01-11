# Add GAP data to the wheel

import os
import shlex
import sys

from pathlib import Path

from sage_conf import GAP_ROOT_PATHS

wheel = sys.argv[1]

for dir in GAP_ROOT_PATHS.split(';'):
    print(f'Adding {dir}')
    sys.stdout.flush()
    parent = Path(dir).parent
    name = Path(dir).name
    command = f'cd {shlex.quote(str(parent))} && zip -r {shlex.quote(wheel)} {name}'
    print(f'Running {command}')
    sys.stdout.flush()
    os.system(command)

# Remove the sage-conf dependency; it is not needed because our wheels ship what is needed.

command = f'rm -rf *.dist-info && unzip {shlex.quote(wheel)} "*.dist-info/METADATA" && sed -i.bak "/^Requires-Dist: passagemath-conf/d" *.dist-info/METADATA && zip -r {shlex.quote(wheel)} *.dist-info/METADATA'
print(f'Running {command}')
sys.stdout.flush()
os.system(command)
