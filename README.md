Node.js on Mobile
=====================

This project is an experimental fork of [nodejs/node-chakracore](https://github.com/nodejs/node-chakracore) bringing Node.js to mobile operating systems, as a library that can be embedded in mobile applications and frameworks.

It currently only builds for Android (with V8), as a shared library for the `armeabi-v7a`, `x86`, `arm64-v8a` and `x86_64` architectures. Support for iOS is in the works and will be published soon.

##### Project Goals
The goals of this project are:

1. To provide the fixes necessary to run Node.js on mobile operating systems.
1. To investigate which features need to be added to Node.js in order to make it a useful tool for mobile app development.
1. To diverge as little as possible from nodejs/node and nodejs/node-chakracore, while fulfilling goals (1) and (2).

## Download
Binaries are available at https://github.com/janeasystems/nodejs-mobile/releases.

## Documentation

Samples and instructions on how to embed the binaries into mobile applications can be found in the [samples repo](https://github.com/janeasystems/nodejs-mobile-samples/).

***Disclaimer:***  documentation found in this repository is currently unchanged from the parent repository and may only be applicable to node-chakracore.

## Build Instructions

### Prerequisites to build the Android library on Linux Ubuntu/Debian:

#### Basic build tools:
```sh
sudo apt-get install -y build-essential git python
```

#### Install curl and unzip (needed to download the Android NDK):
```sh
sudo apt-get install -y curl unzip
```

#### Install Android NDK r15c for Linux:
Choose a location where you want to install the Android NDK and run:
```sh
curl https://dl.google.com/android/repository/android-ndk-r15c-linux-x86_64.zip -o ndk.zip
unzip ndk.zip
```
It will create a `android-ndk-r15c` folder. Save that path for later.

### Prerequisites to build the Android library on Mac OS:

#### Git:

Run `git` in a terminal window, it will show a prompt to install it if not already present.
As an alternative, installing one of these will install `git`:
* XCode, with the Command Line Tools.
* [Homebrew](https://brew.sh/)
* [Git-SCM](https://git-scm.com/download/mac)

#### Install Android NDK r15c for Mac OS:
Choose a location where you want to install the Android NDK and run:
```sh
curl https://dl.google.com/android/repository/android-ndk-r15c-darwin-x86_64.zip -o ndk.zip
unzip ndk.zip
```
It will create a `android-ndk-r15c` folder. Save that path for later.

### Building the Android library on Linux or Mac OS:

#### 1) Clone this repo and check out the `mobile-master` branch:

```sh
git clone https://github.com/janeasystems/nodejs-mobile
cd nodejs-mobile
git checkout mobile-master
```

#### 2a) Using the Android helper script:

The `tools/android_build.sh` script takes as first argument the Android NDK path (in our case is `~/android-ndk-r15c`). The second argument is optional and is the target architecture, which can be one of the following: `arm`, `x86`, `arm64` or `x86_64`. If no target architecture is provided, it will build all available architectures.
Run:

```sh
./tools/android_build.sh ~/android-ndk-r15c
```

When done, each built shared library will be placed in `out_android/$(ARCHITECTURE)/libnode.so`.

#### 2b) Configure and build manually:
Run the `android-configure` script to configure the build with the path to the downloaded NDK and the desired target architecture.

```sh
source ./android-configure ../android-ndk-r15c arm
```

Start the build phase:
```sh
make
```

This will create the Android `armeabi-v7a` shared library in `out/Release/lib.target/libnode.so`.

## Contributing
Please see the [CONTRIBUTING](https://github.com/janeasystems/nodejs-mobile/blob/mobile-master/doc_mobile/CONTRIBUTING.md) file in the `doc_mobile` folder in this source distribution.

