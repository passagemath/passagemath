# Add data to the wheel

import os
import shlex
import sys

from pathlib import Path

from auditwheel.wheeltools import InWheel

from sage_conf import SAGE_LOCAL

wheel = sys.argv[1]

if "TMPDIR" in os.environ:
    os.environ["TMPDIR"] = str(Path(os.environ["TMPDIR"]).resolve())

wheel = Path(sys.argv[1])

with InWheel(wheel, wheel):
    # SAGE_LOCAL/bin/fricas --> sage_wheels/bin/fricas
    command = f'set -o pipefail; (cd {shlex.quote(SAGE_LOCAL)} && tar cf - --dereference bin/{{fricas,efricas}} lib/fricas) | (mkdir -p sage_wheels && cd sage_wheels && tar xvf -)'
    print(f'Running {command}')
    sys.stdout.flush()
    if os.system(f"bash -c {shlex.quote(command)}") != 0:
        sys.exit(1)

    # Remove the sage-conf dependency; it is not needed because our wheels ship what is needed.

    command = 'sed -i.bak "/^Requires-Dist: passagemath-conf/d" *.dist-info/METADATA'
    print(f'Running {command}')
    sys.stdout.flush()
    if os.system(f"bash -c {shlex.quote(command)}") != 0:
        sys.exit(1)
