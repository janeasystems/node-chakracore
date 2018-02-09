#!/bin/bash
set -e

FOLDER_TARGET="../../../out/android.release"

mkdir "$FOLDER_TARGET"

cp "node-android-proxy.sh" "$FOLDER_TARGET/node"