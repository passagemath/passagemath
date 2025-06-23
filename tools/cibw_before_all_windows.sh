#! /bin/sh
set -ex
pwd
echo > constraints.txt
PREFIX=$HOME/sage-local
./configure --enable-build-as-root --prefix=$PREFIX --with-sage-venv --with-system-gfortran=force --with-system-python3=force --without-system-libpng
MAKE="make -j6" make V=0 $TARGETS_PRE
