
"""
Python rewrite of `build/bin/sage-spkg-info` with suggestions applied:
  - Rewrote actually most of the original script because 
  - Utilizes Python's logging (instead of print) for debug/info.
    - Re-use/initialize logging via sage_bootstrap if available.
  - Call `sage-print-system-package-command` instead of writing sudo lines.

NOTE: Many functions presume Sage's bootstrap helpers are in PATH (e.g. `sage-package`).
      Could try to Adjust `SAGE_ROOT`, PATH, or run from within bootstrap like within the original script.

Could try the following invoking method:
cd ~/passagemath (SAGE_ROOT)
export SAGE_ROOT="$PWD"
export PATH="$PWD/build/bin:$PATH"
python3 build/bin/sage-spkg-info.py 4ti2 --output-rst --log-level INFO
"""
#!/usr/bin/env python3
from __future__ import annotations
from functools import cached_property
import sys
from pathlib import Path

# Make .../build importable so `import sage_bootstrap` works
BUILD_DIR = Path(__file__).resolve().parents[1]  # .../build
sys.path.insert(0, str(BUILD_DIR))

# To emulate the env the shell script sets up
import os
os.environ.setdefault("SAGE_ROOT", str(BUILD_DIR.parent))  # .../passagemath
os.environ["PATH"] = f"{(BUILD_DIR / 'bin')}:{os.environ.get('PATH', '')}"

import argparse
import logging
import re
import shlex
import subprocess
from typing import Dict, Iterable, Optional

from sage_bootstrap.package import Package


SYSTEM_NAME_MAP = {
    "alpine": "Alpine",
    "arch": "Arch Linux",
    "conda": "conda-forge",
    "debian": "Debian/Ubuntu",
    "fedora": "Fedora/Redhat/CentOS",
    "freebsd": "FreeBSD",
    "gentoo": "Gentoo Linux",
    "homebrew": "Homebrew",
    "macports": "MacPorts",
    "mingw": "mingw-w64",
    "nix": "Nixpkgs",
    "openbsd": "OpenBSD",
    "opensuse": "openSUSE",
    "slackware": "Slackware",
    "void": "Void Linux",
}
# This is to map system names to display names 
def _strip_comments_and_collapse(path: Path) -> str:
    """Mimic `sed 's/#.*//'` + whitespace collapsing from the bash script."""
    txt = path.read_text(encoding="utf-8")
    txt = re.sub(r"#.*", "", txt)
    return " ".join(txt.split()).strip()

# Logging
try:  # pragma: no cover - to choose optional path
    import sage_bootstrap.logging as _sb_logging  # noqa: F401
except Exception:  # pragma: no cover - to ignore if not available
    pass

logger = logging.getLogger("sage-spkg-info")
if not logger.handlers:  # To go back to basic config if none set by sage_bootstrap
    logging.basicConfig(level=logging.INFO, format="%(levelname)s: %(message)s")

# CLI: To parse arguments (Rewrite version)
def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Fetch and format Sage package information (Python rewrite)."
    )
    parser.add_argument(
        "packages",
        nargs="+",
        help="One or more package base names (separate by space) (e.g. 4ti2 pari ntl)",
    )
    parser.add_argument(
        "--output-dir", dest="output_dir", default=None,
        help="Directory to write the formatted output (default: stdout)",
    )
    parser.add_argument(
        "--output-rst", dest="output_rst", action="store_true",
        help="Emit reStructuredText markup instead of plain text",
    )
    parser.add_argument(
        "--log-level", dest="log_level", default="WARNING",
        choices=["CRITICAL", "ERROR", "WARNING", "INFO", "DEBUG"],
        help="Set logging verbosity (default: WARNING)",
    )
    return parser.parse_args()


# To run the Helpers

def run(cmd: Iterable[str], *, check: bool = True, text: bool = True) -> subprocess.CompletedProcess:
    # To Run the subprocess and log on DEBUG.
    logger.debug("Running command: %s", " ".join(map(shlex.quote, cmd)))
    return subprocess.run(cmd, capture_output=True, text=text, check=check)


def parse_shell_assignments(shell_text: str) -> Dict[str, str]:
    # To Parse lines like `VAR=value` that come from `--format=shell`.
    # For simplification purposes, I decided to ignore export, quoting, and command substitutions beyond simple cases.
    # lines that do not match VAR=... are skipped.
    env: Dict[str, str] = {}
    assignment_re = re.compile(r"^(?:export\s+)?([A-Za-z_][A-Za-z0-9_]*)=(.*)$")
    for line in shell_text.splitlines():
        m = assignment_re.match(line.strip())
        if not m:
            continue
        key, val = m.groups()
        # To strip surrounding quotes if present.
        val = val.strip()
        if (val.startswith("'") and val.endswith("'")) or (val.startswith('"') and val.endswith('"')):
            val = val[1:-1]
        env[key] = val
    return env


# For the purpose of better looking, Output formatting helpers 
class Formatter:
    def __init__(self, rst: bool):
        self.rst = rst

    def ref(self, x: str) -> str:
        return f":ref:`{x}`" if self.rst else x

    def spkg(self, x: str) -> str:
        return self.ref(f"spkg_{x}") if self.rst else x

    def issue(self, x: str) -> str:
        return f":issue:`{x}`" if self.rst else f"https://github.com/sagemath/sage/issues/{x}"

    def code(self, *args: str) -> str:
        if self.rst:
            return f"``{' '.join(args)}``"
        return " ".join(args)

    def tab(self, x: str) -> str:
        return f".. tab:: {x}" if self.rst else f"{x}:"


# Core functionality

# To Return dict of properties from `sage-package properties --format=shell`.
def get_package_properties(pkg_base: str) -> Dict[str, str]:    
    try:
        result = run(["sage-package", "properties", "--format=shell", pkg_base])
    except subprocess.CalledProcessError as e:
        logger.error("Unknown package %s (exit %s): %s", pkg_base, e.returncode, e.stderr.strip())
        raise SystemExit(1)

    props_text = result.stdout
    logger.debug("Raw properties for %s:\n%s", pkg_base, props_text)
    props = parse_shell_assignments(props_text)
    return props

# To Read and post-process SPKG.rst (README).
def process_spkg_file(pkg_base: str, pkg_scripts: Path, fmt: Formatter, out) -> None:
    spkg_file = pkg_scripts / "SPKG.rst"
    if not spkg_file.is_file():
        logger.info("No SPKG.rst for %s", pkg_base)
        return

    content = spkg_file.read_text(encoding="utf-8")

    # To replace emulating sed tweaks in original script (hopefully this works)
    content = content.replace("https://github.com/sagemath/sage/issues/", ":issue:`")
    content = content.replace("https://arxiv.org/abs/cs/", ":arxiv:`cs/")
    # To Ensure underline length (example from original sed).（ This is heuristic.）
    content = content.replace("====", "==============")

    print(content, file=out)


def display_dependencies(pkg_base: str, fmt: Formatter, out) -> None:
    try:
        result = run(["sage-package", "dependencies", f"--format={'rst' if fmt.rst else 'plain'}", pkg_base], check=True)
    except subprocess.CalledProcessError as e:
        logger.warning("Could not get dependencies for %s: %s", pkg_base, e.stderr.strip())
        return

    print("Dependencies", file=out)
    print("------------", file=out)
    print(result.stdout.strip(), file=out)


def display_version_info(pkg_base: str, out) -> None:
    try:
        result = run(["sage-get-system-packages", "versions", pkg_base], check=True)
    except subprocess.CalledProcessError as e:
        logger.warning("Could not get version info for %s: %s", pkg_base, e.stderr.strip())
        return

    print("Version Information", file=out)
    print("-------------------", file=out)
    print(result.stdout.strip(), file=out)

# To Build the "Equivalent System Packages" section and Use sage-print-system-package-command.
def handle_system_packages(pkg_base: str, pkg_scripts: Path, fmt: Formatter, out) -> None:
    distros_dir = pkg_scripts / "distros"
    if not distros_dir.is_dir():
        logger.info("No distros directory for %s", pkg_base)
        print("(none known)", file=out)
        return

    systems: list[str] = []
    have_repology = False
    for entry in sorted(distros_dir.glob("*.txt")):
        name = entry.stem
        if name == "repology":
            have_repology = True
        else:
            systems.append(name)

    if not systems and not have_repology:
        print("Equivalent System Packages", file=out)
        print("--------------------------", file=out)
        print("(none known)", file=out)
        return

    print("Equivalent System Packages", file=out)
    print("--------------------------", file=out)

    # To Match bash script's indentation behavior
    rst_indent = "   " if fmt.rst else ""

    for system in systems:
        system_file = distros_dir / f"{system}.txt"
        sys_pkgs = _strip_comments_and_collapse(system_file)

        tab_name = SYSTEM_NAME_MAP.get(system, system)
        print(fmt.tab(tab_name), file=out)

        if sys_pkgs:
            args = [
                "sage-print-system-package-command",
                system,
                "--wrap",
                f"--prompt={rst_indent}    $ ",
                f"--continuation={rst_indent}          ",
                "--sudo",
                "install",
            ] + sys_pkgs.split()
            try:
                cp = run(args)
                print(cp.stdout.rstrip(), file=out)
            except subprocess.CalledProcessError as e:
                logger.warning("Failed to get system package command for %s on %s: %s",
                               pkg_base, system, e.stderr.strip())
                print(f"{rst_indent}No package needed.", file=out)
        else:
            print(f"{rst_indent}No package needed.", file=out)
        print("", file=out)

    if have_repology:
        # To show bekiw the tabs, like the shell script
        repology_file = distros_dir / "repology.txt"
        sys_pkgs = _strip_comments_and_collapse(repology_file)
        try:
            cp = run([
                "sage-print-system-package-command", "repology",
                "--wrap", "--prompt=    $ ", "--continuation=          ",
                "--sudo", "install",
            ] + sys_pkgs.split())
            print(cp.stdout.rstrip(), file=out)
        except subprocess.CalledProcessError as e:
            logger.warning("repology cmd failed: %s", e.stderr.strip())

# To print message about spkg-configure.m4. Optionally: expose as @property later.
def handle_configuration(pkg_base: str, pkg_scripts: Path, fmt: Formatter, out) -> None:
    print("", file=out)
    pkg = Package(pkg_base)   # or to change to Package.from_base(pkg_base), depending on types of API
    if pkg.has_spkg_configure:
        if pkg.uses_python_package_check:
            print("If the system package is installed and if the (experimental) option", file=out)
            print(f"{fmt.code('--enable-system-site-packages')} is passed to {fmt.code('./configure')}, "
                  f"then {fmt.code('./configure')} will check if the system package can be used.", file=out)
        else:
            print(f"If the system package is installed, {fmt.code('./configure')} will check if it can be used.",
                  file=out)
    else:
        if not pkg_base.startswith("_"):
            print("However, these system packages will not be used for building Sage", file=out)
            print(f"because {fmt.code('spkg-configure.m4')} has not been written for this package;", file=out)
            print(f"see {fmt.issue('27330')} for more information.", file=out)

# To Emit info for multiple packages.
def emit_for_package(pkg_base: str, fmt: Formatter, out_dir: Optional[Path]) -> None:
    props = get_package_properties(pkg_base)

    pkg_scripts_str = props.get("PKG_SCRIPTS") or props.get(f"path_{pkg_base}")
    if not pkg_scripts_str:
        logger.error("Cannot determine PKG_SCRIPTS/path_%s from properties.", pkg_base)
        raise SystemExit(1)
    pkg_scripts = Path(pkg_scripts_str)

    if out_dir:
        out_dir.mkdir(parents=True, exist_ok=True)
        target = out_dir / (f"{pkg_base}.rst" if fmt.rst else f"{pkg_base}.txt")
        with target.open("w", encoding="utf-8") as out:
            logger.info("Writing output to %s", target)
            if fmt.rst:
                print(f".. _spkg_{pkg_base}:\n", file=out)
            process_spkg_file(pkg_base, pkg_scripts, fmt, out)
            display_dependencies(pkg_base, fmt, out)
            display_version_info(pkg_base, out)
            handle_system_packages(pkg_base, pkg_scripts, fmt, out)
            handle_configuration(pkg_base, pkg_scripts, fmt, out)
    else:
        out = os.sys.stdout
        if fmt.rst:
            print(f".. _spkg_{pkg_base}:\n", file=out)
        process_spkg_file(pkg_base, pkg_scripts, fmt, out)
        display_dependencies(pkg_base, fmt, out)
        display_version_info(pkg_base, out)
        handle_system_packages(pkg_base, pkg_scripts, fmt, out)
        handle_configuration(pkg_base, pkg_scripts, fmt, out)

# Main

def main() -> None:
    args = parse_args()
    logging.getLogger().setLevel(getattr(logging, args.log_level))
    logger.debug("Arguments: %s", args)

    fmt = Formatter(rst=args.output_rst)
    out_dir = Path(args.output_dir) if args.output_dir else None

    for i, pkg_base in enumerate(args.packages):
        # Nice visual separator when writing to stdout
        if not out_dir and i > 0:
            print("\n" + "-" * 79 + "\n")
        emit_for_package(pkg_base, fmt, out_dir)

if __name__ == "__main__":
    main()
