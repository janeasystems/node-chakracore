# Running the Node.js tests in Node.js for Mobile Apps

This document describes how to run the Node.js tests for testing the nodejs-mobile runtime on iOS and Android. Currently, the tests can only be run on physical devices, not simulators.

The Node.js tests expect to run the Node.js runtime as if it was a standalone executable running on the same machine. To get around this, iOS and Android applications were developed to use the nodejs-mobile library and behave like a desktop standalone application, paired with "proxy" scripts that are called by `tools/test.py` as if they were the actual desktop node application and start the iOS or Android applications to run the selected tests and return the results.

Some tests depend on the ability of node to spawn new processes / fork the current process, which is not supported in `nodejs-mobile`, so those tests are skipped, alongside tests for other functionalities not currently supported. Tests that are expected to fail are also currently skipped so we can use the current tests as a regression baseline.

## iOS

### iOS prerequisites

You'll need a macOS development machine, an iOS arm64 physical device running iOS 11.0 or greater and a valid iOS Development certificate installed.

iOS tests depend on the [`ios-deploy` tool](https://github.com/phonegap/ios-deploy) for installing and running the test app. You can install it by using npm:
```sh
npm install -g ios-deploy@1.9.2
```

You'll need to build nodejs-mobile, so [its prerequisites should also be installed on your system.](https://github.com/janeasystems/nodejs-mobile#prerequisites-to-build-the-ios-framework-library-on-macos)

### Build and install the iOS test app

Build nodejs-mobile [for iOS](https://github.com/janeasystems/nodejs-mobile#building-the-ios-framework-library-on-macos):
```sh
./tools/ios_framework_prepare.sh
```

Connect the iOS device on which you intend to run tests, and make sure its screen stays unlocked.

Sign the `tools/mobile-test/ios/testnode/testnode.xcodeproj` in Xcode to be able to run on your target device. In the project settings (click on the project main node), in the `Signing` portion of the `General` tab, select a valid Team and handle the provisioning profile creation/update. If you get an error that the bundle identifier cannot be used, you can simply change the bundle identifier to a unique string by appending a few characters to it.

Run the helper script to build and install the iOS test application. It will also run the application on the device to copy the tests to the iOS application's documents path:
```sh
./tools/mobile-test/ios/prepare-ios-tests.sh
```

This should be done the first time you run the tests and be repeated any time you change any of the tests or rebuild nodejs-mobile.

If you have more than one device connected to the development machine you can use the environment variable `DEVICE_ID` to select the device you want to run the tests on. Start by listing the devices:
```sh
ios-deploy --detect
```
and then run the helper script setting `DEVICE_ID` to the device id you intend on using:
```sh
DEVICE_ID=1234567890abcdef123456789abcdef987654321 ./tools/mobile-test/ios/prepare-ios-tests.sh
```

### Run test suites on an iOS device

Connect the iOS device on which you intend to run tests, and make sure its screen stays unlocked.

You can run the Node.js test scripts in iOS by calling `./tools/test.py` with `--arch ios`. Here's an example to run the `parallel`, `sequential` and `message` test suites:
```sh
./tools/test.py --report --flaky-tests=skip --arch ios parallel sequential message
```

While the tests are running, you will see the test application being repeatedly restarted on your test device.

If you have more than one device connected to the development machine you can use the environment variable `DEVICE_ID` to select the device you want to run the tests on. Start by listing the devices:
```sh
ios-deploy --detect
```
and then run the tests setting `DEVICE_ID` to the device id you intend on using:
```sh
DEVICE_ID=1234567890abcdef123456789abcdef987654321 ./tools/test.py --report --flaky-tests=skip --arch ios parallel sequential message
```

## Android

### Android prerequisites

You'll need a macOS or Linux development machine, and a physical Android device.

You'll need [Android Studio](https://developer.android.com/studio/install.html) installed on your development Machine, alongside `Java`, `Gradle`, the `Android 8.0 (Android SDK Platform 26)`, `Android SDK Build Tools v26.0.1`, `Android SDK Tools`, `Android SDK Platform-Tools`, `NDK version >=16` and `CMake`.

You should set the Environment variables required to build Android Applications from the command line: the `ANDROID_HOME` variable pointing to your `android-sdk` path and the `ANDROID_NDK_HOME` variable pointing to the installed NDK path (it usually is `$ANDROID_HOME/ndk-bundle`) . You should also add `$ANDROID_HOME/platform-tools`, `$ANDROID_HOME/tools` and `$ANDROID_HOME/tools/bin` to the `PATH` environment variable.

You'll need to build nodejs-mobile, so [its prerequisites should also be installed on your system.](https://github.com/janeasystems/nodejs-mobile#prerequisites-to-build-the-android-library-on-linux-ubuntudebian)

### Build and install the Android test app

Build nodejs-mobile [for Android](https://github.com/janeasystems/nodejs-mobile#building-the-android-library-on-linux-or-macos):
```sh
./tools/android_build.sh "$ANDROID_NDK_HOME"
```

Connect the Android device on which you intend to run tests, and make sure its screen stays unlocked.

Run the helper script to build and install the Android test application. It will also run the application on the device to copy the tests to the Android application's `FilesDir` path:
```sh
./tools/mobile-test/android/prepare-android-test.sh
```

This should be done the first time you run the tests and be repeated any time you change any of the tests or rebuild nodejs-mobile.

If you have more than one device connected to the development machine you can use the environment variable `DEVICE_ID` to select the device you want to run the tests on. Start by listing the devices:
```sh
adb devices
```
and then run the helper script setting `DEVICE_ID` to the device id you intend on using:
```sh
DEVICE_ID=ENU7N123456789A ./tools/mobile-test/android/prepare-android-tests.sh
```

### Run test suites on an Android device

Connect the Android device on which you intend to run tests, and make sure its screen stays unlocked.

You can run the Node.js test scripts in Android by calling `./tools/test.py` with `--arch android`. Here's an example to run the `parallel`, `sequential` and `message` test suites:
```sh
./tools/test.py --report --flaky-tests=skip --arch android parallel sequential message
```

While the tests are running, you will see the test application being repeatedly restarted on your test device.

If you have more than one device connected to the development machine you can use the environment variable `DEVICE_ID` to select the device you want to run the tests on. Start by listing the devices:
```sh
adb devices
```
and then run the tests setting `DEVICE_ID` to the device id you intend on using:
```sh
DEVICE_ID=ENU7N123456789A ./tools/test.py --report --flaky-tests=skip --arch android parallel sequential message
```
