# sage_setup: distribution = sagemath-environment
from sage.cli import main
from sage.cli.run_file_cmd import RunFileCmd
from sage.cli.options import CliOptions
from unittest.mock import patch
import sys


def test_run_file_cmd(capsys, tmp_path):
    file = tmp_path / "test.sage"
    file.write_text("print(3^33)")
    options = CliOptions(file=[str(file)])
    run_file_cmd = RunFileCmd(options)

    result = run_file_cmd.run()
    captured = capsys.readouterr()
    assert captured.out == "5559060566555523\n"


def test_run_file_cmd_with_args(capsys, tmp_path):
    with patch.object(sys, 'argv', ["python3", "test.sage", "1", "1"]):
        file = tmp_path / "test.sage"
        file.write_text("import sys; print(int(sys.argv[1]) + int(sys.argv[2]))")
        options = CliOptions(file=[str(file), "1", "1"])
        run_file_cmd = RunFileCmd(options)

        result = run_file_cmd.run()
        captured = capsys.readouterr()
        assert captured.out == "2\n"


def test_run_file_cmd_with_options_for_the_file(capsys, tmp_path):
    file = tmp_path / "test.py"
    file.write_text("import sys; print(sys.argv)")
    with patch.object(sys, 'argv', ["sage", "-q", str(file), "--input", "x", "-v", "--version"]):
        result = main()
        captured = capsys.readouterr()
        assert result == 0
        assert captured.out == f"{[str(file), '--input', 'x', '-v', '--version']}\n"


def test_run_file_cmd_with_separator(capsys, tmp_path):
    file = tmp_path / "test.py"
    file.write_text("import sys; print(sys.argv)")
    with patch.object(sys, 'argv', ["sage", "-q", "--", str(file), "-v", "--", "x"]):
        result = main()
        captured = capsys.readouterr()
        assert result == 0
        assert captured.out == f"{[str(file), '-v', '--', 'x']}\n"
