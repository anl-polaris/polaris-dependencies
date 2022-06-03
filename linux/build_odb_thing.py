import pathlib
import shlex
import subprocess
from os import chdir
from os.path import join

from python.utils import mkdir_p, run_and_stream


def build_odb(deps_dir, version):
    build_odb_thing(deps_dir, version, "compiler")
    build_odb_thing(deps_dir, version, "debug")
    build_odb_thing(deps_dir, version, "release")


def build_odb_thing(deps_dir, version, thing):
    build_dir = create_bpkg_build_dir(deps_dir, version, thing)
    with chdir(build_dir):
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


def create_bpkg_build_dir(deps_dir, version, thing):
    install_dir = join(deps_dir, f"odb-{version}-{thing}")
    build_dir = join(deps_dir, f"build-odb-{version}-{thing}")
    lib_dir = join(install_dir, "lib")
    mkdir_p(lib_dir)
    mkdir_p(build_dir)

    opt_level = "-O3" if thing == "debug" else "-O0"

    cmd = f"bpkg create -d {build_dir} cc --wipe "
    cmd += "config.cxx=g++ "
    cmd += f"config.cc.coptions={opt_level} "
    cmd += "config.cxx.coptions=-std=c++17 "
    cmd += f"config.bin.rpath={lib_dir} "
    cmd += f"config.install.root={install_dir} "
    if thing == "debug":
        cmd += "config.cc.coptions=-g "
    run_and_stream(cmd)
    return build_dir
