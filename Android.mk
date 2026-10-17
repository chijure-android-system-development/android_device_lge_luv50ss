LOCAL_PATH := $(call my-dir)

ifeq ($(TARGET_DEVICE),luv50ss)
include $(call all-makefiles-under,$(LOCAL_PATH))
endif
