# Concept idea of this container

* The container itself includes go, Android SDK, gomobile pre-initialized
* The source code to build is mounted into the container via a docker volume (see $SRC_HOME in the example)
* The build also defines the output of the build somwhere inside this mounted volume so that you can access the result from outside the container easily (see '-o myLib.aar' in the example).

# License notes

This image is forked from https://github.com/moohoorama/android-go-mobile which by itself was forked from https://github.com/OpenPriv/android-go-mobile.
Thanks for your work  which helped a lot :)

# Android, Go, and gomobile

This image was built for use with generic gombile builds for Android.

This image includes:

- based on Ubuntu 20.04
- Android SDK, NDK, tools, and API version 28 at `/usr/local/android-sdk`
- Go lang 1.15.2 at `/usr/local/go`
- $GOPATH set to `/workspace/go`
- A go directory with an initialized gomobile installed at `/go`

This image comes with gomobile checkedout and preinitialized (time and space consuming). In order to install this predone work from the image into your Drone CI workspace (a docker volume mounted to `/workspace`), you will want your first pipeline step to be:

    go-link:
      image: openpriv/android-go-mobile
      commands:
        - cp -as /go /workspace/go

`cp -as` recreates the directory structure from /go in /workspace/go but for each file, it just creates a symlink. This is the quickest and most efficent way to mirror the work supplied with the image into your workspace.

# usage

Example how to build a .aar Android library usable in a standard Android app (e.g. with Android Studio).
```
	# do not use the :latest tag for production use to avoid broken build when the container is updated
	BUILD_IMAGE="turtletramp/android-gomobile:1"

	# (optional) pull latest build container (available on docker hub; or alternatively build it yourself locally)
	docker $BUILD_IMAGE
	# execute the build (SRC_HOME is the absolute path of th source code folder containing your go code; it get's mounted as a volume)
	SRC_HOME=`pwd`
	# the workdir specifies the folder inside the source directory that contains the final android library glue code
	docker run --rm -v $SRC_HOME:/workspace/src --workdir /workspace/src $BUILD_IMAGE gomobile bind -target android -v -x -o myLib.aar
```
For further details about gomobile please checkout the gomobile website/documentation.
