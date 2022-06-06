from os.path import join
from python.compiler_version import get_cxx_compiler

from python.utils import mkdir_p, run_and_stream, is_posix


def build_odb(deps_dir, version, compiler):
    build_odb_thing(deps_dir, version, "compiler", compiler)
    build_odb_thing(deps_dir, version, "debug", compiler)
    build_odb_thing(deps_dir, version, "release", compiler)
    return True


def build_odb_thing(deps_dir, version, thing, compiler):
    build_dir = create_bpkg_build_dir(deps_dir, version, thing, compiler)

    def run(cmd):
        if run_and_stream(cmd, cwd=build_dir).returncode != 0:
            raise RuntimeError(f"Error while running: {cmd}")

    if thing == "compiler":
        run("bpkg build odb@https://pkg.cppget.org/1/beta --yes --trust-yes")
        run("bpkg test odb")
        run("bpkg install odb")
    elif (thing == "debug") or (thing == "release"):
        run("bpkg add https://pkg.cppget.org/1/beta")
        run("bpkg fetch --trust-yes")
        run("bpkg build --yes libodb")
        run("bpkg build --yes libodb-sqlite")
        # run("bpkg build libodb-pgsql")
        # run("bpkg build libodb-mysql")
        run("bpkg install --all --recursive")
    else:
        raise RuntimeError(f"Don't know how build odb-thing: {thing}")


def create_bpkg_build_dir(deps_dir, version, thing, compiler):
    install_dir = join(deps_dir, f"odb-{version}-{thing}")
    build_dir = join(deps_dir, f"build-odb-{version}-{thing}")
    lib_dir = join(install_dir, "lib")
    mkdir_p(lib_dir)
    mkdir_p(build_dir)

    # Not sure why but "ODB compiler can only be built with GCC"
    compiler = "gcc" if thing == "compiler" else compiler

    cmd = ["bpkg", "create", "-v", "-d", f"{build_dir}", "cc", "--wipe"]
    cmd.append(get_cxx(compiler))
    cmd.append(f"config.cc.coptions={get_cc_options(thing, compiler)}")
    cmd.append(f"config.cxx.coptions={get_std(compiler)}")
    cmd.append(get_linker_options(thing, compiler))
    # The rpath is used to set a relative search path for so files
    if is_posix():
        cmd.append(f'config.bin.rpath="\$ORIGIN/../lib" ')
    cmd.append(f'config.install.root="{install_dir}" ')
    cmd = [o for o in cmd if o]  # Remove any None that came from unneeded options
    run_and_stream(cmd, cwd=build_dir)
    return build_dir


def get_cxx(compiler):
    return f'config.cxx="{get_cxx_compiler(compiler)}"'


def get_cc_options(thing, compiler):
    if "gcc" in compiler:
        return "-O3" if thing == "debug" else "-O0 -g"
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
    return None
