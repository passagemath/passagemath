
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
from __future__ import annotations

import argparse
import logging
import os
import re
import shlex
import subprocess
from pathlib import Path
from typing import Dict, Iterable, Optional
from sage_bootstrap.package import Package

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
    parser.add_argument("pkg_base", help="Package base name (e.g. 4ti2)")
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
        return

    systems: list[str] = []
    have_repology = False

    for entry in sorted(distros_dir.iterdir()):
        if entry.suffix != ".txt":
            continue
        name = entry.stem
        if name == "repology":
            have_repology = True
        else:
            systems.append(name)

    if systems:
        print("Equivalent System Packages", file=out)
        print("--------------------------", file=out)

# To Run sage-print-system-package-command for this corrected version
    for system in systems:
        try:
            cmd_out = run([
                "sage-print-system-package-command",
                system,
                pkg_base,
            ], check=True).stdout.strip()
        except subprocess.CalledProcessError as e:
            logger.warning("Failed to get system package command for %s on %s: %s", pkg_base, system, e.stderr.strip())
            cmd_out = "(no package needed or unknown)"

        print(fmt.tab(system), file=out)
        print(cmd_out or "(no package needed)", file=out)
        print("", file=out)

    if have_repology:
        print(fmt.tab("repology"), file=out)
        print("(repology badge handled separately)", file=out)

# To print message about spkg-configure.m4. Optionally: expose as @property later.
def handle_configuration(pkg_base: str, pkg_scripts: Path, out) -> None:
    cfg = pkg_scripts / "spkg-configure.m4"
    print("Configuration", file=out)
    print("-------------", file=out)
    if not cfg.is_file():
        print("No configuration file found for this package.", file=out)
        return

    content = cfg.read_text(encoding="utf-8", errors="ignore")
    # Simple heuristic check inspired by correction suggestion. (Added for additional help info).
    uses_python_pkg_check = "SAGE_PYTHON_PACKAGE_CHECK" in content
    if uses_python_pkg_check:
        print("This package uses SAGE_PYTHON_PACKAGE_CHECK; if a system package is installed, use --enable-system-site-packages to check compatibility.", file=out)
    else:
        print("If the system package is installed, ./configure will check whether it can be used.", file=out)


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
# Main

def main() -> None:
    args = parse_args()
    logging.getLogger().setLevel(getattr(logging, args.log_level))
    logger.debug("Arguments: %s", args)

    pkg_base: str = args.pkg_base
    out_path: Optional[Path] = Path(args.output_dir) if args.output_dir else None
    fmt = Formatter(rst=args.output_rst)

    props = get_package_properties(pkg_base)

    # To look for the package’s PKG_SCRIPTS file and prints a brief message telling the user if the path is eligable.
    pkg_scripts_str = props.get("PKG_SCRIPTS") or props.get(f"path_{pkg_base}")
    if not pkg_scripts_str:
        logger.error("Cannot determine PKG_SCRIPTS/path_%s from properties.", pkg_base)
        raise SystemExit(1)
    pkg_scripts = Path(pkg_scripts_str)

    if out_path:
        out_path.mkdir(parents=True, exist_ok=True)
        target = out_path / f"{pkg_base}.rst" if fmt.rst else out_path / f"{pkg_base}.txt"
        out_file = target.open("w", encoding="utf-8")
        logger.info("Writing output to %s", target)
    else:
        out_file = None  

    # To Ensure to always close if opened a file
    try:
        out = out_file or os.sys.stdout

        process_spkg_file(pkg_base, pkg_scripts, fmt, out)
        display_dependencies(pkg_base, fmt, out)
        display_version_info(pkg_base, out)
        handle_system_packages(pkg_base, pkg_scripts, fmt, out)
        handle_configuration(pkg_base, pkg_scripts, out)

    finally:
        if out_file:
            out_file.close()


if __name__ == "__main__":
    main()
