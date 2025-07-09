# Add data to the wheel

import os
import shlex
import sys

from pathlib import Path

from auditwheel.wheeltools import InWheel

from sage_conf import SAGE_LOCAL

if "TMPDIR" in os.environ:
    os.environ["TMPDIR"] = str(Path(os.environ["TMPDIR"]).resolve())

wheel = Path(sys.argv[1])

# SAGE_LOCAL/bin/* --> sage_wheels/bin/*
with InWheel(wheel, wheel):
    command = f'set -o pipefail; (cd {shlex.quote(SAGE_LOCAL)} && tar cf - --dereference bin/{{adjacency,adjacency_gmp,allfaces,allfaces_gmp,cddexec,cddexec_gmp,fourier,fourier_gmp,lcdd,lcdd_gmp,projection,projection_gmp,redcheck,redcheck_gmp,scdd,scdd_gmp,testcdd1,testcdd1_gmp,testcdd2,testcdd2_gmp,testlp1,testlp1_gmp,testlp2,testlp2_gmp,testlp3,testlp3_gmp,testshoot,testshoot_gmp}}) | (mkdir -p sage_wheels && cd sage_wheels && tar xvf -)'
    print(f'Running {command}')
    sys.stdout.flush()
    if os.system(f"bash -c {shlex.quote(command)}") != 0:
        sys.exit(1)
