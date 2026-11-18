# sage_setup: distribution = sagemath-environment
import argparse
import sys

from sage.cli.options import CliOptions


class CommandAction(argparse.Action):
    r"""
    Store the command and the arguments that follow it.
    """

    def __call__(self, parser, namespace, values, option_string=None):
        namespace.command = values[0] if values else None
        namespace.command_args = values[1:]


class EvalCmd:
    @staticmethod
    def extend_parser(parser: argparse.ArgumentParser):
        r"""
        Extend the parser with the "run" command.

        INPUT:

        - ``parsers`` -- the parsers to extend.

        OUTPUT:

        - the extended parser.
        """
        parser.add_argument(
            "-c",
            "--command",
            # like python, everything after the command is passed to it
            nargs=argparse.REMAINDER,
            action=CommandAction,
            help="execute the given command as sage code, passing the remaining arguments to it",
        )

    def __init__(self, options: CliOptions):
        r"""
        Initialize the command.
        """
        self.options = options
        # like python, set sys.argv to "-c" and the arguments after the command
        sys.argv = ["-c", *(options.command_args or [])]

    def run(self) -> int:
        r"""
        Execute the given command.
        """
        from sage.repl.preparse import preparse
        from sage.all import sage_globals

        code = preparse(self.options.command)
        eval(compile(code, "<cmdline>", "exec"), sage_globals())
        return 0
