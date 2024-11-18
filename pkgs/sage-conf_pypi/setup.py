import os
import sys
import shutil
import sysconfig
import platform
import fnmatch

from setuptools import setup
from setuptools.dist import Distribution
from distutils.command.build_scripts import build_scripts as distutils_build_scripts
from setuptools.command.build_py import build_py as setuptools_build_py
from setuptools.command.editable_wheel import editable_wheel as setuptools_editable_wheel
from setuptools.errors import SetupError


# setuptools plugins considered harmful:
# If build isolation is not in use and setuptools_scm is installed,
# then its file_finders entry point is invoked, which we don't need.
# And with setuptools_scm 8, we get more trouble:
# LookupError: pyproject.toml does not contain a tool.setuptools_scm section
# LookupError: setuptools-scm was unable to detect version ...
# We just remove all handling of "setuptools.finalize_distribution_options" entry points.
Distribution._removed = staticmethod(lambda ep: True)


class build_py(setuptools_build_py):

    def run(self):

        HERE = os.path.dirname(__file__)

        SAGE_CONF_FILE = os.environ.get('SAGE_CONF_FILE', None)
        SAGE_CONF_ENV_FILE = os.environ.get('SAGE_CONF_ENV_FILE', None)

        if SAGE_CONF_FILE or SAGE_CONF_ENV_FILE:
            try:
                shutil.copyfile(SAGE_CONF_FILE or '/dev/null',
                                os.path.join(HERE, '_sage_conf', '_conf.py'))
            except OSError:
                raise SetupError(f"environment variable SAGE_CONF_FILE is set to {SAGE_CONF_FILE}, "
                                 f"but the file cannot be copied")
            if SAGE_CONF_ENV_FILE and SAGE_CONF_ENV_FILE != '/dev/null':
                try:
                    shutil.copyfile(SAGE_CONF_ENV_FILE or '/dev/null',
                                    os.path.join(HERE, 'bin', 'sage-env-config'))
                except OSError:
                    raise SetupError(f"environment variable SAGE_CONF_ENV_FILE is set to {SAGE_CONF_ENV_FILE}, "
                                     f"but the file cannot be copied")
            else:
                # Remove possible leftover file
                try:
                    os.remove(os.path.join(HERE, 'bin', 'sage-env-config'))
                except OSError:
                    pass
            SAGE_ROOT = None
        elif self.editable_mode:
            SAGE_ROOT = os.path.join(HERE, 'sage_root')
        else:
            SAGE_ROOT = self._create_writable_sage_root()

        if SAGE_ROOT:
            # For convenience, set up the homebrew env automatically. This is a no-op if homebrew is not present.
            if os.environ.get('CONDA_PREFIX', ''):
                SETENV = ':'
            else:
                SETENV = '. ./.homebrew-build-env 2> /dev/null'

            SAGE_LOCAL = os.path.join(SAGE_ROOT, 'local')

            if os.path.exists(os.path.join(SAGE_ROOT, 'config.status')):
                print(f'Reusing configured SAGE_ROOT={SAGE_ROOT}')
            else:
                SAGE_CONF_CONFIGURE_ARGS = os.environ.get('SAGE_CONF_CONFIGURE_ARGS', '')
                cmd = f"cd {SAGE_ROOT} && ({SETENV}; ./configure --prefix={SAGE_LOCAL} --with-python={sys.executable} --enable-build-as-root --enable-download-from-upstream-url --with-system-python3=force --with-sage-venv --disable-notebook --disable-sagelib --disable-sage_conf --disable-doc {SAGE_CONF_CONFIGURE_ARGS})"
                print(f"Running {cmd}")
                sys.stdout.flush()
                if os.system(cmd) != 0:
                    print(f"configure failed; this may be caused by missing build prerequisites.")
                    sys.stdout.flush()
                    PREREQ_SPKG = "_prereq bzip2 xz libffi"  # includes python3 SPKG_DEPCHECK packages
                    os.system(f'cd {SAGE_ROOT} && export SYSTEM=$(build/bin/sage-guess-package-system 2>/dev/null) && export PACKAGES="$(build/bin/sage-get-system-packages $SYSTEM {PREREQ_SPKG})" && [ -n "$PACKAGES" ] && echo "You can install the required build prerequisites using the following shell command" && echo "" && build/bin/sage-print-system-package-command $SYSTEM --verbose --sudo install $PACKAGES && echo ""')
                    raise SetupError("configure failed")

            # Copy over files generated by the configure script
            # (see configure.ac AC_CONFIG_FILES)
            if self.editable_mode:
                pass  # same file
            else:
                shutil.copyfile(os.path.join(SAGE_ROOT, 'pkgs', 'sage-conf', '_sage_conf', '_conf.py'),
                                os.path.join(HERE, '_sage_conf', '_conf.py'))
            shutil.copyfile(os.path.join(SAGE_ROOT, 'src', 'bin', 'sage-env-config'),
                            os.path.join(HERE, 'bin', 'sage-env-config'))

            # Here we run "make base-toolchain"
            # Alternatives:
            # - "make build" -- which builds everything except for sagelib because we
            #   used configure --disable-sagelib
            # - "make build-local" only builds the non-Python packages of the Sage distribution.
            #   It still makes an (empty) venv in SAGE_VENV, which is unused by default;
            #   but then a user could use "make build-venv" to build compatible wheels for all Python packages.
            # - TODO: A target to only build wheels of tricky packages
            #   (that use native libraries shared with other packages).
            SETMAKE = 'if [ -z "$MAKE" ]; then export MAKE="make -j$(PATH=build/bin:$PATH build/bin/sage-build-num-threads | cut -d" " -f 2)"; fi'
            TARGETS = 'base'
            cmd = f'cd {SAGE_ROOT} && ({SETENV}; {SETMAKE} && $MAKE V=0 ${{SAGE_CONF_TARGETS-{TARGETS}}})'
            print(f"Running {cmd}", flush=True)
            if os.system(cmd) != 0:
                raise SetupError(f"make ${{SAGE_CONF_TARGETS-{TARGETS}}} failed")

        setuptools_build_py.run(self)

    def _create_writable_sage_root(self):
        HERE = os.path.dirname(__file__)
        DOT_SAGE = os.environ.get('DOT_SAGE', os.path.join(os.environ.get('HOME'), '.sage'))
        with open(os.path.join(HERE, 'VERSION.txt')) as f:
            sage_version = f.read().strip()
        # After #30534, SAGE_LOCAL no longer contains any Python.  So we key the SAGE_ROOT only to Sage version
        # and architecture.
        system = platform.system()
        machine = platform.machine()
        arch_tag = f'{system}-{machine}'
        # TODO: Should be user-configurable with config settings
        SAGE_ROOT = os.path.join(DOT_SAGE, f'sage-{sage_version}-{arch_tag}')
        UPSTREAM = os.path.join(DOT_SAGE, 'upstream')

        def ignore(path, names):
            # exclude all embedded src trees
            if fnmatch.fnmatch(path, f'*/build/pkgs/*'):
                return ['src']
            ### ignore more stuff --- .tox etc.
            return [name for name in names
                    if name in ('.tox', '.git', '__pycache__',
                                'prefix', 'local', 'venv', 'upstream',
                                'config.status', 'config.log', 'logs')]

        if not os.path.exists(os.path.join(SAGE_ROOT, 'config.status')):
            # config.status and other configure output has to be writable.
            # So (until the Sage distribution supports VPATH builds - #21469), we have to make a copy of sage_root.
            try:
                shutil.copytree('sage_root', SAGE_ROOT,
                                ignore=ignore)  # will fail if already exists
                cmd = f'cd {SAGE_ROOT} && mkdir -p {UPSTREAM} && ln -sf {UPSTREAM} .'
                os.system(cmd)
            except Exception as e:
                raise SetupError(f"the directory SAGE_ROOT={SAGE_ROOT} already exists but it is not configured ({e}). "
                                 "Please either remove it and try again, or install in editable mode (pip install -e).")

        return SAGE_ROOT


class build_scripts(distutils_build_scripts):

    def run(self):
        HERE = os.path.dirname(__file__)

        sage_env_config = os.path.join(HERE, 'bin', 'sage-env-config')
        if os.path.exists(sage_env_config):
            self.distribution.scripts.append(sage_env_config)
        else:
            self.distribution.scripts[:] = [script for script in self.distribution.scripts
                                            if not script.endswith('sage-env-config')]
        if not self.distribution.entry_points:
            self.entry_points = self.distribution.entry_points = dict()
        distutils_build_scripts.run(self)


class editable_wheel(setuptools_editable_wheel):
    r"""
    Customized so that exceptions raised by our build_py
    do not lead to the "Customization incompatible with editable install" message
    """
    _safely_run = setuptools_editable_wheel.run_command


setup(
    cmdclass=dict(build_py=build_py,
                  build_scripts=build_scripts,
                  editable_wheel=editable_wheel)
)
