LOCAL_PATH := $(call my-dir)
ifeq ($(TARGET_DEVICE),OP5AA5L1)
include $(call all-makefiles-under,$(LOCAL_PATH))
endif
