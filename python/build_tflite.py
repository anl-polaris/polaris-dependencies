import os, sys
from os.path import join
from shutil import copytree
from python.utils import build_script, download_and_unzip, replace_in_file, run_and_stream, mkdir_p


def tflite_url(version):
    return f"https://github.com/tensorflow/tensorflow/archive/refs/tags/v{version}.tar.gz"


def build_tflite(output_dir, version, compiler):
    src_dir = join(output_dir, f"tensorflow-{version}")
    download_and_unzip(tflite_url(version), output_dir, src_dir)
    tflite_dir = join(output_dir, f"tflite-{version}")
    return build_tflite_(tflite_dir, src_dir, compiler)


def build_tflite_(output_dir, src_dir, compiler):
    if compiler == "msvc-15.0":
        # VS 2017 can't compile tflite (it needs c++20 features) so we switch to the 2019 comiler
        # for this stage
        compiler = "msvc-16.0"

        # Disable smaller exception handling code so that the binaries built by
        # 2019 can be used in a 2017 project
        os.environ['CXXFLAGS'] = "-d2FH4-"
    cmd = f'cmake {src_dir}/tensorflow/lite'
    temp_script = build_script( output_dir, cmd, compiler)
    if run_and_stream(cmd=temp_script, cwd=output_dir).returncode != 0:
        return False

    build_cmd = "cmake --build . -j"
    if "msvc" in compiler:
        make_msvc_adjustments(output_dir, src_dir)
        build_cmd += " --config Release"

    temp_script = build_script( output_dir, build_cmd)
    if run_and_stream(cmd=temp_script, cwd=output_dir).returncode != 0:
        return False

    include_dir = join(output_dir, 'include')
    tf_include_dir = join(include_dir, 'tensorflow')
    mkdir_p(tf_include_dir)
    copytree(join(output_dir, 'flatbuffers', 'include', 'flatbuffers'), join(include_dir, 'flatbuffers'), dirs_exist_ok=True)
    copytree(join(output_dir, 'abseil-cpp', 'absl'), join(include_dir, 'absl'), dirs_exist_ok=True)
    copytree(join(src_dir, 'tensorflow', 'lite'), join(tf_include_dir, 'lite'), dirs_exist_ok=True)
    return True

def make_msvc_adjustments(output_dir, src_dir):

    # Files () uses designated initializers which requires c++20 support
    tflite_vcxproj = join(output_dir, 'tensorflow-lite.vcxproj')
    cpp14,cpp17,cpp20 = [f"<LanguageStandard>stdcpp{v}</LanguageStandard>" for v in [14, 17, 20]]
    replace_in_file(tflite_vcxproj, cpp17, cpp20)
    replace_in_file(tflite_vcxproj, cpp14, cpp20)

    # These files use gcc specific macro __PRETTY_FUNCTION__, replace its usage with the corresponding MSVC version
    pretty_func_files = ["depthwiseconv_float.h", "depthwiseconv_uint8.h", "integer_ops/depthwise_conv.h"]
    opt_kernel_dir = join(src_dir, 'tensorflow', 'lite', 'kernels', 'internal', 'optimized')
    for i in pretty_func_files:
        replace_in_file(join(opt_kernel_dir, i), '__PRETTY_FUNCTION__', '__FUNCSIG__')