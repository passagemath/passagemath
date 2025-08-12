#!/usr/bin/env python

from glob import glob
from pathlib import Path
import shutil

# PEP 517 builds do not have . in sys.path
import os
import sys
sys.path.insert(0, os.path.dirname(__file__))

from sage_setup import sage_setup
from distutils.command.install import install
from setuptools.command.develop import develop


# xeus-gp

class install_kernel_spec_mixin:

    def install_kernel_spec(self):
        """
        Install the Jupyter kernel spec.

        .. NOTE::

            The files are generated, not copied. Therefore, we cannot
            use ``data_files`` for this.
        """
        from sage.env import SAGE_LOCAL

        if SAGE_LOCAL:
            spec_src = Path(SAGE_LOCAL) / "share" / "jupyter" / "kernels" / "xeus-gp"
            if spec_src.exists():
                spec_dst = Path(self.install_data) / "share" / "jupyter" / "kernels" / "xeus-gp"
                spec_dst.mkdir(parents=True, exist_ok=True)
                shutil.copytree(spec_src, spec_dst, dirs_exist_ok=True)


class sage_install(install, install_kernel_spec_mixin):

    def run(self):
        install.run(self)
        self.install_kernel_spec()


class sage_develop(develop, install_kernel_spec_mixin):

    def run(self):
        develop.run(self)
        if not self.uninstall:
            self.install_kernel_spec()


# pari-jupyter
kernelpath = os.path.join("share", "jupyter", "kernels", "pari_jupyter")
nbextpath = os.path.join("share", "jupyter", "nbextensions", "gp-mode")
nbconfpath = os.path.join("etc", "jupyter", "nbconfig", "notebook.d")


if not (len(sys.argv) > 1 and (sys.argv[1] in ["sdist", "egg_info", "dist_info"])):
    from autogen import rebuild
    rebuild()


sage_setup(['sagemath-pari'],
           cmdclass={
               "develop":   sage_develop,
               "install":   sage_install,
           },
           required_modules=('gsl', 'givaro'),
           optional_modules=('readline',),
           spkgs=['pari', 'gsl', 'givaro'],
           recurse_packages=[
               'sage',
               'cypari2',
               'PARIKernel',
            ],
           package_data={"sage": [
               "ext_data/pari/**",
            ],
            'cypari2': [
                'declinl.pxi',
                '*.pxd',
                '*.h'
            ]},
           data_files=[
               (kernelpath, glob("pari-jupyter/spec/*")),
               (nbextpath, glob("pari-jupyter/gp-mode/*")),
               (nbconfpath, ["pari-jupyter/gp-mode.json"]),
           ])
