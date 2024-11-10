# Add Maxima data to the wheel

import os
import shlex
import sys

from pathlib import Path

from sage_conf import SAGE_LOCAL

wheel = sys.argv[1]

# SAGE_LOCAL/bin/* --> sage_wheels/bin/*
command = f'ln -sf {shlex.quote(SAGE_LOCAL)} sage_wheels && zip -r {shlex.quote(wheel)} sage_wheels/bin/{{B_A,B_A_center,B_D,B_D_center,B_S,B_S_center,Dnxk,binomial,check,checkregularity,chiro2*,cocircuits2*,cross,cube,cyclic,hypersimplex,kDn,lattice,permutahedron,points2*,santos_*triang}}'
print(f'Running {command}')
sys.stdout.flush()
os.system(command)
