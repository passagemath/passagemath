# sage_setup: distribution = sagemath-pari
r"""
Conversion functions for bytes/unicode
"""

import sys
encoding = sys.getfilesystemencoding()


cpdef bytes to_bytes(s):
    """
    Converts bytes and unicode ``s`` to bytes.

    Examples:

    >>> from cypari2.string_utils import to_bytes
    >>> s1 = to_bytes(b'hello')
    >>> s2 = to_bytes('hello')
    >>> s3 = to_bytes(u'hello')
    >>> type(s1) is type(s2) is type(s3) is bytes
    True
    >>> s1 == s2 == s3 == b'hello'
    True

    >>> type(to_bytes(1234)) is bytes
    True
    >>> int(to_bytes(1234))
    1234
    """
    cdef int convert
    for convert in range(2):
        if convert:
            s = str(s)
        if isinstance(s, bytes):
            return <bytes> s
        elif isinstance(s, unicode):
            return (<unicode> s).encode(encoding)
    raise AssertionError(f"str() returned {type(s)}")


cpdef unicode to_unicode(s):
    r"""
    Converts bytes and unicode ``s`` to unicode.

    Examples:

    >>> from cypari2.string_utils import to_unicode
    >>> s1 = to_unicode(b'hello')
    >>> s2 = to_unicode('hello')
    >>> s3 = to_unicode(u'hello')
    >>> type(s1) is type(s2) is type(s3) is type(u"")
    True
    >>> s1 == s2 == s3 == u'hello'
    True

    >>> print(to_unicode(1234))
    1234
    >>> type(to_unicode(1234)) is type(u"")
    True
    """
    if isinstance(s, bytes):
        return (<bytes> s).decode(encoding)
    elif isinstance(s, unicode):
        return <unicode> s
    return unicode(s)
