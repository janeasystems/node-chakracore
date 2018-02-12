#!/bin/bash

if [ "$DEVICE_ID" = "" ]; then
  TARGET_DEVICE=""
else
  TARGET_DEVICE="-i $DEVICE_ID"
fi

TEMP_COMMAND="$BASH_SOURCE $@"

PROXY_BASE_DIR="$( cd "$( dirname "$0" )" && pwd )"
LOG_FILE_PATH="$PROXY_BASE_DIR/testsrun_$DEVICE_ID.log"
IOS_APP_PATH="$PROXY_BASE_DIR/Release-iphoneos/testnode.app"

TEST_BASE_DIR="$( cd "$( dirname "$0" )" && cd .. && cd .. && cd test && pwd )"

echo "Time: $(date '+%FT%T') -> Proxying testcase: $TEMP_COMMAND" >> "$LOG_FILE_PATH"

ios-deploy -t 60 --noinstall $TARGET_DEVICE -b "$IOS_APP_PATH" --noninteractive --args "--substitute-dir $TEST_BASE_DIR $*" | sed $'s/\r$//' | tee -a "$LOG_FILE_PATH" | sed '1,/(lldb)     autoexit/d' | sed -E '/Process [0-9]+ exited with status.*|PROCESS_EXITED/,$d'

exit ${PIPESTATUS[0]}
