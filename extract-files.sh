#!/bin/bash
#
# Copyright (C) 2018-2019 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

set -e

DEVICE=violet
VENDOR=xiaomi

# Load extract_utils and do some sanity checks
MY_DIR="${BASH_SOURCE%/*}"
if [[ ! -d "${MY_DIR}" ]]; then MY_DIR="${PWD}"; fi

MK_ROOT="${MY_DIR}"/../../..

HELPER="${MK_ROOT}/vendor/hentai/build/tools/extract_utils.sh"
if [ ! -f "${HELPER}" ]; then
    echo "Unable to find helper script at ${HELPER}"
    exit 1
fi
source "${HELPER}"

# Default to sanitizing the vendor folder before extraction
CLEAN_VENDOR=true

SECTION=
KANG=

while [ "${#}" -gt 0 ]; do
    case "${1}" in
        -n | --no-cleanup )
                CLEAN_VENDOR=false
                ;;
        -k | --kang )
                KANG="--kang"
                ;;
        -s | --section )
                SECTION="${2}"; shift
                CLEAN_VENDOR=false
                ;;
        * )
                SRC="${1}"
                ;;
    esac
    shift
done

if [ -z "${SRC}" ]; then
    SRC="adb"
fi

# Initialize the helper
setup_vendor "${DEVICE}" "${VENDOR}" "${MK_ROOT}" true "${CLEAN_VENDOR}"

extract "${MY_DIR}/proprietary-files.txt" "${SRC}" \
        "${KANG}" --section "${SECTION}"

extract "${MY_DIR}/proprietary-files-coral.txt" "${SRC}" \
        "${KANG}" --section "${SECTION}"

BLOB_ROOT="${MK_ROOT}/vendor/${VENDOR}/${DEVICE}/proprietary"

# Adreno
patchelf --set-soname vulkan.sm6150.so "${BLOB_ROOT}/vendor/lib64/hw/vulkan.sm6150.so"
patchelf --set-soname vulkan.sm6150.so "${BLOB_ROOT}/vendor/lib/hw/vulkan.sm6150.so"

"${MY_DIR}/setup-makefiles.sh"
