import sys

from setuptools import setup


package_data = {
    'sage_root': ['.upstream.d/*']
}


if not (len(sys.argv) > 1 and (sys.argv[1] in ["sdist", "egg_info", "dist_info"])):
    package_data['sage_root'].append('build/pkgs/**')


setup(package_data=package_data)
