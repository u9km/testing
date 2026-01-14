TARGET := iphone:latest:14.0
ARCHS = arm64

DEBUG = 0
FINALPACKAGE = 1

TWEAK_NAME = V12VN

# دمج الملفين هنا ضروري جداً
V12VN_FILES = Tweak.xm V12.m

V12VN_CFLAGS = -fobjc-arc -Wno-deprecated-declarations
V12VN_FRAMEWORKS = UIKit Foundation

include $(THEOS)/makefiles/common.mk
include $(THEOS_MAKE_PATH)/tweak.mk
