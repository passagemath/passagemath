# PEP 517 builds do not have . in sys.path
import os
import sys
sys.path.insert(0, os.path.dirname(__file__))

from sage_setup import sage_setup
from sage_setup.command.sage_install import sage_develop, sage_install

import sage.env
import sage.ext_data
sage.env.SAGE_EXTCODE = os.path.join(os.path.dirname(__file__),
                                     'sage', 'ext_data')

sage_setup(
    ['sagemath-repl'],
    cmdclass={
        "develop":   sage_develop,
        "install":   sage_install,
    },
    package_data={
        "sage.doctest": ["tests/*"],
        "sage.ext_data": ["notebook-ipython/*"],
        "sage.repl.rich_output": ["example*"],
    }
)
