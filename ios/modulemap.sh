#!/bin/sh

if [ "$#" -eq 1 ]; then
    BASE_DIR=$1
else
BASE_DIR=$(exec pwd)
fi

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
