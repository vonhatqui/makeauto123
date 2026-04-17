TWEAK_NAME = Vncheat

# LỆNH QUAN TRỌNG: Chặn lỗi Module của Xcode 16
Vncheat_CFLAGS = -fobjc-arc -fno-modules
Vncheat_CCFLAGS = -fno-modules

Vncheat_FILES = $(wildcard *.xm) $(wildcard *.mm) $(wildcard *.cpp) $(wildcard ImGui/*.cpp)
Vncheat_FRAMEWORKS = UIKit Foundation Security QuartzCore CoreGraphics CoreText
Vncheat_LIBRARIES = bz2 z

export ARCHS = arm64 arm64e
# Nâng target lên một chút để khớp với máy ảo
export TARGET = iphone:clang:latest:15.0

include $(THEOS)/makefiles/common.mk
include $(THEOS_MAKE_PATH)/tweak.mk

