TWEAK_NAME = Vncheat

# 1. Tự động tìm tất cả file code
Vncheat_FILES = $(shell find . -name "*.xm" -o -name "*.mm" -o -name "*.cpp" -o -name "*.m" -o -name "*.c")

# 2. Thêm các Framework hệ thống còn thiếu (Đặc biệt là AVFoundation và AudioToolbox)
Vncheat_FRAMEWORKS = UIKit Foundation Security QuartzCore CoreGraphics CoreText AVFoundation AudioToolbox Accelerate

# 3. Liên kết với thư viện CydiaSubstrate và Objective-C Runtime
Vncheat_LIBRARIES = substrate bz2 z sqlite3 c++ iconv

# 4. Cấu hình biên dịch và chặn lỗi Module Xcode 16
# Thêm -fobjc-arc nếu code của Đại ca dùng ARC
Vncheat_CFLAGS = -fobjc-arc -fno-modules -Wno-deprecated-declarations -Wno-error
Vncheat_CCFLAGS = -fno-modules -Wno-deprecated-declarations -Wno-error

# 5. Cấu hình kiến trúc và Target
export ARCHS = arm64 arm64e
export TARGET = iphone:clang:latest:15.0

include $(THEOS)/makefiles/common.mk
include $(THEOS_MAKE_PATH)/tweak.mk




