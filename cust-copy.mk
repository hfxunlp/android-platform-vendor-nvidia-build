# Generated by release script
LOCAL_PATH := $(call my-dir)
ifeq ($(patsubst tegra%,tegra,$(TARGET_BOARD_PLATFORM)),tegra)
include $(LOCAL_PATH)/prebuilt/${REFERENCE_DEVICE}/generated_built.mk
endif
