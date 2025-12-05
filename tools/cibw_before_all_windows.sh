#! /bin/sh
set -ex
pwd
echo > constraints.txt
PREFIX=$(pwd)/sage-local
rm -rf sage-local/lib64  # avoid 'lib64 is not a symlink, see Issue #19782'
export MSYS=winsymlinks:nativestrict
if [ -x ./config.status ]; then
    ./config.status
else
    rm -f config.log
    mkdir -p logs/pkgs
    touch logs/pkgs/config.log
    ln -s logs/pkgs/config.log config.log
    ./configure --enable-build-as-root --enable-fat-binary --prefix=$PREFIX --with-sage-venv --with-system-gfortran=force --with-system-python3=force --disable-python-distutils-check --without-system-gmp --without-system-gsl --without-system-mpfr --without-system-mpc --without-system-boost_cropped --without-system-libpng --without-system-zlib
fi
MAKE="make -j6" make -k V=0 $TARGETS_PRE || echo "Ignoring error"
