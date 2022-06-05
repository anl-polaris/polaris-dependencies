import sys, os, subprocess, shutil, getopt
from os.path import join, abspath, normpath
from python.build_log4cpp import build_log4cpp

sys.path.append(abspath("."))
from python.compiler_version import get_compiler_version
from python.build_odb_thing import build_odb
from python.build_boost import build_boost
from python.build_glpk import build_glpk
from python.build_log4cpp import build_log4cpp
from python.utils import TeeLogger, mkdir_p, is_posix, is_windows, run_and_stream

# python ./get-deps.py -c {compiler} -d {depsdir}
# python ./get-deps.py -d {depsdir} -c {compiler}
# python ./get-deps.py --dependencies {depsdir} --compiler {compiler}


def main():
    setup_variables()
    build_dep("build2", "0.14.0")
    add_build2_to_path()
    # build_dep("log4cpp", "1.1.3")
    build_py_dep("log4cpp", "1.1.3", lambda: build_log4cpp(deps_directory, "1.1.3"))
    build_dep("tflite", "2.4.0")
    build_py_dep("boost", "1.71.0", lambda: build_boost(deps_directory))
    build_py_dep("glpk", "4.65", lambda: build_glpk(deps_directory, "4.65"))
    build_dep("boost", "1.71.0")
    build_dep("rapidjson", "1.1.0")
    build_py_dep("odb", "2.5.0", lambda: build_odb(deps_directory, "2.5.0"))
    build_dep("gtest", "1.11.0")

    if is_windows():
        copy_files()

    summarise()


def setup_variables():

    # polarisdeps directory for our git repository, ie. where get-deps lives
    global working_directory
    working_directory = os.getcwd()

    # set default values for directory and compiler before checking input
    if "POLARIS_DEPS_DIR" in os.environ:
        base_directory = os.environ["POLARIS_DEPS_DIR"]
    else:
        base_directory = (
            "/opt/polaris/deps" if is_posix() else "C:\\opt\\polaris\deps\\"
        )

    # compiler should be able to call MSVC on Windows
    global compiler
    compiler = "gcc" if is_posix() else "15"

    global verbose
    verbose = False
    # Grab command line arguments (if any)
    argv = sys.argv[1:]
    opts, args = getopt.getopt(
        argv, "c:d:v", ["compiler =", "dependencies =", "verbose"]
    )
    for opt, arg in opts:
        if opt in ["-c", "--compiler"]:
            compiler = arg
        elif opt in ["-d", "--dependencies"]:
            base_directory = arg
        elif opt in ["-v", "--verbose"]:
            verbose = True

    print("\n--------------------------")
    print("        Build Phase")
    print("--------------------------\n")
    global compiler_version, deps_directory, logs_directory, status_directory
    compiler_version = get_compiler_version(compiler)
    deps_directory = abspath(normpath(f"{base_directory}/{compiler_version}/"))
    logs_directory = abspath(normpath(f"{deps_directory}/builds/"))
    status_directory = abspath(normpath(f"{deps_directory}/build_status/"))
    print(f"Building into ->        {deps_directory}\n")

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
    # This wraps the given function with early return and reporting using flags defined in the build_status directory
    dep_ver = f"{dep}-{version}"
    log_file = os.path.normpath(logs_directory + f"/{dep}_{version}_build.log")

    if already_built(status_directory, dep, version):
        print(f"  {dep_ver:<18}  - skipping - already built")
        return
    print(f"  {dep_ver:<18}  - building -> {log_file}")

    try:
        with TeeLogger(log_file, verbose):
            fn_return_value = fn()

        if fn_return_value:
            mark_as(status_directory, dep, version, "success")
        else:
            mark_as(status_directory, dep, version, "fail")

    except Exception as e:
        print(f"Failed while building {dep}: ")
        print(e)
        mark_as(status_directory, dep, version, "fail")


def build_dep(dep, version):
    build_py_dep(dep, version, lambda: build_dep_(dep, version))


def build_dep_(dep, version):
    extension = "sh" if is_posix() else "cmd"
    sub_dir = "linux" if is_posix() else "win32"
    filename = f"{working_directory}/{sub_dir}/build-{dep}-{version}.{extension}"
    command = [filename, deps_directory, compiler]

    if is_windows():
        command = ["cmd.exe", "/C", " ".join(command)]

    return run_and_stream(command, cwd=None)


def mark_as(status_directory, dep, version, status):
    symbol = "✔" if status == "success" else "✘"
    dep_ver = ""
    print(f"  {dep_ver:<18}  - {symbol} {status}")
    [rm(f"{status_directory}/{dep}-{version}-{i}") for i in ["fail", "success"]]
    touch(f"{status_directory}/{dep}-{version}-{status}")


def already_built(status_directory, dep, version):
    return os.path.exists(f"{status_directory}/{dep}-{version}-success")


def rm(x):
    os.path.exists(x) and os.remove(x)


def touch(x):
    open(x, "a").close()


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
        print(f"  {lib:>10} {version:>8} {symbol}")


if __name__ == "__main__":
    main()
