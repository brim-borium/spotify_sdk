#!/bin/sh
REPO_NAME="ios-sdk"
FRAMEWORK_NAME="SpotifyiOS.xcframework"

#!/bin/sh
TARGET_DIR="spotify_sdk_ios/${REPO_NAME}"
rm -fR ${TARGET_DIR}
mkdir -p ${TARGET_DIR}
git clone https://github.com/spotify/${REPO_NAME} ${TARGET_DIR}
git -C ${TARGET_DIR} checkout tags/v5.0.1
find ./${TARGET_DIR} -mindepth 1 -maxdepth 1 -not -name ${FRAMEWORK_NAME} -exec rm -rf '{}' \;   # Keep on only the xcframework folder
