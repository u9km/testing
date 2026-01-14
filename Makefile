ARCHS = arm64
TARGET = iphone:clang:latest:latest
INSTALL_TARGET_PROCESSES = com.tencent.ig

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = MuntadharProtection

# الملف هو Tweak.xm لكن سيتم تجميعه كـ Objective-C++
MuntadharProtection_FILES = Tweak.xm
MuntadharProtection_CFLAGS = -fobjc-arc -Wno-deprecated-declarations

include $(THEOS_MAKE_PATH)/tweak.mk
