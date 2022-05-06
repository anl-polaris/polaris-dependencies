import sys, os, subprocess
from subprocess import PIPE, run

def main():
    if sys.platform == "linux" or sys.platform == "linux2":
        if len(sys.argv) > 1:
            cxx=sys.argv[1]
        else:
            cxx="gcc"
        return get_linux_compiler(cxx)
    elif sys.platform == "win32":
        if len(sys.argv) > 1:
            msvc=sys.argv[1]
        else:
            msvc="15"
        return get_windows_compiler(msvc)

def get_windows_compiler(msvc_version_number):
    compiler="msvc"
    version=""

    if msvc_version_number == "15" or msvc_version_number == "2017":
        version="15.0"
        os.environ["VCROOT"] = "C:\\Program Files (x86)\\Microsoft Visual Studio\\2017\\Professional\\VC\\Auxiliary\\Build\\"
        os.environ["VSINSTALLDIR"] = "C:\\Program Files (x86)\\Microsoft Visual Studio\\2017\\"
        os.environ["VisualStudioVersion"] = "15.0"
        os.environ["Platform"] = "x64"
        msbuild="C:\\Program Files (x86)\\Microsoft Visual Studio\\2017\\Professional\\MSBuild\\15.0\\Bin\\MSBuild.exe"
        output=subprocess.run([f"doskey", f"msbuild={msbuild}"], shell=True)
    elif msvc_version_number == "16" or msvc_version_number == "2019":
        version="16.0"
        os.environ["VCROOT"] = "C:\\Program Files (x86)\\Microsoft Visual Studio\\2019\\Professional\\VC\\Auxiliary\\Build\\"
        os.environ["VSINSTALLDIR"] = "C:\\Program Files (x86)\\Microsoft Visual Studio\\2019\\"
        os.environ["VisualStudioVersion"] = "16.0"
        os.environ["Platform"] = "x64"
        msbuild="C:\\Program Files (x86)\\Microsoft Visual Studio\\2019\\Professional\\MSBuild\\Current\\Bin\\MSBuild.exe"
        output=subprocess.run([f"doskey", f"msbuild={msbuild}"], shell=True)
    else:
        return ""
    
    print(f"Found compiler {compiler}-{version}")

    return f"{compiler}-{version}"

def get_linux_compiler(compiler_name):
    compiler=""
    version=""

    if "clang" in compiler_name:
        command=['clang','--version']
    elif "gcc" in compiler_name or "g++" in compiler_name:
        command=['gcc','--version']
    else:
        return ""
    
    result = run(command, stdout=PIPE, stderr=PIPE, universal_newlines=True)
    output_list=result.stdout.split('\n')
    output=output_list[0]
    output=output.split()
    compiler=output[0]
    version=output[-1]
    
    print(f"Found compiler {compiler}-{version}")

    return f"{compiler}-{version}"