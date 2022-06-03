import os
import sys
from os.path import join
from python.utils import download_and_unzip, run_and_stream


def glpk_url(version):
    return f"http://ftp.gnu.org/gnu/glpk/glpk-{version}.tar.gz"


def build_glpk(output_dir, version):
    download_and_unzip(glpk_url(version), output_dir, f"glpk-{version}")
    glpk_dir = join(output_dir, f"glpk-{version}")
    build_fn = build_glpk_win32 if sys.platform == "win32" else build_glpk_posix
    return build_fn(glpk_dir)


def build_glpk_win32(glpk_dir):
    w64_dir = join(glpk_dir, "w64")
    temp_script = build_script(
        w64_dir,
        f"""
            call "{os.environ['VCROOT']}\\vcvarsall.bat" x64
            copy config_VC config.h
            "{os.environ['NMAKE']}" /f Makefile_VC_DLL
            "{os.environ['NMAKE']}" /f Makefile_VC_DLL check
        """,
    )
    return run_and_stream(cmd=temp_script, cwd=w64_dir).returncode == 0


def build_glpk_posix(output_dir):
    temp_script = build_script(
        output_dir,
        f"""
            ./configure --prefix={output_dir}
            make --jobs=10
            make install
        """,
    )
    return run_and_stream(cmd=temp_script, cwd=output_dir).returncode == 0
