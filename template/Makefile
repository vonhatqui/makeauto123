# Đặt tên dự án là Vncheat
TWEAK_NAME = Vncheat

# Chỉ định các file cần build (Đại ca kiểm tra xem folder có đúng file Tweak.xm và Menu.mm không nhé)
Vncheat_FILES = Tweak.xm Menu.mm ImGui/imgui.cpp ImGui/imgui_draw.cpp ImGui/imgui_demo.cpp ImGui/imgui_widgets.cpp

# Các thư viện bắt buộc để Menu hoạt động
Vncheat_FRAMEWORKS = UIKit Foundation Security QuartzCore CoreGraphics CoreText

# Cấu hình biên dịch cho chip iPhone đời mới (arm64 và arm64e)
export ARCHS = arm64 arm64e
export TARGET = iphone:clang:latest:14.0

include $(THEOS)/makefiles/common.mk
include $(THEOS_MAKE_PATH)/tweak.mk
