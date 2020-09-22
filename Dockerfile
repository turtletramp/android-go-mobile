# Android section of this Dockerfile from https://medium.com/@elye.project/intro-to-docker-building-android-app-cb7fb1b97602

FROM ubuntu:20.04

RUN apt-get update -q && \
	DEBIAN_FRONTEND=noninteractive apt-get install -q -y --no-install-recommends libegl1-mesa-dev libgles2-mesa-dev libx11-dev \
		software-properties-common python-dev \
		openjdk-8-jdk openjdk-8-jre \
    	python2.7-dev gdb build-essential libtool autotools-dev libcurl4-openssl-dev curl \
    	git gcc g++ vim wget ethtool \
    	zlib1g zlib1g-dev devscripts unoconv unzip && \
	apt-get clean

#ENV SDK_URL="https://dl.google.com/android/repository/sdk-tools-linux-4333796.zip" \
ENV SDK_URL="https://dl.google.com/android/repository/commandlinetools-linux-6609375_latest.zip" \
    ANDROID_HOME="/usr/local/android-sdk" \
    ANDROID_VERSION=28 \
    ANDROID_BUILD_TOOLS_VERSION=30.0.2

## Download Android SDK
RUN mkdir "$ANDROID_HOME" .android "$ANDROID_HOME/cmdline-tools" \
    && cd "$ANDROID_HOME/cmdline-tools" \
    && curl -o sdk.zip $SDK_URL \
    && unzip sdk.zip \
    && rm sdk.zip
RUN yes | $ANDROID_HOME/cmdline-tools/tools/bin/sdkmanager --licenses

## Install Android Build Tool and Libraries
RUN $ANDROID_HOME/cmdline-tools/tools/bin/sdkmanager --update
RUN $ANDROID_HOME/cmdline-tools/tools/bin/sdkmanager "build-tools;${ANDROID_BUILD_TOOLS_VERSION}" \
    "platforms;android-${ANDROID_VERSION}" \
    "platform-tools"

# Install NDK
RUN $ANDROID_HOME/cmdline-tools/tools/bin/sdkmanager "ndk-bundle"

# Go section of this Dockerfile from Docker golang: https://github.com/docker-library/golang/blob/master/1.10/alpine3.8/Dockerfile
# Adapted from alpine apk to debian apt

## set up nsswitch.conf for Go's "netgo" implementation
## - https://github.com/golang/go/blob/go1.9.1/src/net/conf.go#L194-L275
## - docker run --rm debian:stretch grep '^hosts:' /etc/nsswitch.conf
RUN echo 'hosts: files dns' > /etc/nsswitch.conf

# NOTE: When changing this version take care to also change the chksum below (after wget)
ENV GOLANG_VERSION 1.15.2

RUN set -eux; \
	apt-get update; \
	apt-get install -y --no-install-recommends \
		 bash \
		build-essential \
		openssl \
		libssl-dev \
		golang \
	; \
	apt-get clean; \
	rm -rf /var/lib/apt/lists/*; \
	export \
## set GOROOT_BOOTSTRAP such that we can actually build Go
		GOROOT_BOOTSTRAP="$(go env GOROOT)" \
## ... and set "cross-building" related vars to the installed system's values so that we create a build targeting the proper arch
## (for example, if our build host is GOARCH=amd64, but our build env/image is GOARCH=386, our build needs GOARCH=386)
		GOOS="$(go env GOOS)" \
		GOARCH="$(go env GOARCH)" \
		GOHOSTOS="$(go env GOHOSTOS)" \
		GOHOSTARCH="$(go env GOHOSTARCH)" \
	; \
## also explicitly set GO386 and GOARM if appropriate
## https://github.com/docker-library/golang/issues/184
	aptArch="$(dpkg-architecture  -q DEB_BUILD_GNU_CPU)"; \
	case "$aptArch" in \
		arm) export GOARM='6' ;; \
		x86_64) export GO386='387' ;; \
	esac; \
	\
	wget -O go.tgz "https://golang.org/dl/go$GOLANG_VERSION.src.tar.gz"; \
	echo '28bf9d0bcde251011caae230a4a05d917b172ea203f2a62f2c2f9533589d4b4d *go.tgz' | sha256sum -c -; \
	tar -C /usr/local -xzf go.tgz; \
	rm go.tgz; \
	\
	cd /usr/local/go/src; \
	./make.bash; \
	\
	export PATH="/usr/local/go/bin:$PATH"; \
	go version

# persist new go in PATH
ENV PATH /usr/local/go/bin:$PATH

# Setup /workspace
RUN mkdir /workspace
RUN mkdir /go
# link $GOPATH to persistent /go
RUN ln -sf /go /workspace/go
# Set up GOPATH in /workspace
ENV GOPATH /workspace/go
ENV PATH $GOPATH/bin:$PATH
RUN mkdir -p "$GOPATH/src" "$GOPATH/bin" "$GOPATH/pkg" && chmod -R 777 "$GOPATH"

# install gomobile
RUN go get golang.org/x/mobile/cmd/gomobile
RUN gomobile init
ADD vimrc /etc/vim/vimrc

WORKDIR /workspace
