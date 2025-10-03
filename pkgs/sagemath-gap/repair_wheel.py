# Add GAP data to the wheel

import os
import shlex
import sys

from pathlib import Path

from auditwheel.wheeltools import InWheel

from sage_conf import GAP_ROOT_PATHS
from sage_conf import SAGE_LOCAL


if "TMPDIR" in os.environ:
    os.environ["TMPDIR"] = str(Path(os.environ["TMPDIR"]).resolve())

wheel = Path(sys.argv[1])

with InWheel(wheel, wheel):
    for dir in GAP_ROOT_PATHS.split(';'):
        print(f'Adding {dir}')
        sys.stdout.flush()
        parent = Path(dir).parent
        name = Path(dir).name
        command = f'set -o pipefail; (cd {shlex.quote(str(parent))} && tar cf - --exclude "*/transgrp/data" --exclude "*/ctbllib/data" --exclude "*/tomlib/data" --exclude "*/irredsol/data" --exclude "*/irredsol/fp" --exclude "*/factint/tables" --exclude "*/numericalsgps/data" --exclude "*/primgrp/data" --exclude "*/sglppow/lib/3hoch8" --exclude "*/simpcomp/complexes" --exclude "*/smallgrp/id*" --exclude "*/smallgrp/small*" --exclude "*/sonata/grp" --exclude "*/sonata/nr*" --exclude "*/unitlib/data" --exclude "*/smallsemi/data" --exclude "*/rcwa/data" --exclude "*/difsets/data" --exclude "*/yangbaxter/data" --exclude "*/agt/srglib" --exclude "*/caratinterface" --exclude "*/cddinterface" --exclude "*/curlinterface" --exclude "*/normalizinterface" --exclude "*/semigroups" --exclude "*/*/doc" --exclude "*/*/tutorial" --exclude "*/**/*.o" --exclude "*/digraphs/extern" --exclude "*/digraphs/gen" --exclude "*/grape/nauty*" --exclude "*/*/src" --exclude "*/*/www" --exclude "*/*/htm" {name}) | tar xvf -'
        print(f'Running {command}')
        sys.stdout.flush()
        if os.system(f"bash -c {shlex.quote(command)}") != 0:
            sys.exit(1)

    # real gap executable
    command = f'set -o pipefail; (cd {shlex.quote(SAGE_LOCAL)}/bin && tar cf - --dereference gap) | (cd gap && tar xvf -)'
    print(f'Running {command}')
    sys.stdout.flush()
    if os.system(f"bash -c {shlex.quote(command)}") != 0:
        sys.exit(1)

    # gap relocation script
    os.makedirs("sage_wheels/bin", exist_ok=True)
    with open("sage_wheels/bin/gap", "w") as f:
        f.write('#!/usr/bin/env bash\npython3 -m sage.interfaces.gap "$@"\n')
    os.system("chmod +x sage_wheels/bin/gap")
    print('Created sage_wheels/bin/gap')

    # Remove the sage-conf dependency; it is not needed because our wheels ship what is needed.

    command = 'sed -i.bak "/^Requires-Dist: passagemath-conf/d" *.dist-info/METADATA'
    print(f'Running {command}')
    sys.stdout.flush()
    if os.system(f"bash -c {shlex.quote(command)}") != 0:
        sys.exit(1)
