#!/bin/bash
set -e

# Use the environment variable to target a specific device
if [ "$DEVICE_ID" = "" ]; then
  echo "Target device: default"
  TARGET=""
else
  echo "Target device: $DEVICE_ID"
  TARGET="-s $DEVICE_ID"
fi

SCRIPT_BASE_DIR="$( cd "$( dirname "$0" )" && pwd )"
NODEJS_BASE_DIR="$( cd "$( dirname "$0" )" && cd .. && cd .. && cd .. && pwd )"
TEST_APP_BASE_DIR="$( cd "$( dirname "$0" )" && cd testnode/ && pwd )"
TEST_PROXY_TARGETDIR="$( cd "$NODEJS_BASE_DIR" && mkdir -p ./out/android.release/ && cd ./out/android.release/ && pwd )"

# Build the Android test app
( cd "$TEST_APP_BASE_DIR" && ./gradlew assembleDebug )

# Copy the Android proxy to the target directory.
cp "$SCRIPT_BASE_DIR/node-android-proxy.sh" "$TEST_PROXY_TARGETDIR/node"

# Kill the test app if it's running
adb $TARGET shell 'am force-stop nodejsmobile.test.testnode'
# Clean the Android log
adb logcat -c

adb $TARGET install -r "$TEST_APP_BASE_DIR/app/build/outputs/apk/app-debug.apk"

# Start the test app without parameter in order to copy the assets to a writable location
adb $TARGET shell 'am start -n nodejsmobile.test.testnode/nodejsmobile.test.testnode.MainActivity' > /dev/null

# Wait for the installation result to appear in the log
adb $TARGET shell 'logcat -b main -v raw -s TestNode:V | (grep -q "^COPYASSETS:" && kill -2 $(ps | grep "logcat" | sed -r "s/[[:graph:]]+[ \t]+([0-9]+).*/\1/g"))' < /dev/null

# Return 0 if the test passed, 1 if it failed
parseLogcat() {
  adb $TARGET shell 'logcat -d -b main -v raw -s TestNode:V | grep -m 1 "^COPYASSETS:" | sed -e ''s/COPYASSETS:PASS/0/'' -e ''s/COPYASSETS:FAIL/1/'' '
}
RESULT=$(parseLogcat)

# Echo the raw stdout and stderr
adb $TARGET shell 'logcat -d -b main -v raw -s TestNode:V'

if [ $RESULT -eq 1 ]; then
  exit $RESULT
fi