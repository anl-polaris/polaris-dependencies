# polaris-dependencies
Files for downloading and building POLARIS dependencies

To build locally run this:

```
python ./get-deps.py  [-c <COMPILER>] [-d <TARGET_DIR>] [-v] [-p]
```

The flags for the build script are as follows:
* -c <compiler> - the compiler to use [default gcc or msvc-16.0]
* -d <deps_dir> - the directory into which dependencies will be build [default /opt/polaris/deps or c:\opt\polaris\deps]
* -v            - verbose mode - shows the output of the compilation even if it succeeds [default false]
* -p            - produce a packaged .tar.gz of the entire deps dir (i.e. /opt/polaris/deps/gcc-10.3.0.tar.gz) [default false]

## Building using containers

This project contains a devcontainer specification that can be used to quickly spin up a self-contained dev environment using docker containers.

The easiest way to use this is to use VS Code and install the remote-containers plugin (NOTE: you will need docker desktop installed). More information can be found here:

> https://code.visualstudio.com/docs/remote/containers

Then you should be able to If you open this directory using the "Remote-Containers: Open directory in container" task and it will automatically download a debian version of the [official](https://hub.docker.com/_/gcc) official gcc images and install a modern cmake.