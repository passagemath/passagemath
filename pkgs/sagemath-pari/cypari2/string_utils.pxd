# sage_setup: distribution = sagemath-pari

cdef extern from *:
    int PY_MAJOR_VERSION

cpdef bytes to_bytes(s)
cpdef unicode to_unicode(s)

cpdef inline to_string(s):
    r"""
    Converts a bytes and unicode ``s`` to a string.

    String means bytes in Python2 and unicode in Python3

    Examples:

    >>> from cypari2.string_utils import to_string
    >>> s1 = to_string(b'hello')
    >>> s2 = to_string('hello')
    >>> s3 = to_string(u'hello')
    >>> type(s1) == type(s2) == type(s3) == str
    True
    >>> s1 == s2 == s3 == 'hello'
    True
    """
    if PY_MAJOR_VERSION <= 2:
        return to_bytes(s)
    else:
        return to_unicode(s)
