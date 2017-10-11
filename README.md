Node.js for Mobile Apps
====================================

This is the main repository for [Node.js for Mobile Apps](https://code.janeasystems.com/nodejs-mobile), a toolkit for integrating Node.js into mobile applications.

## Resources for Newcomers
* [Website](https://code.janeasystems.com/nodejs-mobile)
* [Mailing list](https://groups.google.com/group/nodejs-mobile)
* [Gitter channel](https://gitter.im/nodejs-mobile/community)

This is the central repository for reporting **all issues** related to the Node.js for Mobile Apps project, including issues pertaining to the React Native and Cordova plugins. 

The core library source code is in this repo. If you are looking for the *source code* for the plugins, you can find it at:

* [React Native plugin source repo](https://github.com/janeasystems/nodejs-mobile-react-native)
* [Cordova plugin source repo](https://github.com/janeasystems/nodejs-mobile-cordova)


## Project Goals

1. To provide the fixes necessary to run Node.js on mobile operating systems.
1. To investigate which features need to be added to Node.js in order to make it a useful tool for mobile app development.
1. To diverge as little as possible from nodejs/node and nodejs/node-chakracore, while fulfilling goals (1) and (2).

## Download
Binaries for Android and iOS are available at https://github.com/janeasystems/nodejs-mobile/releases.

## Documentation
Documentation can be found on the [project website](https://code.janeasystems.com/nodejs-mobile). Sample code is available in the [samples repo](https://github.com/janeasystems/nodejs-mobile-samples/).

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

### Prerequisites to build the Android library on macOS:

#### Git:

Run `git` in a terminal window, it will show a prompt to install it if not already present.
As an alternative, installing one of these will install `git`:
* Xcode, with the Command Line Tools.
* [Homebrew](https://brew.sh/)
* [Git-SCM](https://git-scm.com/download/mac)

#### Install Android NDK r15c for macOS:
Choose a location where you want to install the Android NDK and run:
```sh
curl https://dl.google.com/android/repository/android-ndk-r15c-darwin-x86_64.zip -o ndk.zip
unzip ndk.zip
```
It will create a `android-ndk-r15c` folder. Save that path for later.

### Building the Android library on Linux or macOS:

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

### Prerequisites to build the iOS .framework library on macOS:

#### Xcode 9 with Command Line Tools

Install Xcode 9 or higher, from the App Store, and then install the Command Line Tools by running the following command:

```sh
xcode-select --install
```

That installs `git`, as well.

#### CMake

To install `CMake`, you can use a package installer like [Homebrew](https://brew.sh/).

First, install `HomeBrew`, if you don't have it already.

```sh
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
```

Then, use it to install `CMake`:

```sh
brew install cmake
```

### Building the iOS .framework library on macOS:

#### 1) Clone this repo and check out the `mobile-master` branch:

```sh
git clone https://github.com/janeasystems/nodejs-mobile
cd nodejs-mobile
git checkout mobile-master
```

#### 2) Run the helper script:

```sh
./tools/ios_framework_prepare.sh
```

That will configure `gyp` to build Node.js and its dependencies as static libraries for iOS on the arm64 and x64 architectures, using the `ChakraCore` engine with JIT disabled. The script copies those libraries to `tools/ios-framework/bin/arm64` and `tools/ios-framework/bin/x64`, respectively. It also merges them into static libraries that contain strips for both architectures, which will be placed in `tools/ios-framework/bin` and used by the `tools/ios-framework/nodeLib.xcodeproj` Xcode project.

The helper script builds the `tools/ios-framework/nodeLib.xcodeproj` Xcode project into three frameworks:
  - The framework to run on iOS devices: `out_ios/Release-iphoneos/libnode.framework`
  - The framework to run on the iOS simulator: `out_ios/Release-iphonesimulator/libnode.framework`
  - The universal framework, that runs on iOS devices and simulators: `out_ios/Release-universal/libnode.framework`

While the universal framework is useful for faster Application development, due to supporting both iOS devices and simulators, frameworks containing simulator strips will not be accepted on the App Store. Before trying to submit your application, it would be advisable to use the `Release-iphoneos/libnode.framework` in your submission archive or strip the x64 slices from the universal framework's binaries before submitting.

## Contributing
Please see the [CONTRIBUTING](https://github.com/janeasystems/nodejs-mobile/blob/mobile-master/doc_mobile/CONTRIBUTING.md) file in the `doc_mobile` folder in this source distribution.

