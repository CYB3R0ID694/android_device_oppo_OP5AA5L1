$(call inherit-product, device/oppo/OP5AA5L1/device.mk)

# Inherit some common Lineage stuff.
$(call inherit-product, vendor/lineage/config/common_full_phone.mk)

PRODUCT_NAME := lineage_OP5AA5L1
PRODUCT_DEVICE := OP5AA5L1
PRODUCT_MANUFACTURER := OPPO
PRODUCT_BRAND := OPPO
PRODUCT_MODEL := CPH2651

PRODUCT_GMS_CLIENTID_BASE := android-oppo

PRODUCT_BUILD_PROP_OVERRIDES += \
    PRIVATE_BUILD_DESC="OP5AA5L1-user 16 BP2A.250605.015 V.R4T3.22234d1_b6831_b665f release-keys"

BUILD_FINGERPRINT := OPPO/CPH2651IN/OP5AA5L1:16/BP2A.250605.015/V.R4T3.22234d1_b6831_b665f:user/release-keys
