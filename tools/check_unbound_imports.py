#!/usr/bin/env python3
"""
AST checker to catch a specific class of NameError bugs:
`except ImportError: pass` (or bare except) where the caught imported name
is used downstream unconditionally within the same scope.

Usage:
    python3 tools/check_unbound_imports.py <directory_or_file> [...]
"""

import ast
import sys
import argparse
from pathlib import Path


def is_control_flow_terminator(node):
    return isinstance(node, (ast.Return, ast.Raise, ast.Continue, ast.Break))


def has_terminator(body):
    for stmt in body:
        if is_control_flow_terminator(stmt):
            return True
    return False


def get_assigned_names(node):
    """
    Collect all names bound within a node (except handler body).

    Recognises:
      - plain assignment:  x = ...
      - tuple unpack:      x, y = ...
      - function def:      def x(...): ...
      - async function:    async def x(...): ...
      - class def:         class X: ...
      - import alias:      import mod as x  /  from mod import name as x
    """
    names = set()
    for stmt in ast.walk(node):
        if isinstance(stmt, ast.Assign):
            for target in stmt.targets:
                if isinstance(target, ast.Name):
                    names.add(target.id)
                elif isinstance(target, ast.Tuple):
                    for elt in target.elts:
                        if isinstance(elt, ast.Name):
                            names.add(elt.id)
        elif isinstance(stmt, (ast.FunctionDef, ast.AsyncFunctionDef, ast.ClassDef)):
            names.add(stmt.name)
        elif isinstance(stmt, ast.Import):
            for alias in stmt.names:
                names.add(alias.asname or alias.name.split('.')[0])
        elif isinstance(stmt, ast.ImportFrom):
            for alias in stmt.names:
                names.add(alias.asname or alias.name)
    return names


def get_enclosing_scope(tree, target_node):
    """Find the innermost FunctionDef, AsyncFunctionDef, ClassDef, or Module
    that contains target_node."""
    parent_map = {}
    for node in ast.walk(tree):
        for child in ast.iter_child_nodes(node):
            parent_map[child] = node

    current = target_node
    while current in parent_map:
        current = parent_map[current]
        if isinstance(current, (ast.FunctionDef, ast.AsyncFunctionDef,
                                ast.ClassDef, ast.Module)):
            return current
    return tree


def _collect_try_imports(try_node):
    """Return the set of names imported in try_node's body."""
    names = set()
    for stmt in try_node.body:
        for subnode in ast.walk(stmt):
            if isinstance(subnode, ast.Import):
                for alias in subnode.names:
                    names.add(alias.asname or alias.name.split('.')[0])
            elif isinstance(subnode, ast.ImportFrom):
                for alias in subnode.names:
                    names.add(alias.asname or alias.name)
    return names


def _node_ids(stmts):
    """Return the set of id() values for all AST nodes in stmts."""
    ids = set()
    for stmt in stmts:
        for subnode in ast.walk(stmt):
            ids.add(id(subnode))
    return ids


def check_file(filepath):
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()
        tree = ast.parse(content, filename=str(filepath))
    except Exception:
        return []

    issues = []

    for node in ast.walk(tree):
        if not isinstance(node, ast.Try):
            continue

        # Determine whether this try has an ImportError (or bare) handler
        # that does NOT unconditionally terminate.
        has_import_error_handler = False
        terminates = False
        for handler in node.handlers:
            if handler.type is None:
                has_import_error_handler = True
                if has_terminator(handler.body):
                    terminates = True
            elif isinstance(handler.type, ast.Name) and handler.type.id == 'ImportError':
                has_import_error_handler = True
                if has_terminator(handler.body):
                    terminates = True
            elif isinstance(handler.type, ast.Tuple):
                for elt in handler.type.elts:
                    if isinstance(elt, ast.Name) and elt.id == 'ImportError':
                        has_import_error_handler = True
                        if has_terminator(handler.body):
                            terminates = True

        if not has_import_error_handler or terminates:
            continue

        imported_names = _collect_try_imports(node)

        # Names bound in the except block(s) are not unbound.
        assigned_names = set()
        for handler in node.handlers:
            assigned_names.update(get_assigned_names(handler))

        unbound = imported_names - assigned_names
        if not unbound:
            continue

        # Safe zones for the current try:
        # - the try body itself
        # - the else (orelse) clause — only reached when try succeeded
        # - every except handler body
        safe_nodes = _node_ids(node.body + node.orelse)
        for handler in node.handlers:
            safe_nodes.update(_node_ids(handler.body))

        scope = get_enclosing_scope(tree, node)

        for name in unbound:
            # Also mark as safe any node that lives inside the body/orelse/
            # handlers of OTHER try blocks in the same scope that also import
            # this name.  This avoids false positives when the same optional
            # module is imported in multiple separate try/else blocks within one
            # function (e.g. matrix_space.py imports SR twice).
            extended_safe = set(safe_nodes)
            for other in ast.walk(scope):
                if isinstance(other, ast.Try) and other is not node:
                    if name in _collect_try_imports(other):
                        extended_safe.update(_node_ids(other.body + other.orelse))
                        for h in other.handlers:
                            extended_safe.update(_node_ids(h.body))

            usages = [
                n for n in ast.walk(scope)
                if isinstance(n, ast.Name)
                and n.id == name
                and isinstance(n.ctx, ast.Load)
                and id(n) not in extended_safe
            ]

            if usages:
                issues.append((name, node.lineno, len(usages)))

    return issues


def main():
    parser = argparse.ArgumentParser(
        description="Check for potentially unbound imports after failed try/except.")
    parser.add_argument("paths", nargs="+", type=Path,
                        help="Files or directories to check")
    args = parser.parse_args()

    found_issues = False

    for path in args.paths:
        if path.is_file() and path.suffix == '.py':
            files = [path]
        elif path.is_dir():
            files = path.rglob('*.py')
        else:
            continue

        for py_file in files:
            issues = check_file(py_file)
            if issues:
                found_issues = True
                print(f"{py_file}:")
                for name, lineno, count in issues:
                    print(f"  - Unbound usage of '{name}' "
                          f"(imported at line {lineno}, used {count} time(s))")

    sys.exit(1 if found_issues else 0)


if __name__ == '__main__':
    main()
