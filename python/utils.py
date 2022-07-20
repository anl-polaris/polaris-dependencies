import contextlib
import os
import pathlib
import shlex
import stat
import subprocess
import sys
import tarfile
import urllib.request
from os.path import basename, exists, join
from pathlib import Path
from textwrap import dedent
from zipfile import ZipFile


class TeeLogger(object):
    def __init__(self, filename, verbose):
        self._terminal = sys.stdout
        self._f = open(filename, "w")
        self.verbose = verbose

    def write(self, message):
        if self.verbose:
            self._terminal.write(" -> " + message)
        self._f.write(message.strip() + "\n")

    def fileno(self):
        return self._terminal.fileno()

    @property
    def encoding(self):
        return self._terminal.encoding

    def __enter__(self):
        self.old_stdout, self.old_stderr = sys.stdout, sys.stderr
        self.old_stdout.flush()
        self.old_stderr.flush()
        sys.stdout, sys.stderr = self, self

    def __exit__(self, exc_type, exc_value, traceback):
        self._f.flush()
        self._f.close()
        sys.stdout = self.old_stdout
        sys.stderr = self.old_stderr


def mkdir_p(x):
    Path(x).mkdir(parents=True, exist_ok=True)


def build_script(output_dir, contents, compiler=None):
    extension = "bat" if is_windows() else "sh"
    output_file = join(output_dir, f"temp.{extension}")
    mkdir_p(output_dir)
    contents = wrap_vcvars_bat(dedent(contents), compiler)
    with open(output_file, "w") as f:
        # Make the script is self executable
        if is_posix():
            f.write("#!/usr/bin/env bash\n")

        f.write(contents)

    # Make the script executable (bat are automatically executable)
    if is_posix():
        os.chmod(output_file, os.stat(output_file).st_mode | stat.S_IEXEC)
    return output_file


def run_and_stream(cmd, cwd):
    if isinstance(cmd, str):
        cmd = shlex.split(cmd, posix=is_posix())

    print(f"=== Running command: {cmd}")
    process = subprocess.Popen(
        cmd, env=os.environ, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, cwd=cwd
    )
    for line in iter(process.stdout.readline, b""):
        sys.stdout.write(line.decode(sys.stdout.encoding))
    process.wait()
    return process


def wrap_vcvars_bat(contents, compiler):
    if compiler is None or "msvc" not in compiler:
        return contents
    return dedent(f"""
            call "{os.environ['VCROOT']}\\vcvarsall.bat" x64
            {contents}
           """)

def download_and_unzip(url, directory, creates=None, filename=None, after=None):
    if creates and exists(join(directory, creates)):
        print(f"Directory: {creates} already exists, skipping")
        return  # early
    zip_file = filename or join(directory, basename(url))
    if not exists(zip_file):
        urllib.request.urlretrieve(url, zip_file)

    if zip_file.endswith("tar.gz"):
        with tarfile.open(zip_file) as file:
            file.extractall(directory)
    else:
        ZipFile(zip_file).extractall(directory)

    if after:  # allows the caller to provide specific after download script
        after()


def replace_in_file(file, pattern, replacement):
    file = Path(file)
    file.write_text(file.read_text().replace(pattern, replacement))


@contextlib.contextmanager
def chdir(path):
    """Changes working directory and returns to previous on exit."""
    prev_cwd = Path.cwd()
    os.chdir(path)
    try:
        yield
    finally:
        os.chdir(prev_cwd)


def is_windows():
    return sys.platform == "win32"


def not_windows():
    return not is_windows()


is_posix = not_windows
not_posix = is_windows

# Possible return values for sys.platform
# ┍━━━━━━━━━━━━━━━━━━━━━┯━━━━━━━━━━━━━━━━━━━━━┑
# │ System              │ Value               │
# ┝━━━━━━━━━━━━━━━━━━━━━┿━━━━━━━━━━━━━━━━━━━━━┥
# │ Linux               │ linux or linux2 (*) │
# │ Windows             │ win32               │
# │ Windows/Cygwin      │ cygwin              │
# │ Windows/MSYS2       │ msys                │
# │ Mac OS X            │ darwin              │
# │ OS/2                │ os2                 │
# │ OS/2 EMX            │ os2emx              │
# │ RiscOS              │ riscos              │
# │ AtheOS              │ atheos              │
# │ FreeBSD 7           │ freebsd7            │
# │ FreeBSD 8           │ freebsd8            │
# │ FreeBSD N           │ freebsdN            │
# │ OpenBSD 6           │ openbsd6            │
# ┕━━━━━━━━━━━━━━━━━━━━━┷━━━━━━━━━━━━━━━━━━━━━┙
