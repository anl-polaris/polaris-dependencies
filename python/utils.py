from os.path import basename, join, exists
import subprocess
import sys
import urllib.request
from zipfile import ZipFile
import tarfile


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


def run_and_stream(cmd, cwd):
    process = subprocess.Popen(cmd, stdout=subprocess.PIPE, cwd=cwd)
    for line in iter(process.stdout.readline, b""):
        sys.stdout.write(line.decode(sys.stdout.encoding))
    process.wait()
    return process


def download_and_unzip(url, directory, creates=None):
    if creates and exists(join(directory, creates)):
        print(f"Directory: {creates} already exists, skipping")
        return  # early
    zip_file = join(directory, basename(url))
    if not exists(zip_file):
        urllib.request.urlretrieve(url, zip_file)

    if zip_file.endswith("tar.gz"):
        with tarfile.open(zip_file) as file:
            file.extractall(directory)
    else:
        ZipFile(zip_file).extractall(directory)
    return True
