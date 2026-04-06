#!/usr/bin/env bash
#
# Copyright (C) 2024 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

set -e

DEVICE=OP5AA5L1
VENDOR=oppo

# Load extract_utils and do some sanity checks
MY_DIR="${BASH_SOURCE%/*}"
if [[ ! -d "${MY_DIR}" ]]; then MY_DIR="${PWD}"; fi

ANDROID_ROOT="${MY_DIR}/../../.."

HELPER="${ANDROID_ROOT}/tools/extract-utils/extract_utils.sh"
if [ ! -f "${HELPER}" ]; then
    echo "Unable to find helper script at ${HELPER}"
    exit 1
fi
source "${HELPER}"

# Default to target-files
if [ -z "${SRC}" ]; then
    SRC=adb
fi

function blob_fixup() {
    case "${1}" in
        vendor/bin/hw/vendor.mediatek.hardware.mms@1.2-service)
            # Fix missing symbols
            "${PATCHELF}" --replace-needed "libui.so" "libui-v32.so" "${2}"
            ;;
        vendor/lib64/libcam.halsensor.so | vendor/lib64/libcam_platform.so)
            # Fix for Android > 12
            "${PATCHELF}" --replace-needed "libdng_sdk.so" "libdng_sdk-vendor.so" "${2}"
            ;;
    esac
}

# Initialize the helper
setup_vendor "${DEVICE}" "${VENDOR}" "${ANDROID_ROOT}" false false

extract "${MY_DIR}/proprietary-files.txt" "${SRC}" "${SECTION}"

"${MY_DIR}/setup-makefiles.sh"
