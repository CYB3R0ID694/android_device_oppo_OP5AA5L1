#!/usr/bin/env bash
#
# extract-blobs-adb.sh
# Comprehensive ADB-based vendor blob extractor for Oppo Find X8 (OP5AA5L1)
#
# This script pulls ALL necessary vendor blobs from a rooted device and
# also extracts kernel artifacts in one pass.
#
# Usage:
#   1. Connect your Find X8, enable USB Debugging + ADB root
#   2. cd <LineageOS_source_root>
#   3. bash device/oppo/OP5AA5L1/extract-blobs-adb.sh
#
# Output: vendor/oppo/OP5AA5L1/ populated with all blobs

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ANDROID_ROOT="${SCRIPT_DIR}/../../.."
VENDOR_PATH="${ANDROID_ROOT}/vendor/oppo/OP5AA5L1"
PREBUILT_PATH="${SCRIPT_DIR}/prebuilt"
DEVICE="OP5AA5L1"
VENDOR="oppo"

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; NC='\033[0m'
log_info()  { echo -e "${GREEN}[INFO]${NC}  $*"; }
log_warn()  { echo -e "${YELLOW}[WARN]${NC}  $*"; }
log_error() { echo -e "${RED}[ERROR]${NC} $*"; }
log_step()  { echo -e "\n${CYAN}==== $* ====${NC}"; }

# ── ADB helpers ────────────────────────────────────────────────────────────────
check_adb() {
    if ! command -v adb &>/dev/null; then
        log_error "adb not found. Install Android Platform Tools."
        exit 1
    fi
    if ! adb devices | grep -q "device$"; then
        log_error "No device found. Connect your Find X8 and enable USB Debugging."
        exit 1
    fi
    adb root &>/dev/null && sleep 2 || log_warn "Could not get root. Some extracts may fail."
    local dev
    dev=$(adb shell getprop ro.product.device 2>/dev/null | tr -d '\r')
    if [[ "$dev" != "OP5AA5L1" ]]; then
        log_warn "Device codename is '${dev}', expected 'OP5AA5L1'. Continuing anyway..."
    fi
    log_info "Connected: $(adb shell getprop ro.product.model | tr -d '\r') (${dev})"
    log_info "Build: $(adb shell getprop ro.build.fingerprint | tr -d '\r')"
}

adb_pull_file() {
    local src="$1" dst="$2"
    mkdir -p "$(dirname "$dst")"
    if adb shell "[ -f '${src}' ]" 2>/dev/null; then
        adb pull "$src" "$dst" &>/dev/null && return 0
    fi
    return 1
}

adb_pull_dir() {
    local src="$1" dst="$2"
    mkdir -p "$dst"
    adb pull "$src" "$dst" &>/dev/null || true
}

# ── Slot detection ─────────────────────────────────────────────────────────────
get_active_slot() {
    local slot
    slot=$(adb shell getprop ro.boot.slot_suffix 2>/dev/null | tr -d '\r')
    echo "${slot:-_a}"
}

# ── 1. Kernel artifacts ────────────────────────────────────────────────────────
extract_kernel_artifacts() {
    log_step "Extracting Kernel Artifacts"
    mkdir -p "${PREBUILT_PATH}/tmp" "${PREBUILT_PATH}/modules"

    local slot
    slot=$(get_active_slot)
    log_info "Active slot: ${slot}"

    # boot image
    log_info "Pulling boot${slot}..."
    adb shell "dd if=/dev/block/by-name/boot${slot} of=/data/local/tmp/boot.img bs=4096 2>/dev/null"
    adb pull /data/local/tmp/boot.img "${PREBUILT_PATH}/tmp/boot.img" &>/dev/null
    adb shell "rm -f /data/local/tmp/boot.img" &>/dev/null

    # dtbo image
    log_info "Pulling dtbo${slot}..."
    adb shell "dd if=/dev/block/by-name/dtbo${slot} of=/data/local/tmp/dtbo.img bs=4096 2>/dev/null" || \
        adb shell "dd if=/dev/block/by-name/dtbo of=/data/local/tmp/dtbo.img bs=4096 2>/dev/null" || true
    adb pull /data/local/tmp/dtbo.img "${PREBUILT_PATH}/dtbo.img" &>/dev/null || true
    adb shell "rm -f /data/local/tmp/dtbo.img" &>/dev/null

    # vendor_boot
    log_info "Pulling vendor_boot${slot}..."
    adb shell "dd if=/dev/block/by-name/vendor_boot${slot} of=/data/local/tmp/vendor_boot.img bs=4096 2>/dev/null"
    adb pull /data/local/tmp/vendor_boot.img "${PREBUILT_PATH}/tmp/vendor_boot.img" &>/dev/null
    adb shell "rm -f /data/local/tmp/vendor_boot.img" &>/dev/null

    # Try to unpack boot image for kernel + dtb
    if command -v unpack_bootimg &>/dev/null; then
        mkdir -p "${PREBUILT_PATH}/tmp/boot_out"
        unpack_bootimg --boot_img "${PREBUILT_PATH}/tmp/boot.img" \
                       --out "${PREBUILT_PATH}/tmp/boot_out" &>/dev/null || true
        [[ -f "${PREBUILT_PATH}/tmp/boot_out/kernel" ]] && \
            cp "${PREBUILT_PATH}/tmp/boot_out/kernel" "${PREBUILT_PATH}/kernel" && \
            log_info "✓ kernel"
        [[ -f "${PREBUILT_PATH}/tmp/boot_out/dtb" ]] && \
            cp "${PREBUILT_PATH}/tmp/boot_out/dtb" "${PREBUILT_PATH}/dtb.img" && \
            log_info "✓ dtb.img"
    else
        log_warn "unpack_bootimg not found — boot images saved to prebuilt/tmp/ for manual unpacking"
        log_warn "Install with: pip install bootimg  OR  build from AOSP"
    fi

    # Modules load list
    adb shell "cat /vendor/lib/modules/modules.load 2>/dev/null || cat /lib/modules/\$(uname -r)/modules.load 2>/dev/null" \
        | tr -d '\r' > "${PREBUILT_PATH}/modules/vendor_boot.modules.load" 2>/dev/null || true
    log_info "✓ modules.load ($(wc -l < "${PREBUILT_PATH}/modules/vendor_boot.modules.load") entries)"
}

# ── 2. Vendor partition blobs ──────────────────────────────────────────────────
extract_vendor_blobs() {
    log_step "Extracting Vendor Partition"
    mkdir -p "${VENDOR_PATH}/proprietary"

    # Critical paths to extract
    local VENDOR_DIRS=(
        "vendor/lib64/hw"
        "vendor/lib64/egl"
        "vendor/lib64/soundfx"
        "vendor/lib/hw"
        "vendor/lib/egl"
        "vendor/bin/hw"
        "vendor/bin"
        "vendor/etc"
        "vendor/firmware"
    )

    for dir in "${VENDOR_DIRS[@]}"; do
        log_info "Pulling /${dir}/ ..."
        mkdir -p "${VENDOR_PATH}/proprietary/${dir}"
        adb pull "/${dir}" "${VENDOR_PATH}/proprietary/$(dirname "${dir}")/" &>/dev/null || \
            log_warn "  Failed to pull ${dir}"
    done

    # Also pull top-level vendor lib64 / lib
    log_info "Pulling /vendor/lib64/*.so ..."
    adb shell "ls /vendor/lib64/*.so 2>/dev/null" | tr -d '\r' | while read -r f; do
        adb_pull_file "$f" "${VENDOR_PATH}/proprietary/vendor/lib64/$(basename "$f")" || true
    done

    log_info "Pulling /vendor/lib/*.so ..."
    adb shell "ls /vendor/lib/*.so 2>/dev/null" | tr -d '\r' | while read -r f; do
        adb_pull_file "$f" "${VENDOR_PATH}/proprietary/vendor/lib/$(basename "$f")" || true
    done
}

# ── 3. ODM partition ───────────────────────────────────────────────────────────
extract_odm_blobs() {
    log_step "Extracting ODM Partition"
    mkdir -p "${VENDOR_PATH}/proprietary/odm"
    adb pull /odm "${VENDOR_PATH}/proprietary/" &>/dev/null || \
        log_warn "ODM extraction failed (expected on some builds)"
}

# ── 4. Config files ────────────────────────────────────────────────────────────
extract_config_files() {
    log_step "Extracting Config Files"

    local AUDIO_CONFIGS="audio_device.xml audio_effects.xml audio_em.xml audio_policy_configuration.xml"
    for cfg in $AUDIO_CONFIGS; do
        if adb_pull_file "/vendor/etc/${cfg}" "${SCRIPT_DIR}/configs/audio/${cfg}"; then
            log_info "✓ configs/audio/${cfg}"
        fi
    done

    local MEDIA_CONFIGS="media_codecs.xml media_codecs_performance.xml media_profiles_V1_0.xml"
    for cfg in $MEDIA_CONFIGS; do
        if adb_pull_file "/vendor/etc/${cfg}" "${SCRIPT_DIR}/configs/media/${cfg}"; then
            log_info "✓ configs/media/${cfg}"
        fi
    done

    # Power hint
    if adb_pull_file "/vendor/etc/powerhint.json" "${SCRIPT_DIR}/configs/perf/powerhint.json"; then
        log_info "✓ configs/perf/powerhint.json"
    fi

    # Thermal
    if adb_pull_file "/vendor/etc/.thermal_policy_00" "${SCRIPT_DIR}/configs/thermal/.thermal_policy_00"; then
        log_info "✓ thermal policy"
    fi
}

# ── 5. Generate proprietary-files.txt ─────────────────────────────────────────
generate_proprietary_files_list() {
    log_step "Generating proprietary-files.txt"

    local tmp_list="/tmp/op5aa5l1_blobs_$$.txt"

    # Find all files in vendor and odm partitions
    adb shell "find /vendor /odm -type f 2>/dev/null | \
        grep -v '\.xml$' | grep -v '\.conf$' | grep -v '\.json$' | \
        grep -v '\.txt$' | grep -v '\.prop$' | \
        sort" | tr -d '\r' > "$tmp_list"

    local count
    count=$(wc -l < "$tmp_list" | tr -d ' ')
    log_info "Found ${count} binary blobs"

    # Convert absolute paths to relative (strip leading /) and format for proprietary-files.txt
    {
        echo "# Auto-generated by extract-blobs-adb.sh"
        echo "# Device: Oppo Find X8 (OP5AA5L1)"
        echo "# Build: $(adb shell getprop ro.build.fingerprint 2>/dev/null | tr -d '\r')"
        echo "# Generated: $(date -u)"
        echo ""
        echo "# Vendor blobs"
        grep "^/vendor/" "$tmp_list" | sed 's|^/||'
        echo ""
        echo "# ODM blobs"
        grep "^/odm/" "$tmp_list" | sed 's|^/||' || true
    } > "${SCRIPT_DIR}/proprietary-files.txt"

    log_info "✓ Written ${count} entries to proprietary-files.txt"
    rm -f "$tmp_list"
}

# ── 6. Generate vendor makefiles ───────────────────────────────────────────────
generate_vendor_makefiles() {
    log_step "Generating Vendor Makefiles"

    mkdir -p "${VENDOR_PATH}"

    cat > "${VENDOR_PATH}/Android.bp" << 'ANDROID_BP'
// Auto-generated vendor Android.bp
soong_namespace {
}
ANDROID_BP

    cat > "${VENDOR_PATH}/Android.mk" << 'ANDROID_MK'
LOCAL_PATH := $(call my-dir)
ifeq ($(TARGET_DEVICE),OP5AA5L1)
include $(call all-makefiles-under,$(LOCAL_PATH))
endif
ANDROID_MK

    # Generate OP5AA5L1-vendor.mk with PRODUCT_COPY_FILES entries
    {
        echo "# Vendor blobs for OP5AA5L1"
        echo "# Auto-generated by extract-blobs-adb.sh"
        echo ""
        echo "PRODUCT_SOONG_NAMESPACES += vendor/oppo/OP5AA5L1"
        echo ""
        echo "# Copy vendor files"
        # We'll generate from what was actually pulled
        if [[ -d "${VENDOR_PATH}/proprietary/vendor" ]]; then
            find "${VENDOR_PATH}/proprietary/vendor" -type f | while read -r f; do
                local rel="${f#${VENDOR_PATH}/proprietary/}"
                echo "PRODUCT_COPY_FILES += \\"
                echo "    vendor/oppo/OP5AA5L1/proprietary/${rel}:\$(TARGET_COPY_OUT_VENDOR)/${rel#vendor/}"
            done
        fi
    } > "${VENDOR_PATH}/OP5AA5L1-vendor.mk"

    log_info "✓ Vendor makefiles generated"
}

# ── Main ───────────────────────────────────────────────────────────────────────
main() {
    echo ""
    echo -e "${GREEN}╔══════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║   Oppo Find X8 (OP5AA5L1) — Blob Extractor          ║${NC}"
    echo -e "${GREEN}║   LineageOS 23.1 / Android 16                        ║${NC}"
    echo -e "${GREEN}╚══════════════════════════════════════════════════════╝${NC}"
    echo ""

    check_adb
    extract_kernel_artifacts
    extract_vendor_blobs
    extract_odm_blobs
    extract_config_files
    generate_proprietary_files_list
    generate_vendor_makefiles

    echo ""
    log_step "Extraction Complete!"
    echo ""
    log_info "Summary:"
    log_info "  Kernel artifacts → ${PREBUILT_PATH}/"
    log_info "  Vendor blobs     → ${VENDOR_PATH}/proprietary/"
    log_info "  Config files     → ${SCRIPT_DIR}/configs/"
    log_info "  Blob list        → ${SCRIPT_DIR}/proprietary-files.txt"
    log_info "  Vendor makefiles → ${VENDOR_PATH}/"
    echo ""
    log_info "Next: Set up your build environment and run:"
    echo "  source build/envsetup.sh"
    echo "  lunch lineage_OP5AA5L1-userdebug"
    echo "  mka bacon"
    echo ""
}

main "$@"
