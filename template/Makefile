TWEAK_NAME = Vncheat

# 1. Tìm tất cả file code trong folder và folder con
Vncheat_FILES = $(shell find . -name "*.xm" -o -name "*.mm" -o -name "*.cpp" -o -name "*.m" -o -name "*.c")

# 2. ÉP LIÊN KẾT: Thêm cờ -objc và các thư viện hệ thống (Fix lỗi Undefined symbols)
Vncheat_LDFLAGS = -objc -lobjc -lsubstrate

# 3. Danh sách Framework hệ thống bắt buộc
Vncheat_FRAMEWORKS = UIKit Foundation Security QuartzCore CoreGraphics CoreText AVFoundation AudioToolbox Accelerate

# 4. Thư viện bổ trợ
Vncheat_LIBRARIES = bz2 z sqlite3 c++ iconv

# 5. Cấu hình biên dịch (Chống lỗi Xcode 16)
Vncheat_CFLAGS = -fobjc-arc -fno-modules -Wno-deprecated-declarations -Wno-error
Vncheat_CCFLAGS = -fno-modules -Wno-deprecated-declarations -Wno-error

# 6. Kiến trúc chip
export ARCHS = arm64 arm64e
export TARGET = iphone:clang:latest:15.0

include $(THEOS)/makefiles/common.mk
include $(THEOS_MAKE_PATH)/tweak.mk






