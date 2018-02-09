#!/bin/bash
set -e

if [ "$#" -eq 0 ]; then
  echo "Usage: $0 apk-path"
  exit 1
fi

# Use the environment variable to target a specific device
if [ "$DEVICE_ID" = "" ]; then
  echo "Target device: default"
  TARGET=""
else
  echo "Target device: $DEVICE_ID"
  TARGET="-s $DEVICE_ID"
fi

# Kill the test app if it's running
adb $TARGET shell 'am force-stop nodejsmobile.test.testnode'
# Clean the Android log
adb logcat -c

adb $TARGET install -r $1

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