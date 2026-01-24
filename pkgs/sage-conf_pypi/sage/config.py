from _sage_conf._conf import *
from _sage_conf.__main__ import _main


def make(targets):
    import os
    SETENV = ':'
    SETMAKE = 'if [ -z "$MAKE" ]; then export MAKE="make -j$(PATH=build/bin:$PATH build/bin/sage-build-num-threads | cut -d" " -f 2)"; fi'
    cmd = f'cd {SAGE_ROOT} && ({SETENV}; {SETMAKE} && $MAKE V=0 {targets})'
    if os.system(cmd) != 0:
        raise RuntimeError(f"make {targets} failed")


if __name__ == "__main__":
    _main()
