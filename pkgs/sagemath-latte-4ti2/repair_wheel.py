# Add data to the wheel

import os
import shlex
import sys

from pathlib import Path

from auditwheel.wheeltools import InWheel

from sage_conf import SAGE_LOCAL

if "TMPDIR" in os.environ: os.environ["TMPDIR"] = str(Path(os.environ["TMPDIR"]).resolve())

wheel = Path(sys.argv[1])

# SAGE_LOCAL/bin/* --> sage_wheels/bin/*
with InWheel(wheel, wheel):
    command = f'(cd {shlex.quote(SAGE_LOCAL)} && tar cf - --dereference bin/{{ConvertCDDextToLatte,ConvertCDDineToLatte,count,count-linear-forms-from-polynomial,ehrhart,ehrhart3,hilbert-from-rays,hilbert-from-rays-symm,integrate,latte-maximize,latte-minimize,latte2ext,latte2ine,polyhedron-to-cones,top-ehrhart-knapsack,triangulate}} share/latte-int/{{m-knapsack.mpl,simplify*.add}} bin/{{4ti2gmp,4ti2int32,4ti2int64,circuits,genmodel,gensymm,graver,groebner,hilbert,markov,minimize,normalform,output,ppi,qsolve,rays,walk,zbasis,zsolve}}) | (mkdir -p sage_wheels && cd sage_wheels && tar xvf -)'
    print(f'Running {command}')
    sys.stdout.flush()
    os.system(command)
