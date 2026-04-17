TWEAK_NAME = Vncheat

# 1. Tự động tìm tất cả file code
Vncheat_FILES = $(shell find . -name "*.xm" -o -name "*.mm" -o -name "*.cpp" -o -name "*.m" -o -name "*.c")

# 2. Ép nạp thư viện Objective-C và Substrate (Fix lỗi Undefined symbols)
Vncheat_LDFLAGS = -lobjc -lsubstrate

# 3. Thêm các Framework hệ thống cần thiết
Vncheat_FRAMEWORKS = UIKit Foundation Security QuartzCore CoreGraphics CoreText AVFoundation AudioToolbox Accelerate

# 4. Thêm thư viện hỗ trợ
Vncheat_LIBRARIES = bz2 z sqlite3 c++ iconv

# 5. Cấu hình biên dịch và chặn lỗi Module
Vncheat_CFLAGS = -fobjc-arc -fno-modules -Wno-deprecated-declarations -Wno-error
Vncheat_CCFLAGS = -fno-modules -Wno-deprecated-declarations -Wno-error

# 6. Cấu hình kiến trúc
export ARCHS = arm64 arm64e
export TARGET = iphone:clang:latest:15.0

include $(THEOS)/makefiles/common.mk
include $(THEOS_MAKE_PATH)/tweak.mk





