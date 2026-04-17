# Tên dự án
TWEAK_NAME = Vncheat

# LỆNH THÔNG MINH: Tự động tìm tất cả file .xm, .mm, .cpp trong folder gốc và folder ImGui
Vncheat_FILES = $(wildcard *.xm) $(wildcard *.mm) $(wildcard *.cpp) $(wildcard ImGui/*.cpp) $(wildcard ImGui/*.mm)

# Các thư viện hệ thống
Vncheat_FRAMEWORKS = UIKit Foundation Security QuartzCore CoreGraphics CoreText
Vncheat_LIBRARIES = bz2 z

# Cấu hình cho iPhone
export ARCHS = arm64 arm64e
export TARGET = iphone:clang:latest:14.0

include $(THEOS)/makefiles/common.mk
include $(THEOS_MAKE_PATH)/tweak.mk
