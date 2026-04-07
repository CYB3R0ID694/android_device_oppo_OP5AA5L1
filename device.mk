DEVICE_PATH := device/oppo/OP5AA5L1

# Enable updating of APEXes
$(call inherit-product, $(SRC_TARGET_DIR)/product/updatable_apex.mk)

# Project name (hardware board revision)
TARGET_OTA_ALLOW_NON_AB := false

# Enable virtual A/B OTA
$(call inherit-product, $(SRC_TARGET_DIR)/product/virtual_ab_ota/launch_with_vendor_ramdisk.mk)

# A/B OTA dexopt
$(call inherit-product, $(SRC_TARGET_DIR)/product/abt_otadexopt_vm.mk)

# Installs gsi keys into ramdisk, to boot a developer GSI with verified boot
$(call inherit-product, $(SRC_TARGET_DIR)/product/developer_gsi_keys.mk)

# Setup dalvik vm configs
$(call inherit-product, frameworks/native/build/phone-xhdpi-6144-dalvik-heap.mk)

# Partitions - fstab
PRODUCT_COPY_FILES += \
    $(DEVICE_PATH)/rootdir/etc/fstab.mt6991:$(TARGET_COPY_OUT_VENDOR_RAMDISK)/first_stage_ramdisk/fstab.mt6991 \
    $(DEVICE_PATH)/rootdir/etc/fstab.mt6991:$(TARGET_COPY_OUT_VENDOR)/etc/fstab.mt6991

# Init scripts
PRODUCT_COPY_FILES += \
    $(DEVICE_PATH)/rootdir/etc/init.mt6991.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/init.mt6991.rc \
    $(DEVICE_PATH)/rootdir/etc/init.mt6991.usb.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/init.mt6991.usb.rc \
    $(DEVICE_PATH)/rootdir/etc/ueventd.rc:$(TARGET_COPY_OUT_VENDOR)/etc/ueventd.rc \
    $(DEVICE_PATH)/rootdir/etc/init.recovery.mt6991.rc:recovery/root/init.recovery.mt6991.rc

# Overlays (RROs via Android.bp)
PRODUCT_PACKAGES += \
    FrameworksResOverlay \
    WifiResOverlay

PRODUCT_ENFORCE_RRO_TARGETS := *
PRODUCT_ENFORCE_RRO_EXCLUDED_OVERLAYS += $(DEVICE_PATH)/overlay
DEVICE_PACKAGE_OVERLAYS += $(DEVICE_PATH)/overlay

# Soong namespaces
PRODUCT_SOONG_NAMESPACES += \
    $(DEVICE_PATH) \
    hardware/mediatek

# AAPT
PRODUCT_AAPT_CONFIG := normal
PRODUCT_AAPT_PREF_CONFIG := xxxhdpi
PRODUCT_AAPT_PREBUILT_DPI := xxxhdpi xxhdpi xhdpi hdpi

# Boot animation
TARGET_SCREEN_HEIGHT := 2760
TARGET_SCREEN_WIDTH := 1256

# Audio
$(call soong_config_set, android_hardware_audio, run_64bit, true)
PRODUCT_PACKAGES += \
    android.hardware.audio@7.1-impl \
    android.hardware.audio.effect@7.0-impl \
    android.hardware.audio.service \
    android.hardware.bluetooth.audio-impl \
    audio.bluetooth.default \
    audio.r_submix.default \
    audio.usb.default \
    libaudiopreprocessing \
    libbluetooth_audio_session \
    libalsautils \
    libnbaio_mono \
    libtinycompress \
    libdynproc \
    libhapticgenerator \
    libstagefright_softomx_plugin

PRODUCT_COPY_FILES += \
    $(DEVICE_PATH)/configs/audio/audio_device.xml:$(TARGET_COPY_OUT_VENDOR)/etc/audio_device.xml \
    $(DEVICE_PATH)/configs/audio/audio_effects.xml:$(TARGET_COPY_OUT_VENDOR)/etc/audio_effects.xml \
    $(DEVICE_PATH)/configs/audio/audio_em.xml:$(TARGET_COPY_OUT_VENDOR)/etc/audio_em.xml \
    $(DEVICE_PATH)/configs/audio/audio_policy_configuration.xml:$(TARGET_COPY_OUT_VENDOR)/etc/audio_policy_configuration.xml

# Bluetooth
PRODUCT_PACKAGES += \
    android.hardware.bluetooth@1.1-impl-qti \
    android.hardware.bluetooth@1.1-service

# Camera
PRODUCT_PACKAGES += \
    android.hardware.camera.provider@2.6-impl \
    android.hardware.camera.provider@2.6-service_64 \
    libcamera_metadata

# Display
PRODUCT_PACKAGES += \
    android.hardware.graphics.composer@2.3-service \
    libdrm \
    libvulkan

# Fingerprint
PRODUCT_PACKAGES += \
    android.hardware.biometrics.fingerprint@2.3-service.oplus

# Gatekeeper
PRODUCT_PACKAGES += \
    android.hardware.gatekeeper@1.0-impl \
    android.hardware.gatekeeper@1.0-service

# Health
PRODUCT_PACKAGES += \
    android.hardware.health@2.1-impl \
    android.hardware.health@2.1-impl.recovery \
    android.hardware.health@2.1-service

# HIDL
PRODUCT_PACKAGES += \
    android.hidl.base@1.0 \
    android.hidl.manager@1.0

# Keymaster
PRODUCT_PACKAGES += \
    android.hardware.keymaster@4.1-service \
    libkeymaster4support \
    libkeymaster41

# Lights
PRODUCT_PACKAGES += \
    android.hardware.light-service.mt6991

# Media
PRODUCT_PACKAGES += \
    libavservices_minijail \
    libavservices_minijail_vendor \
    libstagefright_softomx

PRODUCT_COPY_FILES += \
    $(DEVICE_PATH)/configs/media/media_codecs.xml:$(TARGET_COPY_OUT_VENDOR)/etc/media_codecs.xml \
    $(DEVICE_PATH)/configs/media/media_codecs_performance.xml:$(TARGET_COPY_OUT_VENDOR)/etc/media_codecs_performance.xml \
    $(DEVICE_PATH)/configs/media/media_profiles_V1_0.xml:$(TARGET_COPY_OUT_VENDOR)/etc/media_profiles_V1_0.xml

PRODUCT_COPY_FILES += \
    frameworks/av/media/libstagefright/data/media_codecs_google_audio.xml:$(TARGET_COPY_OUT_VENDOR)/etc/media_codecs_google_audio.xml \
    frameworks/av/media/libstagefright/data/media_codecs_google_video.xml:$(TARGET_COPY_OUT_VENDOR)/etc/media_codecs_google_video.xml

# NFC
PRODUCT_PACKAGES += \
    NfcNci \
    Tag \
    android.hardware.nfc@1.2-service

# Neural Networks
PRODUCT_PACKAGES += \
    android.hardware.neuralnetworks-service-mtk

# OTA
PRODUCT_PACKAGES += \
    update_engine \
    update_engine_sideload \
    update_verifier \
    otapreopt_script \
    cppreopts.sh

# Perf
PRODUCT_PACKAGES += \
    android.hardware.power@1.3-service.mediatek-libperfmgr

PRODUCT_COPY_FILES += \
    $(DEVICE_PATH)/configs/perf/powerhint.json:$(TARGET_COPY_OUT_VENDOR)/etc/powerhint.json

# Power Off Alarm
PRODUCT_PACKAGES += \
    PowerOffAlarm

# Rootdir
PRODUCT_PACKAGES += \
    fstab.mt6991 \
    init.mt6991.rc \
    init.mt6991.usb.rc \
    ueventd.rc

# Sensors
PRODUCT_PACKAGES += \
    android.hardware.sensors@2.1-service.multihal

# Thermal
PRODUCT_PACKAGES += \
    android.hardware.thermal@2.0-service.mediatek

PRODUCT_COPY_FILES += \
    $(DEVICE_PATH)/configs/thermal/.thermal_policy:$(TARGET_COPY_OUT_VENDOR)/etc/.thermal_policy_00

# USB
PRODUCT_PACKAGES += \
    android.hardware.usb@1.3-service-mtkdefault

# Vibrator
PRODUCT_PACKAGES += \
    android.hardware.vibrator-service.mediatek

# Wi-Fi
PRODUCT_PACKAGES += \
    android.hardware.wifi@1.6-service \
    hostapd \
    wpa_supplicant \
    wpa_supplicant.conf

PRODUCT_COPY_FILES += \
    $(DEVICE_PATH)/configs/wifi/p2p_supplicant_overlay.conf:$(TARGET_COPY_OUT_VENDOR)/etc/wifi/p2p_supplicant_overlay.conf \
    $(DEVICE_PATH)/configs/wifi/wpa_supplicant_overlay.conf:$(TARGET_COPY_OUT_VENDOR)/etc/wifi/wpa_supplicant_overlay.conf

# Shipping API level (device launched on Android 15)
PRODUCT_SHIPPING_API_LEVEL := 35

# GKI / Kernel modules
PRODUCT_PACKAGES += \
    init.insmod.sh

# Kernel modules load list (populated after extract-kernel.sh)
ifneq ($(wildcard $(DEVICE_PATH)/prebuilt/modules/vendor_boot.modules.load),)
PRODUCT_COPY_FILES += \
    $(DEVICE_PATH)/prebuilt/modules/vendor_boot.modules.load:$(TARGET_COPY_OUT_VENDOR_RAMDISK)/lib/modules/modules.load
endif

# Power
PRODUCT_COPY_FILES += \
    $(DEVICE_PATH)/configs/perf/powerhint.json:$(TARGET_COPY_OUT_VENDOR)/etc/powerhint.json

# Telephony
PRODUCT_PACKAGES += \
    telephony-ext

# Lineage extras
PRODUCT_PACKAGES += \
    libprotobuf-cpp-full-vendorcompat \
    libprotobuf-cpp-lite-vendorcompat

# Inherit vendor blobs (populated after running extract-files.sh)
$(call inherit-product, vendor/oppo/OP5AA5L1/OP5AA5L1-vendor.mk)
