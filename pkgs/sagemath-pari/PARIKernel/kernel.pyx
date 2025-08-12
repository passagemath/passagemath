# sage_setup: distribution = sagemath-pari
# distutils: include_dirs = READLINE_INCDIR
# distutils: library_dirs = READLINE_LIBDIR
# distutils: extra_link_args = READLINE_LIBEXTRA
# distutils: libraries = readline
#cython: language_level=3
#
# Jupyter kernel for PARI/GP
#
# Copyright (C) 2015-2016 Jeroen Demeyer
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#


from .paridecl cimport *
from .io cimport PARIKernelIO
from libc.setjmp cimport *
from libc.string cimport memset, strncmp
from ipykernel.kernelbase import Kernel
from libc.signal cimport SIGALRM, SIGINT
from posix.signal cimport sigaction, sigaction_t
import PARIKernel

cdef extern from "readline/readline.h":
    pass

DEF PARISIZE = 2**27
DEF PRIMELIMIT = 500000


# Global setjmp() context for error handling
cdef sigjmp_buf context

cdef void pari_recover(long numerr) noexcept nogil:
    siglongjmp(context, numerr)

# Global PARI readline interface
cdef pari_rl_interface pari_rl

# Support for SVG plotting (if compiled in)
try:
    from .svg import init_svg
except ImportError:
    def init_svg(self):
        pass


# Helper functions
cdef extern from "Python.h":
    unicode PyUnicode_FromString(const char*)


cdef inline PyUnicode_FromGEN(GEN g):
    cdef char* s = GENtostr(g)
    cdef object pystr = PyUnicode_FromString(s)
    pari_free(s)
    return pystr


def pari_short_version():
    cdef unsigned long mask = (1<<PARI_VERSION_SHIFT) - 1
    cdef unsigned long n = paricfg_version_code

    cdef unsigned long patch = n & mask
    n >>= PARI_VERSION_SHIFT
    cdef unsigned long minor = n & mask
    n >>= PARI_VERSION_SHIFT
    cdef unsigned long major = n
    return "{}.{}.{}".format(major, minor, patch)


cdef inline bint is_keyword_char_python(s) except -1:
    """
    Given a Python single-character string ``s``, is it a PARI
    keyword character?
    """
    cdef long c
    try:
        c = ord(s)
    except TypeError:
        return 0
    return 32 <= c < 128 and is_keyword_char(c)


class PARIKernel(Kernel):
    implementation = 'PARI'
    implementation_version = PARIKernel.__version__
    language = 'GP'
    language_version = pari_short_version()
    language_info = dict(mimetype='text/x-pari-gp', name='gp', file_extension='.gp')
    banner = "PARI/GP kernel"

    def __init__(self, *args, **kwds):
        super().__init__(*args, **kwds)

        pari_init_opts(PARISIZE, PRIMELIMIT, INIT_SIGm | INIT_DFTm)
        global cb_pari_err_recover
        cb_pari_err_recover = pari_recover
        self.io = PARIKernelIO(self)
        pari_use_readline(pari_rl)
        init_svg(self)

    def do_execute(self, code, silent, store_history=True, user_expressions=None,
                   allow_stdin=False):
        global avma
        cdef pari_sp av = avma
        cdef GEN result

        code = (<unicode?>code).encode("utf-8")
        cdef const char* gp_code = <bytes>code

        self.io.set_parent(self._parent_header)

        cdef sigaction_t sa
        cdef sigaction_t old_sa
        memset(&sa, 0, sizeof(sa))
        sa.sa_handler = pari_sighandler

        cdef int err
        cdef long t_ms, wt_ms
        cdef char last

        with nogil:
            err = sigsetjmp(context, 1)
            if err == 0:  # Initial sigsetjmp() call
                sigaction(SIGINT, &sa, &old_sa)  # Handle SIGINT by PARI
                timer_start(GP_DATA.T)
                walltimer_start(GP_DATA.Tw)
                result = gp_read_str_multiline(gp_code, &last)
                t_ms = timer_delay(GP_DATA.T)
                wt_ms = walltimer_delay(GP_DATA.Tw)
            sigaction(SIGINT, &old_sa, &sa)      # Restore Python SIGINT handler

        if err == 0:  # success
            if not silent:
                if t_ms and GP_DATA.chrono:
                    pari_puts(b"time = ")
                    pari_puts(gp_format_time(t_ms))
                    pari_flush()

            # gnil as a result is like Python's None, it should be
            # considered as "no result"
            if result is not gnil:
                if store_history:
                    pari_add_hist(result, t_ms, wt_ms)

                if last != c';' and not silent:
                    content = {
                        'execution_count': pari_nb_hist(),
                        'data': {
                            'text/plain': PyUnicode_FromGEN(result),
                        },
                        'metadata': {}
                    }
                    self.send_response(self.iopub_socket, 'execute_result', content)

            reply = {'status': 'ok',
                     'execution_count': pari_nb_hist(),
                     'payload': [],
                     'user_expressions': {},
                    }

            avma = av

        else:  # error (therefore no result)
            reply = {'status': 'error',
                     'execution_count': pari_nb_hist(),
                     'ename': "",
                     'evalue': "",
                     'traceback': [],
                    }

            if err > 0:
                # true error
                avma = av
            else:
                # allocatemem
                avma = pari_mainstack.top

        self.io.flush()
        return reply

    def do_complete(self, code, cursor_pos):
        cdef long word
        cdef char** m = pari_completion_matches(&pari_rl,
                (<unicode?>code).encode("utf-8"), cursor_pos, &word)

        cdef list matches = []
        if m != NULL:
            if m[1] == NULL:  # Unique match
                matches = [PyUnicode_FromString(m[0])]
            else:             # Non-unique match
                while m[1] != NULL:
                    matches.append(PyUnicode_FromString(m[1]))
                    m += 1

        reply = dict(status="ok", matches=sorted(matches),
                cursor_start=word, cursor_end=cursor_pos)
        return reply

    def do_inspect(self, code, cursor_pos, detail_level=0):
        word = self.__get_keyword(code, cursor_pos)[0]
        # Possibly rewind if we are right after a "("
        if not word and cursor_pos > 0 and code[cursor_pos-1] == u"(":
            word = self.__get_keyword(code, cursor_pos-1)[0]

        reply = dict(status="ok", found=False, data={}, metadata={})
        if not word:
            return reply

        cdef entree* ep = is_entry((<unicode?>word).encode("utf-8"))
        if ep == NULL or ep.help == NULL:
            return reply

        reply["found"] = True
        reply["data"] = {"text/plain": PyUnicode_FromString(ep.help)}
        return reply

    def publish_svg(self, svg, width, height):
        # For some reason, the payload must be str, not bytes
        if not isinstance(svg, str):
            svg = PyUnicode_FromString(svg)
        content = {
            'data': {
                "text/plain": "SVG plot",
                "image/svg+xml": svg,
            },
            'metadata': {
                "width": width,
                "height": height,
            }
        }
        self.send_response(self.iopub_socket, 'display_data', content)

    def __get_keyword(self, code, pos):
        """
        Return a tuple ``(word, start, end)`` such that ``word`` is a
        PARI "keyword" and ``word = code[start:end]``. The bounds are
        such that ``start <= pos <= end``.
        """
        cdef Py_ssize_t start, end, length = len(code)
        start = end = pos
        while start > 0 and is_keyword_char_python(code[start-1]):
            start -= 1
        while end < length and is_keyword_char_python(code[end]):
            end += 1
        word = code[start:end]
        return (word, start, end)
