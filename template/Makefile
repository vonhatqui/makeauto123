TWEAK_NAME = Vncheat

# 1. Tự động tìm tất cả file code
Vncheat_FILES = $(shell find . -name "*.xm" -o -name "*.mm" -o -name "*.cpp" -o -name "*.m" -o -name "*.c")

# 2. Cấu hình Linker mạnh tay: Dùng Linker Classic để tránh lỗi symbol trên Xcode mới
Vncheat_LDFLAGS = -Wl,-ld_classic -lobjc -lsubstrate

# 3. Frameworks: Thêm CoreFoundation và bỏ bớt mấy cái gây lỗi auto-link
Vncheat_FRAMEWORKS = UIKit Foundation CoreGraphics QuartzCore CoreText Security CoreFoundation

# 4. Thư viện bổ trợ
Vncheat_LIBRARIES = bz2 z sqlite3 c++ iconv

# 5. Cờ biên dịch: Chống lỗi Module và tối ưu hóa
Vncheat_CFLAGS = -fobjc-arc -fno-modules -Wno-deprecated-declarations -Wno-error
Vncheat_CCFLAGS = -fno-modules -Wno-deprecated-declarations -Wno-error

# 6. Kiến trúc và Target
export ARCHS = arm64 arm64e
export TARGET = iphone:clang:latest:14.0

include $(THEOS)/makefiles/common.mk
include $(THEOS_MAKE_PATH)/tweak.mk







