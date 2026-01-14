# إعدادات الهدف (iOS)
TARGET := iphone:latest:14.0
ARCHS = arm64

# إعدادات الإنتاج (Production)
DEBUG = 0
FINALPACKAGE = 1

# اسم التويك (يجب أن يطابق اسم الـ plist)
TWEAK_NAME = V12

# ملفات المشروع
V12_FILES = V12.m

# أعلام المترجم (تفعيل ARC)
V12_CFLAGS = -fobjc-arc -Wno-deprecated-declarations

# المكتبات المطلوبة
V12_FRAMEWORKS = UIKit Foundation

include $(THEOS)/makefiles/common.mk
include $(THEOS_MAKE_PATH)/tweak.mk
