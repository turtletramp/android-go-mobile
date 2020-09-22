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

# usage (work in progress)

- Build docker image & make .apk
```
    docker build .  -t android-gomobile    
    docker run -d --name gomob android-gomobile
    docker exec -it gomob /bin/bash
    
    cd go/src/golang.org/x/mobile/example/basic/
    gomobile build
```
