# sage_setup: distribution = sagemath-environment
from sage.cli import main
from sage.cli.eval_cmd import EvalCmd
from sage.cli.options import CliOptions
from unittest.mock import patch
import pytest
import sys


def test_eval_cmd_print(capsys):
    with patch.object(sys, 'argv', ["sage"]):
        options = CliOptions(command="print(3^33)")
        eval_cmd = EvalCmd(options)

        result = eval_cmd.run()
        captured = capsys.readouterr()
        assert captured.out == "5559060566555523\n"
        assert result == 0


def test_eval_cmd_invalid_command(capsys):
    with patch.object(sys, 'argv', ["sage"]):
        options = CliOptions(command="invalid_command")
        eval_cmd = EvalCmd(options)

        with pytest.raises(NameError) as err:
            result = eval_cmd.run()
        assert str(err.value) == "name 'invalid_command' is not defined"


@pytest.mark.parametrize("option", ["-c", "--command"])
@pytest.mark.parametrize(
    "args",
    [
        [],
        ["foo", "--input", "x"],
        # arguments that are also options of sage
        ["-v", "foo"],
        ["-q", "--simple-prompt"],
        ["--version"],
        ["--help"],
        ["-c", "print('another command')"],
        # the separator is passed to the command, like in python
        ["--"],
        ["--", "x"],
        ["--", "-v"],
        ["--", "--", "x"],
        ["x", "--", "y"],
        ["-v", "--", "--version"],
    ],
)
def test_eval_cmd_with_args(capsys, option, args):
    with patch.object(sys, 'argv', ["sage", "-q", option, "import sys; print(sys.argv)", *args]):
        result = main()
        captured = capsys.readouterr()
        assert result == 0
        assert captured.out == f"{['-c', *args]}\n"


def test_eval_cmd_does_not_run_file(capsys, tmp_path):
    file = tmp_path / "test.py"
    file.write_text("print('the file was run')")
    with patch.object(sys, 'argv', ["sage", "-q", "-c", "print('the command was run')", str(file)]):
        result = main()
        captured = capsys.readouterr()
        assert result == 0
        assert captured.out == "the command was run\n"


def test_eval_cmd_empty_command(capsys):
    with patch.object(sys, 'argv', ["sage", "-q", "-c", ""]):
        result = main()
        captured = capsys.readouterr()
        assert result == 0
        assert captured.out == ""


@pytest.mark.parametrize("option", ["-c", "--command"])
def test_eval_cmd_missing_command(option):
    with patch.object(sys, 'argv', ["sage", option]):
        with pytest.raises(SystemExit) as exc:
            main()
        assert exc.value.code == 2
