# sage_setup: distribution = sagemath-pari
#cython: language_level=3
#
# Helper class to manage I/O between PARI and the Jupyter client
#
# Copyright (C) 2015 Jeroen Demeyer
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


from .paridecl cimport pariOut, pariErr
from ipykernel.iostream import OutStream


cdef extern from "Python.h":
    unicode PyUnicode_FromString(const char *)
    unicode PyUnicode_FromStringAndSize(const char *, Py_ssize_t)

# Unique PARIKernelIO object
cdef PARIKernelIO io


cdef void out_putch(char c) noexcept with gil:
    io.stdout_stream.write(PyUnicode_FromStringAndSize(&c, 1))

cdef void out_puts(const char* s) noexcept with gil:
    io.stdout_stream.write(PyUnicode_FromString(s))

cdef void out_flush() noexcept with gil:
    io.stdout_stream.flush()

cdef void err_putch(char c) noexcept with gil:
    io.stderr_stream.write(PyUnicode_FromStringAndSize(&c, 1))

cdef void err_puts(const char* s) noexcept with gil:
    io.stderr_stream.write(PyUnicode_FromString(s))

cdef void err_flush() noexcept with gil:
    io.stderr_stream.flush()


cdef class PARIKernelIO(object):
    def __cinit__(self):
        self.pari_out.putch = out_putch
        self.pari_out.puts = out_puts
        self.pari_out.flush = out_flush
        self.pari_err.putch = err_putch
        self.pari_err.puts = err_puts
        self.pari_err.flush = err_flush

    def __init__(self, kernel):
        global io
        if io is not None:
            raise RuntimeError("cannot create more than one PARIKernelIO object")
        io = self

        global pariOut, pariErr
        pariOut = &self.pari_out
        pariErr = &self.pari_err

        self.stdout_stream = OutStream(kernel.session,
                kernel.iopub_socket, "stdout")
        self.stderr_stream = OutStream(kernel.session,
                kernel.iopub_socket, "stderr")

    def set_parent(self, parent):
        self.stdout_stream.set_parent(parent)
        self.stderr_stream.set_parent(parent)

    def flush(self):
        self.stdout_stream.flush()
        self.stderr_stream.flush()
