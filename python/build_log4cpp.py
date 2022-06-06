import os
from platform import architecture
import sys
from os.path import join
from time import sleep
from python.utils import build_script, download_and_unzip, mkdir_p, run_and_stream


def log4cpp_url(version):
    return f"https://sourceforge.net/projects/log4cpp/files/log4cpp-1.1.x%20%28new%29/log4cpp-1.1/log4cpp-{version}.tar.gz/download"


def build_log4cpp(output_dir, version, compiler):
    install_dir = join(output_dir, "log4cpp")
    download_to = install_dir if sys.platform == "win32" else join(install_dir, "build")

    download_and_unzip(
        log4cpp_url(version), download_to, filename=f"log4cpp-{version}.tar.gz"
    )
    if sys.platform == "win32":
        return build_log4cpp_win32(install_dir, compiler)
    else:
        return build_log4cpp_posix(install_dir, compiler)


def build_log4cpp_win32(log4cpp_dir, compiler):
    build_dir = join(log4cpp_dir, "CMAKE_BUILD")
    architecture = "" if compiler == "msvc-15.0" else "-A x64"
    print(compiler)
    temp_script = build_script(
        build_dir,
        f"""
            cmake -G "{ os.environ["CMake_Generator"] }" {architecture} ..\. -Wno-dev
            cmake --build . -j --config Debug
            cmake --build . -j --config RelWithDebInfo
        """,
    )
    return run_and_stream(cmd=temp_script, cwd=build_dir).returncode == 0


def build_log4cpp_posix(build_dir, install_dir):
    temp_script = build_script(
        build_dir,
        f"""
            ./configure --prefix={install_dir}
            make --jobs=10
        """,
    )
    return run_and_stream(cmd=temp_script, cwd=build_dir).returncode == 0
