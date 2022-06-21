import os
from os.path import join
import shlex
import shutil
from textwrap import dedent
from python.compiler_version import get_cxx_compiler

from python.utils import build_script, is_windows, mkdir_p, run_and_stream, is_posix


def build_odb(deps_dir, version, compiler):
    build_odb_thing(deps_dir, version, "compiler", compiler)
    build_odb_thing(deps_dir, version, "debug", compiler)
    build_odb_thing(deps_dir, version, "release", compiler)
    return True


def build_odb_thing(deps_dir, version, thing, compiler):
    build_dir = create_bpkg_build_dir(deps_dir, version, thing, compiler)
    bpkg = shutil.which('bpkg')

    def run(contents):
        temp_script = build_script(deps_dir, contents, compiler)
        if run_and_stream(temp_script, cwd=build_dir).returncode != 0:
            raise RuntimeError(f"Error while running: {contents}")

    if thing == "compiler":
        run(f"""
                {bpkg} build odb@https://pkg.cppget.org/1/beta --yes --trust-yes
                {bpkg} test odb
                {bpkg} install odb
            """)

    elif (thing == "debug") or (thing == "release"):
        run(f"""
            {bpkg} add https://pkg.cppget.org/1/beta
            {bpkg} fetch --trust-yes
            {bpkg} build --yes libodb
            {bpkg} build --yes libodb-sqlite
            {bpkg} install --all --recursive
        """)
    else:
        raise RuntimeError(f"Don't know how build odb-thing: {thing}")


def create_bpkg_build_dir(deps_dir, version, thing, compiler):
    build_dir = join(deps_dir, f"build-odb-{version}-{thing}")
    install_dir = get_install_dir(deps_dir, version, thing)
    mkdir_p(build_dir)
    bpkg = f'"{shutil.which("bpkg")}"' # get full path

    # Not sure why but "ODB compiler can only be built with GCC"
    compiler = "gcc" if thing == "compiler" else compiler

    cmd = [bpkg, "create", "-v", "-d", f"{build_dir}", "cc", "--wipe"]
    cmd.append(get_cxx(compiler))
    cmd.append(f"config.cc.coptions={get_cc_options(thing, compiler)}")
    cmd.append(f"config.cxx.coptions={get_std(compiler)}")
    cmd.append(get_linker_options(thing, compiler))
    cmd.append(f'config.install.root={install_dir}')
    if is_posix():
        # The $ORIGIN in rpath is used to set a relative search path for so files
        cmd.append(f'config.bin.rpath="\$ORIGIN/../lib"')

    # Remove any None that came from unneeded options and " wrap any that contain spaces
    cmd = [f'"{e}"' if " " in e else e for e in cmd if e]

    temp_script = build_script(deps_dir, " ".join(cmd), compiler)
    if run_and_stream(temp_script, cwd=build_dir).returncode != 0:
        raise RuntimeError("Command failed")
    return build_dir


def get_install_dir(deps_dir, version, thing):
    # On windows we make sure to drop the odb.exe into the build2 folder so that it is next to the
    # shared libraries and binaries that it needs to run
    if thing == "compiler" and is_windows:
        return join(deps_dir, f"build2")
    return join(deps_dir, f"odb-{version}-{thing}")


def get_cxx(compiler):
    return f'config.cxx="{get_cxx_compiler(compiler)}"'


def get_cc_options(thing, compiler):
    if "gcc" in compiler:
        return "-O3" if thing != "debug" else "-O0 -g"
    if "msvc" in compiler:
        return "/Od /MDd /Zi" if thing == "debug" else "/O2 /MD"


def get_std(compiler):
    if "gcc" in compiler:
        return "-std=c++17"
    if "msvc" in compiler:
        return "/std:c++17"


def get_linker_options(thing, compiler):
    if "msvc" in compiler and thing == "debug":
        return "config.cc.loptions=/DEBUG"
    # if thing == "compiler":
    #     # To avoid having to copy around libstdc++-6.dll and libgcc-whatever.dll, we will compile the
    #     # odb compiler with staticly linked runtime (which is always gcc)
    #     # - note the hacky allow-multiple-definitions
    #     return "config.cc.loptions=-static-libgcc -static-libstdc++ -Wl,-allow-multiple-definition"
    return None
