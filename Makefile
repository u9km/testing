ARCHS = arm64
TARGET = iphone:clang:latest:latest

# تأكد أن هذا هو معرف اللعبة الصحيح (عالمية: com.tencent.ig)
INSTALL_TARGET_PROCESSES = com.tencent.ig

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = MuntadharSafeMod

# ملف واحد فقط
MuntadharSafeMod_FILES = Tweak.xm

# تفعيل ARC والسماح بأكواد C++ المختلطة
MuntadharSafeMod_CFLAGS = -fobjc-arc -Wno-deprecated-declarations

include $(THEOS_MAKE_PATH)/tweak.mk
