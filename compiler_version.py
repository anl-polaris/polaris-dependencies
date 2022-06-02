from email.mime import base
import sys, os, subprocess
from subprocess import PIPE, run
from os.path import join, exists


def main():
    if sys.platform == "linux" or sys.platform == "linux2":
        if len(sys.argv) > 1:
            cxx = sys.argv[1]
        else:
            cxx = "gcc"
        return get_linux_compiler(cxx)
    elif sys.platform == "win32":
        if len(sys.argv) > 1:
            msvc = sys.argv[1]
        else:
            msvc = "15"
        return get_windows_compiler(msvc)


def get_windows_compiler(msvc_version_number):
    compiler = "msvc"
    version = ""

    if msvc_version_number == "15" or msvc_version_number == "2017":
        version = "15.0"
        os.environ[
            "VCROOT"
        ] = "C:\\Program Files (x86)\\Microsoft Visual Studio\\2017\\Professional\\VC\\Auxiliary\\Build\\"
        os.environ[
            "VSINSTALLDIR"
        ] = "C:\\Program Files (x86)\\Microsoft Visual Studio\\2017\\"
        os.environ["VisualStudioVersion"] = "15.0"
        os.environ["Platform"] = "x64"
        msbuild = "C:\\Program Files (x86)\\Microsoft Visual Studio\\2017\\Professional\\MSBuild\\15.0\\Bin\\MSBuild.exe"
    elif msvc_version_number == "16" or msvc_version_number == "2019":
        version = "16.0"
        base_dir = r"C:\Program Files (x86)\Microsoft Visual Studio\2019"
        if exists(join(base_dir, "Enterprise")):
            base_dir = join(base_dir, "Enterprise")
        elif exists(join(base_dir, "Professsional")):
            base_dir = join(base_dir, "Professsional")
        else:
            raise RuntimeError("Can't find installed VS 2019")
        os.environ["VSINSTALLDIR"] = base_dir + "\\"
        os.environ["VCROOT"] = f"{base_dir}\\VC\\Auxiliary\\Build\\"
        os.environ["VisualStudioVersion"] = "16.0"
        os.environ["Platform"] = "x64"
        # set NMAKE="C:\Program Files (x86)\Microsoft Visual Studio\2019\Enterprise\SDK\ScopeCppSDK\VC\bin\nmake.exe"
        msbuild_exe = f"{base_dir}\\MSBuild\\Current\\Bin\\MSBuild.exe"
        os.environ["MSBUILD"] = msbuild_exe
        os.environ["NMAKE"] = f"{base_dir}\\SDK\\ScopeCppSDK\\VC\\bin\\nmake.exe"
    else:
        return ""

    print(f"Found compiler {compiler}-{version}")

    return f"{compiler}-{version}"


def get_linux_compiler(compiler_name):
    compiler = ""
    version = ""

    if "clang" in compiler_name:
        command = ["clang", "--version"]
    elif "gcc" in compiler_name or "g++" in compiler_name:
        command = ["gcc", "--version"]
    else:
        return ""

    result = run(command, stdout=PIPE, stderr=PIPE, universal_newlines=True)
    output_list = result.stdout.split("\n")
    output = output_list[0]
    output = output.split()
    compiler = output[0]
    version = output[-1]

    print(f"Found compiler {compiler}-{version}")

    return f"{compiler}-{version}"
