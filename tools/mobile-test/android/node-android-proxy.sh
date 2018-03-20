#!/bin/bash
set -e

# Use the environment variable to target a specific device
if [ "$DEVICE_ID" = "" ]; then
  TARGET=""
else
  TARGET="-s $DEVICE_ID"
fi

# Kill the test app if it's running
adb $TARGET shell 'am force-stop nodejsmobile.test.testnode'
# Clean the Android log
adb $TARGET logcat -c

TEST_PATH="$( cd "$( dirname "$0" )" && cd .. && cd .. && cd test && pwd )"

ARGS=$(echo $*)

# Start the test app passing the test filename and directory to substitute
ADB_START_COMMAND='am start -n nodejsmobile.test.testnode/nodejsmobile.test.testnode.MainActivity -e "nodeargs" "'$ARGS'" -e "substitutedir" "'$TEST_PATH'" '
adb $TARGET shell "$ADB_START_COMMAND" > /dev/null
# Wait for the test result to appear in the log
adb $TARGET shell 'logcat -b main -v raw -s TestNode:I | (grep -q "^RESULT:" && kill -2 $(ps | grep "logcat" | sed -r "s/[[:graph:]]+[ \t]+([0-9]+).*/\1/g"))' < /dev/null

# Return 0 if the test passed, 1 if it failed
parseLogcat() {
  adb $TARGET shell 'logcat -d -b main -v raw -s TestNode:I | grep -m 1 "^RESULT:" | sed -e ''s/RESULT:PASS/0/'' -e ''s/RESULT:FAIL/1/'' '
}
RESULT=$(parseLogcat)

# Echo the raw stdout and stderr
adb $TARGET shell 'logcat -d -b main -v raw -s TestNode:I | sed -E ''s/^RESULT:[A-Z]*//'' '

if [ $RESULT -eq 1 ]; then
  exit $RESULT
fi