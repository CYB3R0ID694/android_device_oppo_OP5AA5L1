#!/usr/bin/env bash
#
# extract-kernel.sh - Extract kernel artifacts from a live device via ADB
# For Oppo Find X8 (OP5AA5L1) running ColorOS 16
#
# Usage: ./extract-kernel.sh
# Device must be connected via ADB with root access
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEVICE_PREBUILT="${SCRIPT_DIR}/prebuilt"
SLOT="_a"  # Active slot, change to _b if needed

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info()  { echo -e "${GREEN}[INFO]${NC}  $*"; }
log_warn()  { echo -e "${YELLOW}[WARN]${NC}  $*"; }
log_error() { echo -e "${RED}[ERROR]${NC} $*"; }

# Check ADB connection
check_adb() {
    if ! adb devices | grep -q "device$"; then
        log_error "No device connected via ADB. Connect your Find X8 and enable USB debugging."
        exit 1
    fi
    
    # Try to get root
    adb root || log_warn "Cannot get root. Some operations may fail."
    sleep 1
}

# Get active slot
get_slot() {
    SLOT=$(adb shell getprop ro.boot.slot_suffix 2>/dev/null || echo "_a")
    log_info "Active slot: ${SLOT}"
}

# Extract boot image and unpack
extract_boot() {
    log_info "Extracting boot image from slot ${SLOT}..."
    
    mkdir -p "${DEVICE_PREBUILT}/tmp"
    
    adb shell "dd if=/dev/block/by-name/boot${SLOT} of=/data/local/tmp/boot.img bs=4096"
    adb pull /data/local/tmp/boot.img "${DEVICE_PREBUILT}/tmp/boot.img"
    adb shell "rm /data/local/tmp/boot.img"
    
    log_info "Unpacking boot image..."
    if command -v unpack_bootimg &>/dev/null; then
        mkdir -p "${DEVICE_PREBUILT}/tmp/boot_unpacked"
        unpack_bootimg --boot_img "${DEVICE_PREBUILT}/tmp/boot.img" \
                       --out "${DEVICE_PREBUILT}/tmp/boot_unpacked"
        
        if [ -f "${DEVICE_PREBUILT}/tmp/boot_unpacked/kernel" ]; then
            cp "${DEVICE_PREBUILT}/tmp/boot_unpacked/kernel" "${DEVICE_PREBUILT}/kernel"
            log_info "✓ Kernel extracted → prebuilt/kernel"
        fi
        if [ -f "${DEVICE_PREBUILT}/tmp/boot_unpacked/dtb" ]; then
            cp "${DEVICE_PREBUILT}/tmp/boot_unpacked/dtb" "${DEVICE_PREBUILT}/dtb.img"
            log_info "✓ DTB extracted → prebuilt/dtb.img"
        fi
    else
        log_warn "unpack_bootimg not found. Install AOSP tools first."
        log_warn "You can find it in: android/build/tools/releasetools/unpack_bootimg.py"
        log_warn "Alternatively: pip install bootimg"
    fi
}

# Extract dtbo image
extract_dtbo() {
    log_info "Extracting DTBO image from slot ${SLOT}..."
    
    adb shell "dd if=/dev/block/by-name/dtbo${SLOT} of=/data/local/tmp/dtbo.img bs=4096 2>/dev/null || \
               dd if=/dev/block/by-name/dtbo of=/data/local/tmp/dtbo.img bs=4096"
    adb pull /data/local/tmp/dtbo.img "${DEVICE_PREBUILT}/dtbo.img"
    adb shell "rm /data/local/tmp/dtbo.img"
    
    log_info "✓ DTBO extracted → prebuilt/dtbo.img"
}

# Extract vendor_boot
extract_vendor_boot() {
    log_info "Extracting vendor_boot image from slot ${SLOT}..."
    
    adb shell "dd if=/dev/block/by-name/vendor_boot${SLOT} of=/data/local/tmp/vendor_boot.img bs=4096"
    adb pull /data/local/tmp/vendor_boot.img "${DEVICE_PREBUILT}/tmp/vendor_boot.img"
    adb shell "rm /data/local/tmp/vendor_boot.img"
    
    log_info "✓ vendor_boot extracted"
}

# Extract kernel modules
extract_modules() {
    log_info "Extracting kernel modules..."
    mkdir -p "${DEVICE_PREBUILT}/modules"
    
    # Get modules.load list
    adb shell cat /vendor/lib/modules/modules.load > "${DEVICE_PREBUILT}/modules/vendor_boot.modules.load" 2>/dev/null || \
        adb shell cat /lib/modules/modules.load > "${DEVICE_PREBUILT}/modules/vendor_boot.modules.load" 2>/dev/null || \
        log_warn "Could not find modules.load"
    
    log_info "Module list saved. Note: actual .ko files come from vendor_dlkm partition (extracted via extract-files.sh)"
    
    # List modules
    MODULE_COUNT=$(adb shell ls /vendor/lib/modules/*.ko 2>/dev/null | wc -l | tr -d ' ' || echo "0")
    log_info "Found ${MODULE_COUNT} kernel modules on device"
}

# Display device info for verification
show_device_info() {
    log_info "=== Device Information ==="
    echo "Device: $(adb shell getprop ro.product.device 2>/dev/null)"
    echo "Model: $(adb shell getprop ro.product.model 2>/dev/null)"
    echo "Fingerprint: $(adb shell getprop ro.build.fingerprint 2>/dev/null)"
    echo "Kernel: $(adb shell uname -r 2>/dev/null)"
    echo "Slot: $(adb shell getprop ro.boot.slot_suffix 2>/dev/null)"
    echo "=========================="
}

# Main
log_info "=== Oppo Find X8 (OP5AA5L1) Kernel Extractor ==="
check_adb
show_device_info
get_slot
extract_boot
extract_dtbo
extract_vendor_boot
extract_modules

log_info "=== Extraction complete! ==="
log_info "Files saved to: ${DEVICE_PREBUILT}/"
log_info ""
log_info "Next steps:"
log_info "  1. Run extract-files.sh to pull vendor blobs"
log_info "  2. Set up your LineageOS build environment"
log_info "  3. Run: source build/envsetup.sh && lunch lineage_OP5AA5L1-userdebug"
log_info "  4. Run: mka bacon"
