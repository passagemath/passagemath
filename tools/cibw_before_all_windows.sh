#! /bin/sh
set -ex
pwd
echo > constraints.txt
PREFIX=$(pwd)/sage-local
rm -rf sage-local/lib64  # avoid 'lib64 is not a symlink, see Issue #19782'
if [ -x ./config.status ]; then
    ./config.status
else
    ./configure --enable-build-as-root --enable-fat-binary --prefix=$PREFIX --with-sage-venv --with-system-gfortran=force --with-system-python3=force --without-system-libpng
fi
MAKE="make -j6" make V=0 $TARGETS_PRE
