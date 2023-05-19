symbol_table = {'functions': {}}


def register_symbol(obj, conversions, nargs=None):
    """
    Add an object to the symbol table, along with how to convert it to
    other systems such as Maxima, Mathematica, etc.  This table is used
    to convert *from* other systems back to Sage.

    INPUT:

    - ``obj`` -- a symbolic object or function.

    - ``conversions`` -- a dictionary of conversions, where the keys
      are the names of interfaces (e.g., ``'maxima'``), and the values
      are the string representation of ``obj`` in that system.

    - ``nargs`` -- optional number of arguments. For most functions,
      this can be deduced automatically.

    EXAMPLES::

        sage: from sage.symbolic.expression import register_symbol as rs
        sage: rs(SR(5),{'maxima':'five'})
        sage: SR(maxima_calculus('five'))
        5
    """
    conversions = dict(conversions)
    try:
        conversions['sage'] = obj.name()
    except AttributeError:
        pass
    if nargs is None:
        try:
            nargs = obj.number_of_arguments()
        except AttributeError:
            nargs = -1  # meaning unknown number of arguments
    for system, name in conversions.iteritems():
        system_table = symbol_table.get(system, None)
        if system_table is None:
            symbol_table[system] = system_table = {}
        system_table[(name, nargs)] = obj
