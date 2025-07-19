import argparse
import subprocess
import os

# To Parse input arguments
def parse_args():
    parser = argparse.ArgumentParser(description="Fetch and format Sage package information.")
    parser.add_argument('pkg_base', help="Package base name")
    parser.add_argument('--output_dir', help="Directory for output files", default=None)
    parser.add_argument('--output_rst', action='store_true', help="Output in reStructuredText format")
    return parser.parse_args()

args = parse_args()
# DEBUG: To Print the parsed arguments for debugging (This is for development purpose, please delete if not neeeded)
print(f"Package base: {args.pkg_base}")
print(f"Output directory: {args.output_dir}")
print(f"Output in reST format: {args.output_rst}")

PKG_BASE = args.pkg_base
OUTPUT_DIR = args.output_dir
OUTPUT_RST = args.output_rst
# To Redirect output to file if OUTPUT_DIR is set
if OUTPUT_DIR:
    output_file = os.path.join(OUTPUT_DIR, f"{PKG_BASE}.rst")
    output = open(output_file, 'w')
else:
    output = None

# To Determine output format
if OUTPUT_RST:
    def ref(x): return f":ref:`{x}`"
    def spkg(x): return ref(f"spkg_{x}")
    def issue(x): return f":issue:`{x}`"
    def code(*args): return f"``{' '.join(args)}``"
    def tab(x): return f".. tab:: {x}"
    FORMAT = 'rst'
else:
    def ref(x): return x
    def spkg(x): return x
    def issue(x): return f"https://github.com/sagemath/sage/issues/{x}"
    def code(x): return x
    def tab(x): return f"{x}:"
    FORMAT = 'plain'
def get_package_properties(pkg_base):
    try:
        result = subprocess.run(
            ['sage-package', 'properties', '--format=shell', pkg_base],
            capture_output=True, text=True, check=True
        )
        props = result.stdout
        print(f"Package properties: {props}")  # DEBUG: Debugging line
        exec(props)  # Execute the properties to define variables like PKG_SCRIPTS
        return props
    except subprocess.CalledProcessError:
        print(f"Error: Unknown package {pkg_base}")
        exit(1)

props = get_package_properties(PKG_BASE)
# I need to execute the properties (similar to eval in shell script)
exec(props)
# After evaluating the properties, to extract the correct path
PKG_SCRIPTS = globals().get(f'path_{PKG_BASE}', None)
# DEBUG: 
if PKG_SCRIPTS is None:
    print(f"Error: PKG_SCRIPTS is not defined for package {PKG_BASE}")
    exit(1)

# To "sed" on the SPKG.rst to tweak (README) file
def process_spkg_file(pkg_base, spkg_scripts):
    spkg_file = os.path.join(spkg_scripts, "SPKG.rst")
    if os.path.isfile(spkg_file):
        with open(spkg_file, 'r') as file:
            content = file.read()

        # Replace links with reST format
        content = content.replace(
            "https://github.com/sagemath/sage/issues/",
            ":issue:`"
        ).replace(
            "https://arxiv.org/abs/cs/", ":arxiv:`cs/"
        )
        content = content.replace("====", "==============")
        print(content)
    
process_spkg_file(PKG_BASE, PKG_SCRIPTS)

def display_dependencies(pkg_base, format_type):
    result = subprocess.run(
        ['sage-package', 'dependencies', '--format=' + format_type, pkg_base],
        capture_output=True, text=True
    )
    print("Dependencies")
    print("------------")
    print(result.stdout)

def display_version_info(pkg_base):
    result = subprocess.run(
        ['sage-get-system-packages', 'versions', pkg_base],
        capture_output=True, text=True
    )
    print("Version Information")
    print("-------------------")
    print(result.stdout)

display_dependencies(PKG_BASE, FORMAT)
display_version_info(PKG_BASE)

# To build the “Equivalent System Packages” section of the original shell script.
def handle_system_packages(pkg_base, pkg_scripts):
    PKG_DISTROS = os.path.join(pkg_scripts, "distros")
    systems = []
    have_repology = False

    for system_package_file in os.listdir(PKG_DISTROS):
        system = os.path.splitext(system_package_file)[0]
        # Don't include repology file.
        if system == "repology":
            have_repology = True
        # Incdlue orther system name to the list.
        else:
            systems.append(system)

    for system in systems:
        system_package_file = os.path.join(PKG_DISTROS, f"{system}.txt")
        with open(system_package_file, 'r') as file:
            system_packages = file.read().strip()

        if system_packages:
            print(tab(system))
            print(f"sudo install {system_packages}")
        else:
            print(f"{tab(system)} No package needed.")
    
    if have_repology:
        print(tab("repology"))


handle_system_packages(PKG_BASE, PKG_SCRIPTS)
# To look for the package’s spkg-configure.m4 file and prints a brief message telling the user how (if) ./configure can use a pre-installed system version of the package.
def handle_configuration(pkg_base, pkg_scripts):
    spkg_configure_file = os.path.join(pkg_scripts, "spkg-configure.m4")
    if os.path.isfile(spkg_configure_file):
        with open(spkg_configure_file, 'r') as file:
            content = file.read()

        if "SAGE_PYTHON_PACKAGE_CHECK" in content:
            print("If the system package is installed, use --enable-system-site-packages to check compatibility.")
        else:
            print("If the system package is installed, ./configure will check if it can be used.")
    else:
        print("No configuration file found for this package.")

handle_configuration(PKG_BASE, PKG_SCRIPTS)
# If OUTPUT_DIR is set, close the output file
if OUTPUT_DIR:
    output.close()
