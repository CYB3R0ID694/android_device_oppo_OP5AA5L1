# Prebuilt directory structure for OP5AA5L1
# 
# This directory holds prebuilt kernel artifacts extracted from stock firmware.
# After building/extracting you should populate:
#
# prebuilt/
#   kernel          - vmlinuz (GKI kernel image)
#   dtb.img         - compiled device tree blob
#   dtbo.img        - compiled device tree overlay image
#   dtb/            - individual DTB files (optional)
#   modules/
#     vendor_boot.modules.load   - list of modules to load at boot
#     *.ko                       - kernel modules (vendor_dlkm partition's .ko files)
#   vendor_ramdisk/
#     dlkm/         - vendor ramdisk dlkm fragment
#
# === HOW TO EXTRACT ===
# 1. Boot device, then:
#    adb pull /sys/fs/pstore/console-ramdump kernel_boot.log  (optional)
#    adb pull /proc/version                                    (check kernel version)
#
# 2. Pull kernel image from boot partition:
#    adb shell dd if=/dev/block/by-name/boot_a of=/sdcard/boot_a.img
#    adb pull /sdcard/boot_a.img
#    unpack_bootimg --boot_img boot_a.img
#    cp kernel prebuilt/kernel
#    cp dtb prebuilt/dtb.img
#
# 3. Pull dtbo.img:
#    adb shell dd if=/dev/block/by-name/dtbo_a of=/sdcard/dtbo_a.img
#    adb pull /sdcard/dtbo_a.img
#    cp dtbo_a.img prebuilt/dtbo.img
#
# 4. Pull kernel modules:
#    adb pull /vendor/lib/modules/ prebuilt/modules/
#    adb pull /vendor_dlkm/lib/modules/ prebuilt/vendor_dlkm_modules/
#
# 5. Get the modules.load list:
#    adb shell cat /vendor/lib/modules/modules.load > prebuilt/modules/vendor_boot.modules.load
#
README
