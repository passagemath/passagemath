# Add Maxima data to the wheel

import os
import shlex
import sys

from pathlib import Path

from sage_conf import SAGE_LOCAL

wheel = sys.argv[1]

# SAGE_LOCAL/bin/maxima --> sage_wheels/bin/maxima
command = f'ln -sf {shlex.quote(SAGE_LOCAL)} sage_wheels && zip -r {shlex.quote(wheel)} sage_wheels/bin/maxima sage_wheels/share/maxima sage_wheels/share/info/*maxima*'
print(f'Running {command}')
sys.stdout.flush()
os.system(command)

# Remove the sage-conf dependency; it is not needed because our wheels ship what is needed.

command = f'rm -rf *.dist-info && unzip {shlex.quote(wheel)} "*.dist-info/METADATA" && sed -i.bak "/^Requires-Dist: passagemath-conf/d" *.dist-info/METADATA && zip -r {shlex.quote(wheel)} *.dist-info/METADATA'
print(f'Running {command}')
sys.stdout.flush()
os.system(command)
