# Add GAP data to the wheel

import os
import shlex
import subprocess
import sys

from pathlib import Path

from auditwheel.wheeltools import InWheel

from sage_conf import GAP_ROOT_PATHS

if "TMPDIR" in os.environ:
    os.environ["TMPDIR"] = str(Path(os.environ["TMPDIR"]).resolve())

wheel = Path(sys.argv[1])

with InWheel(wheel, wheel):
    for dir in GAP_ROOT_PATHS.split(';'):
        print(f'Adding {dir}')
        sys.stdout.flush()
        parent = Path(dir).parent
        name = Path(dir).name
        command = f'set -o pipefail; (cd {shlex.quote(str(parent))} && tar cf - --exclude "*/transgrp/data" --exclude "*/ctbllib/data" --exclude "*/tomlib/data" --exclude "*/irredsol/data" {name}) | tar xvf -'
        print(f'Running {command}')
        sys.stdout.flush()
        subprocess.run(["bash", "-c", command], check=True)

    # Remove the sage-conf dependency; it is not needed because our wheels ship what is needed.

    command = 'sed -i.bak "/^Requires-Dist: passagemath-conf/d" *.dist-info/METADATA'
    print(f'Running {command}')
    sys.stdout.flush()
    subprocess.run(["bash", "-c", command], check=True)
