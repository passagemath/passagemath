# Add data to the wheel

import os
import shlex
import sys

from pathlib import Path

from auditwheel.wheeltools import InWheel

from sage.config import SAGE_LOCAL

if "TMPDIR" in os.environ:
    os.environ["TMPDIR"] = str(Path(os.environ["TMPDIR"]).resolve())

wheel = Path(sys.argv[1])

# kenzo.fas is already shipped by passagemath-ecl
with InWheel(wheel, wheel):
    # Remove the sage-conf dependency; it is not needed because our wheels ship what is needed.
    command = 'sed -i.bak "/^Requires-Dist: passagemath-conf/d" *.dist-info/METADATA'
    print(f'Running {command}')
    sys.stdout.flush()
    if os.system(f"bash -c {shlex.quote(command)}") != 0:
        sys.exit(1)
