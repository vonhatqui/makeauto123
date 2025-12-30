//
//  Menu.h
//  ModMenu
//
//  Created by Joey on 3/14/19.
//  Updated by ABS on 28/12/25.
//  Copyright © 2025 Joey. All rights reserved.
//

#import "UIKit/UIKit.h"
#import "KittyMemory/MemoryPatch.hpp"
#import "SCLAlertView/SCLAlertView.h"

#import <vector>
#import <initializer_list>

#define UIColorFromHex(hexColor) [UIColor colorWithRed:((float)((hexColor & 0xFF0000) >> 16))/255.0 green:((float)((hexColor & 0xFF00) >> 8))/255.0 blue:((float)(hexColor & 0xFF))/255.0 alpha:1.0]

@class Category;
@class OffsetSwitch;
@class TextFieldSwitch;
@class SliderSwitch;
@class Switches;

@interface Menu : UIView

-(bool)inited;
-(bool)needInit;
-(id)initWithTitle:(NSString *)title_ titleColor:(UIColor *)titleColor_ titleFont:(NSString *)titleFont_ credits:(NSString *)credits_ headerColor:(UIColor *)headerColor_ addInfoTitleColor:(UIColor *)categoryColor_ switchOffColor:(UIColor *)switchOffColor_ switchOnColor:(UIColor *)switchOnColor_ switchTitleFont:(NSString *)switchTitleFont_ switchTitleColor:(UIColor *)switchTitleColor_ infoButtonColor:(UIColor *)infoButtonColor_ maxVisibleSwitches:(int)maxVisibleSwitches_ menuWidth:(CGFloat )menuWidth_ menuIcon:(NSString *)menuIconBase64_ menuButton:(NSString *)menuButtonBase64_;
-(void)setFrameworkName:(const char *)name_;
-(const char *)getFrameworkName;


-(void)showMenuButton;
-(void)addSwitchToMenu:(id)switch_;
-(void)addInfoToMenu:(id)info_;
-(void)showPopup:(NSString *)title_ description:(NSString *)description_;
-(void)restoreForced;

@end

@interface Category : UIView {
	UILabel *categoryLabel;
}

-(id)initCategory:(NSString *)description_ height:(int)height_;
-(int)getHeight;

@end

@interface OffsetSwitch : UIButton {
	NSString *preferencesKey;
	NSString *description;
    UILabel *switchLabel;
}

- (id)initHackNamed:(NSString *)hackName_ description:(NSString *)description_ offsets:(std::vector<std::string>)offsets_ bytes:(std::vector<std::string>)bytes_;
-(void)showInfo:(UIGestureRecognizer *)gestureRec;

-(NSString *)getPreferencesKey;
-(NSString *)getDescription;
- (std::vector<MemoryPatch>)getMemoryPatches;


@end

@interface TextFieldSwitch : OffsetSwitch<UITextFieldDelegate> {
	NSString *switchValueKey;
}

- (id)initTextfieldNamed:(NSString *)hackName_ description:(NSString *)description_ inputBorderColor:(UIColor *)inputBorderColor_;

-(NSString *)getSwitchValueKey;

@end

@interface SliderSwitch : TextFieldSwitch

- (id)initSliderNamed:(NSString *)hackName_ description:(NSString *)description_ minimumValue:(float)minimumValue_ maximumValue:(float)maximumValue_ sliderColor:(UIColor *)sliderColor_;

@end


@interface Switches : UIButton

-(void)addInfo:(NSString *)description_ height:(std::string)height_;

-(void)addSwitch:(NSString *)hackName_ description:(NSString *)description_;

- (void)addOffsetSwitch:(NSString *)hackName_ description:(NSString *)description_ offsets:(std::initializer_list<std::string>)offsets_ data:(std::initializer_list<std::string>)bytes_;

- (void)addOffsetSwitch:(NSString *)hackName_ description:(NSString *)description_ roots:(std::initializer_list<std::string>)roots_ offsets:(std::initializer_list<std::string>)offsets_ data:(std::initializer_list<std::string>)bytes_;

- (void)addTextfieldSwitch:(NSString *)hackName_ description:(NSString *)description_ inputBorderColor:(UIColor *)inputBorderColor_;

- (void)addSliderSwitch:(NSString *)hackName_ description:(NSString *)description_ minimumValue:(float)minimumValue_ maximumValue:(float)maximumValue_ sliderColor:(UIColor *)sliderColor_;

- (NSString *)getValueFromSwitch:(NSString *)name;
-(bool)isSwitchOn:(NSString *)switchName;

@end