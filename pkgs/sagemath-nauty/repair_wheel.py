# Add Maxima data to the wheel

import os
import shlex
import sys

from pathlib import Path

from sage_conf import SAGE_LOCAL

wheel = sys.argv[1]

# SAGE_LOCAL/bin/* --> sage_wheels/bin/*
# list of files from build/pkgs/nauty/spkg-install.in
command = f'ln -sf {shlex.quote(SAGE_LOCAL)} sage_wheels && zip -r {shlex.quote(wheel)} sage_wheels/bin/{{addedgeg,addptg,amtog,ancestorg,assembleg,biplabg,catg,complg,converseg,copyg,countg,countneg,cubhamg,deledgeg,delptg,dimacs2g,directg,dreadnaut,dretodot,dretog,edgetransg,genbg,genbgL,geng,gengL,genposetg,genquarticg,genrang,genspecialg,gentourng,gentreeg,genktreeg,hamheuristic,labelg,linegraphg,listg,multig,nbrhoodg,newedgeg,pickg,planarg,productg,ranlabg,ransubg,shortg,showg,subdivideg,twohamg,underlyingg,uniqg,vcolg,watercluster2,NRswitchg}}'
print(f'Running {command}')
sys.stdout.flush()
os.system(command)
