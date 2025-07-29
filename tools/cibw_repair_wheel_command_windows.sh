#! /bin/sh
wheel=$1
dest_dir=$2

set -ex
pkg=$(basename ${wheel})
pkg=${pkg%%-*}
pkg=${pkg//_/-}
pkg=${pkg#pas}
if [ -r pkgs/$pkg/repair_wheel.py ]; then
    python3 pkgs/$pkg/repair_wheel.py ${wheel}
fi
delvewheel repair -vv --custom-patch -w ${dest_dir} ${wheel}
