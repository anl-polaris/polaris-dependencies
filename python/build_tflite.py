import os, sys
from os.path import join
from shutil import copytree
from python.utils import build_script, download_and_unzip, run_and_stream, mkdir_p


def tflite_url(version):
    return f"https://github.com/tensorflow/tensorflow/archive/refs/tags/v{version}.tar.gz"


def build_tflite(output_dir, version):
    src_dir = join(output_dir, f"tensorflow-{version}")
    download_and_unzip(tflite_url(version), output_dir, src_dir)
    tflite_dir = join(output_dir, f"tflite-{version}")
    build_fn = build_tflite_win32 if sys.platform == "win32" else build_tflite_posix
    build_fn = build_tflite_posix
    return build_fn(tflite_dir, src_dir)


def build_tflite_win32(tflite_dir):
    w64_dir = join(tflite_dir, "w64")
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


def build_tflite_posix(output_dir, src_dir):
    temp_script = build_script(
        output_dir,
        f"""
            cmake {src_dir}/tensorflow/lite
            cmake --build . -j
        """,
    )
    build_success = run_and_stream(cmd=temp_script, cwd=output_dir).returncode == 0
    if not build_success:
        return False

    include_dir = join(output_dir, 'include')
    tf_include_dir = join(include_dir, 'tensorflow')
    mkdir_p(tf_include_dir)
    copytree(join(output_dir, 'flatbuffers', 'include', 'flatbuffers'), join(include_dir, 'flatbuffers'), dirs_exist_ok=True)
    copytree(join(output_dir, 'abseil-cpp', 'absl'), join(include_dir, 'absl'), dirs_exist_ok=True)
    copytree(join(src_dir, 'tensorflow', 'lite'), join(tf_include_dir, 'lite'), dirs_exist_ok=True)
    return True
        
