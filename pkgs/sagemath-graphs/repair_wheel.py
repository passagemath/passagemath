# Add data to the wheel

import os
import shlex
import subprocess
import sys

from pathlib import Path

from auditwheel.wheeltools import InWheel

from sage_conf import SAGE_LOCAL

if "TMPDIR" in os.environ:
    os.environ["TMPDIR"] = str(Path(os.environ["TMPDIR"]).resolve())

wheel = Path(sys.argv[1])

# SAGE_LOCAL/share/graphs/** --> sage_wheels/share/graphs/**
with InWheel(wheel, wheel):
    command = f'set -o pipefail; (cd {shlex.quote(SAGE_LOCAL)} && tar cf - --dereference share/graphs) | (mkdir -p sage_wheels && cd sage_wheels && tar xvf -)'
    print(f'Running {command}')
    sys.stdout.flush()
    subprocess.run(["bash", "-c", command], check=True)

    # Remove the sage-conf dependency; it is not needed because our wheels ship what is needed.

    command = 'sed -i.bak "/^Requires-Dist: passagemath-conf/d" *.dist-info/METADATA'
    print(f'Running {command}')
    sys.stdout.flush()
    subprocess.run(["bash", "-c", command], check=True)
