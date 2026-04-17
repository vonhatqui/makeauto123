TWEAK_NAME = Vncheat

# LỆNH VÉT CẠN: Tìm tất cả file code trong folder gốc và TẤT CẢ folder con
Vncheat_FILES = $(shell find . -name "*.xm" -o -name "*.mm" -o -name "*.cpp" -o -name "*.m" -o -name "*.c")

# Bỏ qua lỗi lệnh cũ và lỗi module
Vncheat_CFLAGS = -fobjc-arc -fno-modules -Wno-deprecated-declarations -Wno-error
Vncheat_CCFLAGS = -fno-modules -Wno-deprecated-declarations -Wno-error

# Thư viện hệ thống cần thiết cho Mod Menu
Vncheat_FRAMEWORKS = UIKit Foundation Security QuartzCore CoreGraphics CoreText
Vncheat_LIBRARIES = bz2 z

export ARCHS = arm64 arm64e
export TARGET = iphone:clang:latest:15.0

include $(THEOS)/makefiles/common.mk
include $(THEOS_MAKE_PATH)/tweak.mk



