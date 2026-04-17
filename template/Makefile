TWEAK_NAME = Vncheat

# LỆNH THẦN THÁNH: Bỏ qua các cảnh báo lệnh cũ (deprecated) và chặn lỗi module
Vncheat_CFLAGS = -fobjc-arc -fno-modules -Wno-deprecated-declarations -Wno-error
Vncheat_CCFLAGS = -fno-modules -Wno-deprecated-declarations -Wno-error

Vncheat_FILES = $(wildcard *.xm) $(wildcard *.mm) $(wildcard *.cpp) $(wildcard ImGui/*.cpp)
Vncheat_FRAMEWORKS = UIKit Foundation Security QuartzCore CoreGraphics CoreText
Vncheat_LIBRARIES = bz2 z

export ARCHS = arm64 arm64e
export TARGET = iphone:clang:latest:15.0

include $(THEOS)/makefiles/common.mk
include $(THEOS_MAKE_PATH)/tweak.mk


