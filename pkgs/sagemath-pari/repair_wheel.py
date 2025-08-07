# Add data to the wheel

import glob
import json
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
    command = f'set -o pipefail; (cd {shlex.quote(SAGE_LOCAL)} && tar cf - --dereference bin/gp bin/xeus-gp bin/gp2c* share/gp2c/func.dsc) | (mkdir -p sage_wheels && cd sage_wheels && tar xvf -)'
    print(f'Running {command}')
    sys.stdout.flush()
    if os.system(f"bash -c {shlex.quote(command)}") != 0:
        sys.exit(1)

    for kernel_file_name in glob.iglob('passagemath_pari-*.data/data/share/jupyter/kernels/xeus-gp/kernel.json'):
        with open(kernel_file_name, "r") as f:
            spec = json.load(f)
        spec["argv"] = ["sage",
                        "-sh",
                        "-c",
                        "xeus-gp -f {connection_file}"]
        with open(kernel_file_name, "w") as f:
            json.dump(spec, f, indent=True)
