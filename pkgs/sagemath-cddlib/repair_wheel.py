# Add Maxima data to the wheel

import os
import shlex
import sys

from pathlib import Path

from sage_conf import SAGE_LOCAL

wheel = sys.argv[1]

# SAGE_LOCAL/bin/* --> sage_wheels/bin/*
command = f'ln -sf {shlex.quote(SAGE_LOCAL)} sage_wheels && zip -r {shlex.quote(wheel)} sage_wheels/bin/{{adjacency,adjacency_gmp,allfaces,allfaces_gmp,cddexec,cddexec_gmp,fourier,fourier_gmp,lcdd,lcdd_gmp,projection,projection_gmp,redcheck,redcheck_gmp,scdd,scdd_gmp,testcdd1,testcdd1_gmp,testcdd2,testcdd2_gmp,testlp1,testlp1_gmp,testlp2,testlp2_gmp,testlp3,testlp3_gmp,testshoot,testshoot_gmp}}'
print(f'Running {command}')
sys.stdout.flush()
os.system(command)
