import os
import sys
from os.path import join
from time import sleep
from python.utils import build_script, download_and_unzip, mkdir_p, run_and_stream


def log4cpp_url(version):
    return f"https://sourceforge.net/projects/log4cpp/files/log4cpp-1.1.x%20%28new%29/log4cpp-1.1/log4cpp-{version}.tar.gz/download"


def build_log4cpp(output_dir, version):
    dep_ver = f"log4cpp-{version}"
    download_and_unzip(
        log4cpp_url(version),
        output_dir,
        creates=dep_ver,
        filename=f"log4cpp-{version}.tar.gz",
        after=lambda: [
            sleep(2),  # wait for the unzip to release the dir so that we can rename it
            os.rename(join(output_dir, "log4cpp"), join(output_dir, dep_ver)),
        ],
    )
    log4cpp_dir = join(output_dir, f"log4cpp-{version}")
    build_fn = build_log4cpp_win32 if sys.platform == "win32" else build_log4cpp_posix
    return build_fn(log4cpp_dir)


def build_log4cpp_win32(log4cpp_dir):
    build_dir = join(log4cpp_dir, "CMAKE_BUILD")
    temp_script = build_script(
        build_dir,
        f"""
            cmake -G "{ os.environ["CMake_Generator"] }" -A x64 ..\. -Wno-dev
            cmake --build . -j --config Debug
            cmake --build . -j --config RelWithDebInfo
        """,
    )
    return run_and_stream(cmd=temp_script, cwd=build_dir).returncode == 0


def build_log4cpp_posix(output_dir):
    temp_script = build_script(
        output_dir,
        f"""
            ./configure --prefix={output_dir}
            make --jobs=10
            make install
        """,
    )
    return run_and_stream(cmd=temp_script, cwd=output_dir).returncode == 0
