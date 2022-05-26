# polaris-dependencies
Files for downloading and building POLARIS dependencies


## Building using containers

This project contains a devcontainer specification that can be used to quickly spin up a self-contained dev environment using docker containers.

The easiest way to use this is to use VS Code and install the remote-containers plugin (NOTE: you will need docker desktop installed). More information can be found here:

> https://code.visualstudio.com/docs/remote/containers

Then you should be able to If you open this directory using the "Remote-Containers: Open directory in container" task and it will automatically download a debian version of the [official](https://hub.docker.com/_/gcc) official gcc images and install a modern cmake.