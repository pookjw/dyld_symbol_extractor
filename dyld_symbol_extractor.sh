#!/bin/sh

if [[ $4 == '' ]]; then
    echo "dyld_symbol_extractor.sh [CACHE_PATH] [OUTPUT_DIR] [platform] [arch]"
    echo "macOS cache: /System/Volumes/Preboot/Cryptexes/OS/System/Library/dyld/dyld_shared_cache_arm64e"
    echo "macosx ios watchos tvos bridgeos iosmac driverkit"
    exit 1
fi;

if [[ ! -f $1 ]]; then
    echo "Not found ${1}"
    exit 1
fi;

if [[ ! -d $2 ]]; then
    echo "Not found ${2}"
    exit 1
fi;

WORK_DIR="/tmp/dse"
DSC_EXTRACTOR="${WORK_DIR}/dyld-shared-cache-extractor/build/dyld-shared-cache-extractor"
TBD="${WORK_DIR}/tbd/bin/tbd"

if [[ -d ${WORK_DIR} ]]; then
    rm -rf ${WORK_DIR}
fi;

mkdir -p ${WORK_DIR}
cd ${WORK_DIR}

git clone "https://github.com/keith/dyld-shared-cache-extractor.git"
cd "dyld-shared-cache-extractor"
cmake -B build
cmake --build build
cd ..
if [[ ! -f ${DSC_EXTRACTOR} ]]; then
    echo "Error 1"
    exit 1
fi;

git clone "https://github.com/inoahdev/tbd.git"
cd "tbd"
make
if [[ ! -f "${TBD}" ]]; then
    echo "Error 2"
    exit 1
fi;

${DSC_EXTRACTOR} "${1}" "${2}"
${TBD} -p --ignore-warnings --ignore-clients --ignore-undefineds --allow-private-objc-symbols --ignore-missing-exports --replace-platform "${3}" --replace-archs "${4}" -v v3 -r all "${2}" -o --no-overwrite --preserve-subdirs --replace-path-extension "${2}"
rm -rf "${WORK_DIR}"
