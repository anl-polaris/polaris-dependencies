import sys, os, subprocess, pathlib, shutil, getopt
from compiler_version import get_linux_compiler, get_windows_compiler
from os.path import join, dirname, abspath, normpath

sys.path.append(abspath("."))
from linux.build_odb_thing import build_odb
from python.build_boost import build_boost, build_glpk

# python ./get-deps.py -c {compiler} -d {depsdir}
# python ./get-deps.py -d {depsdir} -c {compiler}
# python ./get-deps.py --dependencies {depsdir} --compiler {compiler}


def main():
    setup_variables()
    build_dep("build2", "0.14.0")
    add_build2_to_path()
    build_dep("log4cpp", "1.1.3")
    build_dep("tflite", "2.4.0")
    build_py_dep("boost", "1.71.0", lambda: build_boost(deps_directory))
    build_py_dep("glpk", "4.65", lambda: build_glpk(deps_directory, "4.65"))
    build_dep("boost", "1.71.0")
    build_dep("rapidjson", "1.1.0")
    build_py_dep("odb", "2.5.0", lambda: build_odb(deps_directory, "2.5.0"))
    build_dep("gtest", "1.11.0")

    if operatingSystem == "win32":
        copy_files()

    summarise()


def setup_variables():
    # What OS are we using?
    global operatingSystem
    if sys.platform == "linux" or sys.platform == "linux2":
        operatingSystem = "linux"
    elif sys.platform == "win32":
        operatingSystem = "win32"
    elif sys.platform == "darwin":
        print(f"POLARIS does not support {sys.platform}")
        quit()
    else:
        print(f"Platform {sys.platform} not supported")
        quit()

    # polarisdeps directory for our git repository, ie. where get-deps lives
    global working_directory
    working_directory = os.getcwd()

    # set default values for directory and compiler before checking input
    if "POLARIS_DEPS_DIR" in os.environ:
        base_directory = os.environ["POLARIS_DEPS_DIR"]
    else:
        if operatingSystem == "linux":
            print("Defaulting the dependency directory to /opt/polaris/deps")
            base_directory = "/opt/polaris/deps"
        else:
            print("Defaulting the dependency directory to C:\\opt\\polaris\\deps\\")
            base_directory = "C:\\opt\\polaris\deps\\"

    # compiler should be able to call MSVC on Windows
    global compiler
    if operatingSystem == "linux":
        compiler = "gcc"
    else:
        compiler = "15"

    # Grab command line arguments (if any)
    argv = sys.argv[1:]
    opts, args = getopt.getopt(argv, "c:d:", ["compiler =", "dependencies ="])
    for opt, arg in opts:
        if opt in ["-c", "--compiler"]:
            compiler = arg
            print(f"Compiler input = {arg}")
        elif opt in ["-d", "--dependencies"]:
            base_directory = arg
            print(f"Dependencies input = {arg}")

    global compiler_version
    if operatingSystem == "linux":
        compiler_version = get_linux_compiler(compiler)
    else:
        compiler_version = get_windows_compiler(compiler)
    if compiler_version == "":
        print("No compiler found")
        quit()

    global verbose
    global deps_directory
    global logs_directory
    global status_directory

    verbose = 1
    deps_directory = abspath(normpath(f"{base_directory}/{compiler_version}/"))
    logs_directory = abspath(normpath(f"{deps_directory}/builds/"))
    status_directory = abspath(normpath(f"{deps_directory}/build_status/"))

    print(f"Building in: {deps_directory}")

    for i in [deps_directory, logs_directory, status_directory]:
        mkdir_p(i)


def add_build2_to_path():
    build2_bin_dir = abspath(join(deps_directory, "build2", "bin"))
    if build2_bin_dir not in os.environ["PATH"]:
        os.environ["PATH"] = build2_bin_dir + os.pathsep + os.environ["PATH"]

    build2_lib_dir = abspath(join(deps_directory, "build2", "lib"))
    if "LD_LIBRARY_PATH" not in os.environ:
        os.environ["LD_LIBRARY_PATH"] = build2_lib_dir
    elif build2_lib_dir not in os.environ["LD_LIBRARY_PATH"]:
        os.environ["LD_LIBRARY_PATH"] = (
            build2_lib_dir + os.pathsep + os.environ["LD_LIBRARY_PATH"]
        )


def build_py_dep(dep, version, fn):

    if already_built(status_directory, dep, version):
        return

    try:
        fn()
        mark_as(status_directory, dep, version, "success")
    except Exception as e:
        print(f"Failed while building {dep}: ")
        print(e)
        mark_as(status_directory, dep, version, "fail")


def build_dep(dep, version):
    log_file = os.path.normpath(logs_directory + f"/{dep}_{version}_build.log")
    if os.path.exists(status_directory + f"/{dep}-{version}-success"):
        print(f"Build of {dep} {version}  - SUCCESS (already built)")
        return

    # Should call cmd scripts on Windows
    print(f"Building {dep}-{version}, log: {log_file}")
    if operatingSystem == "linux":
        command = [
            f"{working_directory}/linux/build-{dep}-{version}.sh",
            f"{deps_directory}",
            f"{compiler}",
        ]
    else:
        command = [
            f"{working_directory}\\win32\\build-{dep}-{version}.cmd",
            f"{deps_directory}",
        ]
        command = ["cmd.exe", "/C", " ".join(command)]

    with open(log_file, "w", buffering=1) as f:
        # This can be done more elegantly by just passing f to stdout= in the Popen call
        # but this causes some strange behaviour on bebop, so we do it manually
        print(command)

        ps = subprocess.Popen(command, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
        while True:
            line = ps.stdout.readline().decode()
            if line == "":
                break
            f.write(line.strip() + "\n")
            if verbose:
                print(line.strip())
        ps.wait()

    status = "success" if ps.returncode == 0 else "fail"
    mark_as(status_directory, dep, version, status)


def mark_as(status_directory, dep, version, status):
    print(f"Build of {dep} {version}  - {status.upper()}")
    [rm(f"{status_directory}/{dep}-{version}-{i}") for i in ["fail", "success"]]
    touch(f"{status_directory}/{dep}-{version}-{status}")


def already_built(status_directory, dep, version):
    return os.path.exists(f"{status_directory}/{dep}-{version}-success")


def rm(x):
    os.path.exists(x) and os.remove(x)


def touch(x):
    open(x, "a").close()


def mkdir_p(x):
    pathlib.Path(x).mkdir(parents=True, exist_ok=True)


def copy_files():
    for f in ["Release", "RelWithDebug", "Debug"]:
        folder = join(deps_directory, "bin", f)
        mkdir_p(folder)

        # Split up odb by Rel or Debug
        if "Rel" in folder:
            if os.path.exists(
                f"{deps_directory}/odb-2.5.0-release/bin/"
            ) and os.path.exists(f"{status_directory}/odb-2.5.0-success"):
                shutil.copytree(
                    f"{deps_directory}/odb-2.5.0-release/bin/",
                    f"{deps_directory}/bin/Release/",
                    dirs_exist_ok=True,
                )
                shutil.copytree(
                    f"{deps_directory}/odb-2.5.0-release/bin/",
                    f"{deps_directory}/bin/RelWithDebug/",
                    dirs_exist_ok=True,
                )
        else:
            if os.path.exists(
                f"{deps_directory}/odb-2.5.0-debug/bin/"
            ) and os.path.exists(f"{status_directory}/odb-2.5.0-success"):
                shutil.copytree(
                    f"{deps_directory}/odb-2.5.0-debug/bin/",
                    f"{deps_directory}/bin/Debug/",
                    dirs_exist_ok=True,
                )

        # Copy glpk and tflite regardless of version
        if os.path.isfile(
            f"{deps_directory}/glpk-4.65/w64/glpk_4_65.dll"
        ) and os.path.exists(f"{status_directory}/glpk-4.65-success"):
            shutil.copy(
                f"{deps_directory}/glpk-4.65/w64/glpk_4_65.dll",
                f"{folder}/glpk_4_65.dll",
            )
        # TFLite has some weird permissions issue, adding checks to avoid issues...
        if os.path.exists(
            f"{deps_directory}/tflite-2.4.0/tensorflow/lite/"
        ) and os.path.exists(f"{status_directory}/tflite-2.4.0-success"):
            if not os.path.exists(f"{folder}/tensorflowlite.dll"):
                shutil.copy(
                    f"{deps_directory}/tflite-2.4.0/tensorflow/lite/tensorflowlite.dll",
                    f"{folder}/tensorflowlite.dll",
                )
            if not os.path.exists(f"{folder}/tensorflowlite.dll.if.lib"):
                shutil.copy(
                    f"{deps_directory}/tflite-2.4.0/tensorflow/lite/tensorflowlite.dll.if.lib",
                    f"{folder}/tensorflowlite.dll.if.lib",
                )
            if not os.path.exists(f"{folder}/tensorflowlite.pdb"):
                shutil.copy(
                    f"{deps_directory}/tflite-2.4.0/tensorflow/lite/tensorflowlite.pdb",
                    f"{folder}/tensorflowlite.pdb",
                )


def summarise():
    print("\n--------------------------")
    print("        Summary")
    print("--------------------------\n")
    print(f"Checking status files from {status_directory}")
    for filename in os.listdir(status_directory):
        lib, version, status = filename.split("-")
        symbol = "✔" if status == "success" else "✘"
        print(f"{symbol}  {lib} {version} {status}")


if __name__ == "__main__":
    main()
