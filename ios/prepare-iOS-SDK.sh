#!/bin/sh

if [ "$#" -eq 1 ]; then
    BASE_DIR=$1
else
BASE_DIR=$(exec pwd)
fi

rm -fR ios-sdk
mkdir ios-sdk
curl -OL https://github.com/spotify/ios-sdk/archive/v1.2.2.zip
unzip -o v1.2.2.zip
mv ios-sdk-1.2.2/SpotifyiOS.framework ios-sdk
rm v1.2.2.zip
rm -fR ios-sdk-1.2.2

BASE_DIR="${BASE_DIR}/ios-sdk"
echo "BASE_DIR: ${BASE_DIR}"

MODULE_DIR="${BASE_DIR}/SpotifyiOS.framework"
echo "MODULE_DIR: ${MODULE_DIR}"
mkdir -p "${MODULE_DIR}"
printf "module SpotifyiOS {\n\
header \"Headers/SpotifyiOS.h\"\n\
export *\n\
}" > "${MODULE_DIR}/module.map"
echo "Created module map."
