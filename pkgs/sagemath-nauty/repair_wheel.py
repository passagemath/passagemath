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
# list of files from build/pkgs/nauty/spkg-install.in
with InWheel(wheel, wheel):
    command = f'set -o pipefail; (cd {shlex.quote(SAGE_LOCAL)} && tar cf - --dereference bin/{{addedgeg,addptg,amtog,ancestorg,assembleg,biplabg,catg,complg,converseg,copyg,countg,countneg,cubhamg,deledgeg,delptg,dimacs2g,directg,dreadnaut,dretodot,dretog,edgetransg,genbg,genbgL,geng,gengL,genposetg,genquarticg,genrang,genspecialg,gentourng,gentreeg,genktreeg,hamheuristic,labelg,linegraphg,listg,multig,nbrhoodg,newedgeg,pickg,planarg,productg,ranlabg,ransubg,{"shortg," if sys.platform != "win32" else ""}showg,subdivideg,twohamg,underlyingg,uniqg,vcolg,watercluster2,NRswitchg}}) | (mkdir -p sage_wheels && cd sage_wheels && tar xvf -)'
    print(f'Running {command}')
    sys.stdout.flush()
    if os.system(f"bash -c {shlex.quote(command)}") != 0:
        sys.exit(1)
