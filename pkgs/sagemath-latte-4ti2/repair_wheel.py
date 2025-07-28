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
    # On macOS, 'configure --enable-relocatable' leads to the creation of .bin files (the actual LattE executables)
    command = f'set -o pipefail; (cd {shlex.quote(SAGE_LOCAL)} && if [ -x bin/count.bin ]; then LATTE_EXE=$(echo bin/{{ConvertCDDextToLatte,ConvertCDDineToLatte,count,count-linear-forms-from-polynomial,ehrhart,ehrhart3,hilbert-from-rays,hilbert-from-rays-symm,integrate,latte-maximize,latte-minimize,latte2ext,latte2ine,polyhedron-to-cones,top-ehrhart-knapsack,triangulate}}{{,.bin}}); else LATTE_EXE=$(echo bin/{{ConvertCDDextToLatte,ConvertCDDineToLatte,count,count-linear-forms-from-polynomial,ehrhart,ehrhart3,hilbert-from-rays,hilbert-from-rays-symm,integrate,latte-maximize,latte-minimize,latte2ext,latte2ine,polyhedron-to-cones,top-ehrhart-knapsack,triangulate}}); fi && tar cf - --dereference $LATTE_EXE share/latte-int/{{m-knapsack.mpl,simplify*.add}} bin/{{4ti2gmp,4ti2int32,4ti2int64,circuits,genmodel,gensymm,graver,groebner,hilbert,markov,minimize,normalform,output,ppi,qsolve,rays,walk,zbasis,zsolve}}) | (mkdir -p sage_wheels && cd sage_wheels && tar xvf -)'
    print(f'Running {command}')
    sys.stdout.flush()
    if os.system(f"bash -c {shlex.quote(command)}") != 0:
        sys.exit(1)
