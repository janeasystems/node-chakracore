#!/bin/bash

set -e

ROOT=${PWD}

SCRIPT_DIR="$(dirname "$BASH_SOURCE")"
cd "$SCRIPT_DIR"
SCRIPT_DIR=${PWD}

#should be the node's source root
cd ../

LIBRARY_PATH='out/Release'

make clean

TARGET_LIBRARY_PATH='tools/ios-framework/bin/arm64'

./configure --dest-os=ios --dest-cpu=arm64 --without-chakra-jit --enable-static --with-intl=none --openssl-no-asm
make -j$(getconf _NPROCESSORS_ONLN)

mkdir -p $TARGET_LIBRARY_PATH

cp $LIBRARY_PATH/libcares.a $TARGET_LIBRARY_PATH/
cp $LIBRARY_PATH/libChakraCoreStatic.a $TARGET_LIBRARY_PATH/
cp $LIBRARY_PATH/libchakrashim.a $TARGET_LIBRARY_PATH/
cp $LIBRARY_PATH/libhttp_parser.a $TARGET_LIBRARY_PATH/
cp $LIBRARY_PATH/libnghttp2.a $TARGET_LIBRARY_PATH/
cp $LIBRARY_PATH/libnode.a $TARGET_LIBRARY_PATH/
cp $LIBRARY_PATH/libopenssl.a $TARGET_LIBRARY_PATH/
cp $LIBRARY_PATH/libuv.a $TARGET_LIBRARY_PATH/
cp $LIBRARY_PATH/libzlib.a $TARGET_LIBRARY_PATH/

make clean

TARGET_LIBRARY_PATH='tools/ios-framework/bin/x64'

./configure --dest-os=ios --dest-cpu=x64 --without-chakra-jit --enable-static --with-intl=none --openssl-no-asm
make -j$(getconf _NPROCESSORS_ONLN)

mkdir -p $TARGET_LIBRARY_PATH

cp $LIBRARY_PATH/libcares.a $TARGET_LIBRARY_PATH/
cp $LIBRARY_PATH/libChakraCoreStatic.a $TARGET_LIBRARY_PATH/
cp $LIBRARY_PATH/libchakrashim.a $TARGET_LIBRARY_PATH/
cp $LIBRARY_PATH/libhttp_parser.a $TARGET_LIBRARY_PATH/
cp $LIBRARY_PATH/libnghttp2.a $TARGET_LIBRARY_PATH/
cp $LIBRARY_PATH/libnode.a $TARGET_LIBRARY_PATH/
cp $LIBRARY_PATH/libopenssl.a $TARGET_LIBRARY_PATH/
cp $LIBRARY_PATH/libuv.a $TARGET_LIBRARY_PATH/
cp $LIBRARY_PATH/libzlib.a $TARGET_LIBRARY_PATH/

TARGET_LIBRARY_PATH='tools/ios-framework/bin'

lipo -create "$TARGET_LIBRARY_PATH/arm64/libcares.a" "$TARGET_LIBRARY_PATH/x64/libcares.a" -output "$TARGET_LIBRARY_PATH/libcares.a"
lipo -create "$TARGET_LIBRARY_PATH/arm64/libChakraCoreStatic.a" "$TARGET_LIBRARY_PATH/x64/libChakraCoreStatic.a" -output "$TARGET_LIBRARY_PATH/libChakraCoreStatic.a"
lipo -create "$TARGET_LIBRARY_PATH/arm64/libchakrashim.a" "$TARGET_LIBRARY_PATH/x64/libchakrashim.a" -output "$TARGET_LIBRARY_PATH/libchakrashim.a"
lipo -create "$TARGET_LIBRARY_PATH/arm64/libhttp_parser.a" "$TARGET_LIBRARY_PATH/x64/libhttp_parser.a" -output "$TARGET_LIBRARY_PATH/libhttp_parser.a"
lipo -create "$TARGET_LIBRARY_PATH/arm64/libnghttp2.a" "$TARGET_LIBRARY_PATH/x64/libnghttp2.a" -output "$TARGET_LIBRARY_PATH/libnghttp2.a"
lipo -create "$TARGET_LIBRARY_PATH/arm64/libnode.a" "$TARGET_LIBRARY_PATH/x64/libnode.a" -output "$TARGET_LIBRARY_PATH/libnode.a"
lipo -create "$TARGET_LIBRARY_PATH/arm64/libopenssl.a" "$TARGET_LIBRARY_PATH/x64/libopenssl.a" -output "$TARGET_LIBRARY_PATH/libopenssl.a"
lipo -create "$TARGET_LIBRARY_PATH/arm64/libuv.a" "$TARGET_LIBRARY_PATH/x64/libuv.a" -output "$TARGET_LIBRARY_PATH/libuv.a"
lipo -create "$TARGET_LIBRARY_PATH/arm64/libzlib.a" "$TARGET_LIBRARY_PATH/x64/libzlib.a" -output "$TARGET_LIBRARY_PATH/libzlib.a"

#Create a path to build the frameworks into
rm -rf out_ios
mkdir -p out_ios
cd out_ios
FRAMEWORK_TARGET_DIR=${PWD}
cd ../

NODELIB_PROJECT_PATH='tools/ios-framework'

xcodebuild build -project $NODELIB_PROJECT_PATH/NodeMobile.xcodeproj -target "NodeMobile" -configuration Release -arch arm64 -sdk "iphoneos" SYMROOT=$FRAMEWORK_TARGET_DIR
xcodebuild build -project $NODELIB_PROJECT_PATH/NodeMobile.xcodeproj -target "NodeMobile" -configuration Release -arch x86_64 -sdk "iphonesimulator" SYMROOT=$FRAMEWORK_TARGET_DIR
cp -RL $FRAMEWORK_TARGET_DIR/Release-iphoneos $FRAMEWORK_TARGET_DIR/Release-universal
lipo -create $FRAMEWORK_TARGET_DIR/Release-iphoneos/NodeMobile.framework/NodeMobile $FRAMEWORK_TARGET_DIR/Release-iphonesimulator/NodeMobile.framework/NodeMobile -output $FRAMEWORK_TARGET_DIR/Release-universal/NodeMobile.framework/NodeMobile

echo "Frameworks built to $FRAMEWORK_TARGET_DIR"

cd "$ROOT"
