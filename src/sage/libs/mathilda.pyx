# sage_setup: distribution = sagemath-mathilda
# distutils: libraries = MATHILDA_LIBRARIES
# distutils: extra_compile_args = MATHILDA_CFLAGS
# distutils: include_dirs = MATHILDA_INCDIR
# distutils: library_dirs = MATHILDA_LIBDIR
# distutils: extra_link_args = MATHILDA_LIBEXTRA
# cython: language_level=3
"""
Library interface to the Mathilda computer algebra system

This module links Mathilda's **in-process C API** (``mathilda_ffi.h``) directly
into the interpreter: there is no subprocess, no pipe and no protocol parsing on
our side.  The ``cdef extern`` block below is the one declared by
``sage/libs/mathilda.pyx`` in passagemath (``src/sage/libs/mathilda.pyx`` on
``main`` and the 10.8.x branch); only the Python-level wrapper around it is new.

The extension is linked against ``libmathilda.so.0`` at build time
(``-lmathilda``), so the ten ``mathilda_ffi_*`` entry points are ordinary
dynamic relocations resolved by the loader when the module is imported.  The
library's own dependencies (FLINT, MPFR, GMP, ECM) are resolved through the
process-global scope, which is why the module carries an ``$ORIGIN`` RPATH: the
shared library must sit next to the extension and be found before any other
``libmathilda``.

The C API keeps the kernel's symbol table in global state and the header states
that it is *not reentrant*, so every call here is serialised by a module-wide
recursive lock, and all :class:`Mathilda` objects share one kernel: a name
defined through one handle is visible through every other.  The evaluation runs
with the GIL held, so concurrent Python threads are serialised rather than
parallelised — call from one thread.

The kernel finds its ``internal/`` module tree (``init.m`` and friends) on its
own: a library installed into a prefix resolves the tree relative to it, and for
the ``sage_wheels`` layout ``sage.env`` exports ``MATHILDA_HOME``, which the
library reads.  Nothing here has to point at it.

EXAMPLES::

    sage: from sage.libs.mathilda import Mathilda
    sage: M = Mathilda()
    sage: M.eval("Expand[(x - 1)^3]")
    '-1 + 3 x - 3 x^2 + x^3'
    sage: M.eval("Integrate[Exp[-x^2], {x, -Infinity, Infinity}]")
    'Sqrt[Pi]'
    sage: M.version().startswith("0.")
    True

The kernel is a singleton, so definitions persist::

    sage: M.eval("u = 7")
    '7'
    sage: Mathilda().eval("u + 1")
    '8'

Cells, editor services and the JSON entry point come straight from the C API::

    sage: [e["type"] for e in M.call("Expand[(a + b)^2]")]
    ['line', 'expr', 'done']
    sage: M.json("1/2 + 1/3")["payload"]
    '5/6'
    sage: M.is_complete("Sin[x")
    False
    sage: "Sin" in M.complete("Si")
    True

A parse error raises :class:`MathildaError`::

    sage: M.eval("1+")
    Traceback (most recent call last):
    ...
    MathildaError: Parse error: 1+
"""

import json
import threading

__all__ = ["Mathilda", "MathildaError", "mathilda", "evaluate", "version",
           "is_complete", "complete", "init"]


class MathildaError(RuntimeError):
    """
    Raised when the Mathilda kernel reports a parse error or is unavailable.
    """


# The C API, verbatim from passagemath's src/sage/libs/mathilda.pyx.
cdef extern from "mathilda_ffi.h":

    cdef void mathilda_ffi_init()
    cdef void mathilda_ffi_set_home(const char* dir)
    cdef char* mathilda_ffi_eval(const char* input)
    cdef char* mathilda_ffi_eval_latex(const char* input)
    cdef char* mathilda_ffi_eval_json(const char* input)
    ctypedef void (*mathilda_ffi_sink)(void* ctx, const char* json_line)
    cdef void mathilda_ffi_eval_cell(const char* code, int id,
                                     int cell, mathilda_ffi_sink sink,
                                     void* ctx)
    cdef int mathilda_ffi_is_complete(const char* code)
    cdef char* mathilda_ffi_complete(const char* prefix)
    cdef void mathilda_ffi_free(char* s)
    cdef const char* mathilda_ffi_version()


# --- state -------------------------------------------------------------------

#: The evaluator is process-global and not reentrant; one lock for everything.
cdef object _lock = threading.RLock()

cdef bint _initialised = False

#: Active ``eval_cell`` callbacks, keyed by a token passed through ``void* ctx``.
cdef dict _sinks = {}
cdef long _next_sink = 0


# --- helpers -----------------------------------------------------------------

def _mapped_library():
    """
    Return the path of the ``libmathilda`` mapped into this process, or ``None``.

    EXAMPLES::

        sage: from sage.libs.mathilda import _mapped_library
        sage: _mapped_library().endswith("libmathilda.so.0")
        True
    """
    try:
        with open("/proc/self/maps") as maps:
            for line in maps:
                fields = line.split()
                if len(fields) >= 6 and "libmathilda" in fields[-1]:
                    return fields[-1]
    except OSError:
        pass
    return None


def library():
    """
    Return the path of the ``libmathilda`` this module is linked against.

    EXAMPLES::

        sage: from sage.libs.mathilda import library
        sage: library().endswith("libmathilda.so.0")
        True
    """
    return _mapped_library() or "libmathilda.so.0"


def init():
    """
    Initialise the kernel (symbol table, builtins, ``init.m`` bootstrap).

    Idempotent, and called implicitly by every entry point below.

    EXAMPLES::

        sage: from sage.libs.mathilda import init
        sage: init() is None
        True
    """
    global _initialised
    if _initialised:
        return None
    mathilda_ffi_init()
    _initialised = True
    return None


cdef str _take(char* value):
    """Consume a caller-owned C string returned by the FFI."""
    cdef bytes raw
    if value == NULL:
        return ""
    try:
        raw = value
    finally:
        mathilda_ffi_free(value)
    return raw.decode("utf-8", "replace")


cdef void _sink(void* ctx, const char* json_line) noexcept:
    """Adapter from the FFI's C callback to the Python callable in ``_sinks``."""
    cdef long token = <long><Py_ssize_t>ctx
    cdef object callback
    try:
        callback = _sinks.get(token)
        if callback is not None:
            callback((<bytes>json_line).decode("utf-8", "replace"))
    except BaseException:
        pass


cdef str _parse_checked(str text, str code):
    """Raise :class:`MathildaError` if the FFI signalled a parse failure."""
    if text.startswith("$Failed (parse"):
        raise MathildaError("Parse error: %s" % (code,))
    return text


# --- the interface -----------------------------------------------------------

cdef class Mathilda:
    """
    A handle on the process-wide Mathilda kernel.

    There is exactly one kernel per process (the C API has global state), so
    constructing a second handle is cheap and shares every definition.  All
    calls are serialised by a module-wide lock.

    EXAMPLES::

        sage: from sage.libs.mathilda import Mathilda
        sage: M = Mathilda()
        sage: M.eval("FactorInteger[360]")
        '{{2, 3}, {3, 2}, {5, 1}}'
        sage: M.close()
    """

    cdef str _home

    def __cinit__(self, home=None):
        global _initialised
        if not _initialised:
            init()
        self._home = None

    @property
    def alive(self):
        """
        Always ``True``: the kernel lives in this process.

        EXAMPLES::

            sage: from sage.libs.mathilda import Mathilda
            sage: Mathilda().alive
            True
        """
        return True

    def __repr__(self):
        return "<Mathilda kernel %s, in-process>" % self.version()

    cpdef str eval(self, str code):
        """
        Evaluate ``code`` and return Mathilda's output text.

        EXAMPLES::

            sage: from sage.libs.mathilda import Mathilda
            sage: M = Mathilda()
            sage: M.eval("D[Sin[x] Exp[x], x]")
            'E^x Cos[x] + E^x Sin[x]'
        """
        cdef bytes raw
        cdef char* out
        init()
        raw = code.encode("utf-8")
        with _lock:
            out = mathilda_ffi_eval(raw)
            return _parse_checked(_take(out), code)

    cpdef str latex(self, str code):
        """
        Return the LaTeX form of the result of ``code``.

        EXAMPLES::

            sage: from sage.libs.mathilda import Mathilda
            sage: Mathilda().latex("Integrate[x^2, x]")
            '\\frac{1}{3}\\,x^{3}'
        """
        cdef bytes raw
        cdef char* out
        init()
        raw = code.encode("utf-8")
        with _lock:
            out = mathilda_ffi_eval_latex(raw)
            return _parse_checked(_take(out), code)

    cpdef dict json(self, str code):
        """
        Evaluate ``code`` once and return the FFI's JSON record as a dict.

        The record is one of ``{"type": "expr", "payload": ..., "latex": ...}``,
        ``{"type": "error", "message": ...}`` or ``{"type": "plot", "payload": ...}``.

        EXAMPLES::

            sage: from sage.libs.mathilda import Mathilda
            sage: d = Mathilda().json("1/2 + 1/3")
            sage: d["type"], d["payload"]
            ('expr', '5/6')
        """
        cdef bytes raw
        cdef char* out
        cdef str text
        init()
        raw = code.encode("utf-8")
        with _lock:
            out = mathilda_ffi_eval_json(raw)
            text = _take(out)
        return json.loads(text)

    cpdef list call(self, str code, int id=1, bint cell=True):
        """
        Evaluate ``code`` as a notebook cell and return the event records.

        Each event is one of the JSON lines the C API emits (``line``,
        ``stream``, ``message``, ``expr``, ``plot``, ``image``, ``usage``,
        ``names``, ``error``), always ending with ``done``.

        EXAMPLES::

            sage: from sage.libs.mathilda import Mathilda
            sage: events = Mathilda().call("Expand[(a + b)^2]")
            sage: events[0]["type"], events[-1]["type"]
            ('line', 'done')
            sage: [e["payload"] for e in events if e["type"] == "expr"]
            ['a^2 + 2 a b + b^2']
        """
        cdef bytes raw
        cdef list events = []
        cdef long token
        global _next_sink
        init()
        raw = code.encode("utf-8")
        with _lock:
            _next_sink += 1
            token = _next_sink
            _sinks[token] = events.append
            try:
                mathilda_ffi_eval_cell(raw, id, 1 if cell else 0, _sink,
                                       <void*><Py_ssize_t>token)
            finally:
                _sinks.pop(token, None)
        return [json.loads(line) for line in events]

    cpdef bint is_complete(self, str code):
        """
        Whether ``code`` forms a complete expression (console continuation test).

        EXAMPLES::

            sage: from sage.libs.mathilda import Mathilda
            sage: M = Mathilda()
            sage: M.is_complete("Sin[x"), M.is_complete("Sin[x]")
            (False, True)
        """
        cdef bytes raw
        init()
        raw = code.encode("utf-8")
        with _lock:
            return mathilda_ffi_is_complete(raw) != 0

    cpdef list complete(self, str prefix):
        """
        Return the defined symbols starting with ``prefix`` (tab completion).

        EXAMPLES::

            sage: from sage.libs.mathilda import Mathilda
            sage: M = Mathilda()
            sage: M.complete("Si")[:3]
            ['Sign', 'Signature', 'SimpleGraphQ']
        """
        cdef bytes raw
        cdef char* out
        cdef str text
        init()
        raw = (prefix or "").encode("utf-8")
        with _lock:
            out = mathilda_ffi_complete(raw)
            text = _take(out)
        return json.loads(text)

    cpdef str version(self):
        """
        Return the version string of the linked kernel.

        EXAMPLES::

            sage: from sage.libs.mathilda import Mathilda
            sage: Mathilda().version().startswith("0.")
            True
        """
        cdef const char* banner
        cdef bytes raw
        with _lock:
            banner = mathilda_ffi_version()
            if banner == NULL:
                return ""
            raw = banner
            return raw.decode("utf-8", "replace")

    cpdef close(self):
        """
        No-op, kept for interface compatibility: the kernel is not a process.

        EXAMPLES::

            sage: from sage.libs.mathilda import Mathilda
            sage: Mathilda().close() is None
            True
        """
        return None

    def __enter__(self):
        return self

    def __exit__(self, exc_type, exc_value, traceback):
        return False


cdef object _default = None


def mathilda():
    """
    Return a shared :class:`Mathilda` handle, creating it on first use.

    EXAMPLES::

        sage: from sage.libs.mathilda import mathilda
        sage: mathilda().eval("2 + 3")
        '5'
    """
    global _default
    if _default is None:
        _default = Mathilda()
    return _default


def evaluate(code):
    """
    Evaluate ``code`` on the shared handle.

    EXAMPLES::

        sage: from sage.libs.mathilda import evaluate
        sage: evaluate("Fibonacci[100]")
        '354224848179261915075'
    """
    return mathilda().eval(code)


def version():
    """
    Return the kernel version string.

    EXAMPLES::

        sage: from sage.libs.mathilda import version
        sage: version().startswith("0.")
        True
    """
    return mathilda().version()


def is_complete(code):
    """
    Whether ``code`` is a complete expression.

    EXAMPLES::

        sage: from sage.libs.mathilda import is_complete
        sage: is_complete("f[x"), is_complete("f[x]")
        (False, True)
    """
    return mathilda().is_complete(code)


def complete(prefix):
    """
    Return the symbols starting with ``prefix``.

    EXAMPLES::

        sage: from sage.libs.mathilda import complete
        sage: "Sin" in complete("Si")
        True
    """
    return mathilda().complete(prefix)
