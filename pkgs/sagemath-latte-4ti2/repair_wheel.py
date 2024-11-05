# Add Maxima data to the wheel

import os
import shlex
import sys

from pathlib import Path

from sage_conf import SAGE_LOCAL

wheel = sys.argv[1]

# SAGE_LOCAL/bin/* --> sage_wheels/bin/*
command = f'ln -sf {shlex.quote(SAGE_LOCAL)} sage_wheels && zip -r {shlex.quote(wheel)} sage_wheels/bin/{{ConvertCDDextToLatte,ConvertCDDineToLatte,count,count-linear-forms-from-polynomial,ehrhart,ehrhart3,hilbert-from-rays,hilbert-from-rays-symm,integrate,latte-maximize,latte-minimize,latte2ext,latte2ine,polyhedron-to-cones,top-ehrhart-knapsack,triangulate}} sage_wheels/share/latte-int/{{m-knapsack.mpl,simplify*.add}} sage_wheels/bin/{{4ti2gmp,4ti2int32,4ti2int64,circuits,genmodel,gensymm,graver,groebner,hilbert,markov,minimize,normalform,output,ppi,qsolve,rays,walk,zbasis,zsolve}}'
print(f'Running {command}')
sys.stdout.flush()
os.system(command)
