//
//  Menu.m
//  ModMenu
//
//  Created by Joey on 3/14/19.
//  Updated by ABS on 28/12/25.
//  Copyright © 2025 Joey. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Obfuscate.h"
#import <dlfcn.h>
#import "Menu.h"

@interface Menu ()

@property (assign, nonatomic) CGPoint lastMenuLocation;
@property (strong, nonatomic) UILabel *menuTitle;
@property (strong, nonatomic) UIView *header;
@property (strong, nonatomic) UIView *footer;

@end


@implementation Menu

NSUserDefaults *defaults;

UIScrollView *scrollView;
CGFloat menuWidth;
CGFloat scrollViewX;
NSString *credits;
UIColor *categoryColor;
UIColor *switchOnColor;
NSString *switchTitleFont;
UIColor *switchTitleColor;
UIColor *infoButtonColor;
NSString *menuIconBase64;
NSString *menuButtonBase64;
float scrollViewHeight = 0;
BOOL hasRestoredLastSession = false;
UIButton *menuButton;

const char *frameworkName = NULL;

UIWindow *mainWindow;


// init the menu
// global variabls, extern in Macros.h
Menu *menu = [Menu alloc];
Switches *switches = [Switches alloc];
-(bool)inited {
    return MenuInited;
}
-(bool)needInit {
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Wdeprecated-declarations"
    if([UIApplication sharedApplication].keyWindow != NULL) {
        if(!MenuInited) {
            MenuInited = true;
            return MenuInited;
        }
    }
    return false;
    #pragma clang diagnostic pop
}


-(id)initWithTitle:(NSString *)title_ titleColor:(UIColor *)titleColor_ titleFont:(NSString *)titleFont_ credits:(NSString *)credits_ headerColor:(UIColor *)headerColor_ addInfoTitleColor:(UIColor *)categoryColor_ switchOffColor:(UIColor *)switchOffColor_ switchOnColor:(UIColor *)switchOnColor_ switchTitleFont:(NSString *)switchTitleFont_ switchTitleColor:(UIColor *)switchTitleColor_ infoButtonColor:(UIColor *)infoButtonColor_ maxVisibleSwitches:(int)maxVisibleSwitches_ menuWidth:(CGFloat )menuWidth_ menuIcon:(NSString *)menuIconBase64_ menuButton:(NSString *)menuButtonBase64_ {
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Wdeprecated-declarations"
    mainWindow = [UIApplication sharedApplication].keyWindow;
    #pragma clang diagnostic pop 
    defaults = [NSUserDefaults standardUserDefaults];

    menuWidth = menuWidth_;
    switchOnColor = switchOnColor_;
    credits = credits_;
    categoryColor = categoryColor_;
    switchTitleFont = switchTitleFont_;
    switchTitleColor = switchTitleColor_;
    infoButtonColor = infoButtonColor_;
    menuButtonBase64 = menuButtonBase64_;

    // Base of the Menu UI.
    self = [super initWithFrame:CGRectMake(0,0,menuWidth_, maxVisibleSwitches_ * 50 + 50)];
    self.center = mainWindow.center;
    self.layer.opacity = 0.0f;

    self.header = [[UIView alloc]initWithFrame:CGRectMake(0, 1, menuWidth_, 50)];
    self.header.backgroundColor = headerColor_;
    CAShapeLayer *headerLayer = [CAShapeLayer layer];
    headerLayer.path = [UIBezierPath bezierPathWithRoundedRect: self.header.bounds byRoundingCorners: UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii: (CGSize){10.0, 10.0}].CGPath;
    self.header.layer.mask = headerLayer;
    [self addSubview:self.header];

    NSData* data = [[NSData alloc] initWithBase64EncodedString:menuIconBase64_ options:0];
    UIImage* menuIconImage = [UIImage imageWithData:data];

    UIButton *menuIcon = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    menuIcon.frame = CGRectMake(5, 1, 50, 50);
    menuIcon.backgroundColor = [UIColor clearColor];
    [menuIcon setBackgroundImage:menuIconImage forState:UIControlStateNormal];

    [menuIcon addTarget:self action:@selector(menuIconTapped) forControlEvents:UIControlEventTouchDown];
    [self.header addSubview:menuIcon];

    scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, CGRectGetHeight(self.header.bounds), menuWidth_, CGRectGetHeight(self.bounds) - CGRectGetHeight(self.header.bounds))];
    scrollView.backgroundColor = switchOffColor_;
    [self addSubview:scrollView];

    // we need this for the switches, do not remove.
    scrollViewX = CGRectGetMinX(scrollView.self.bounds);

    self.menuTitle = [[UILabel alloc]initWithFrame:CGRectMake(55, -2, menuWidth_ - 60, 50)];
    self.menuTitle.text = title_;
    self.menuTitle.textColor = titleColor_;
    self.menuTitle.font = [UIFont fontWithName:titleFont_ size:30.0f];
    self.menuTitle.adjustsFontSizeToFitWidth = true;
    self.menuTitle.textAlignment = NSTextAlignmentCenter;
    [self.header addSubview: self.menuTitle];

    self.footer = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetHeight(self.bounds) - 1, menuWidth_, 20)];
    self.footer.backgroundColor = headerColor_;
    CAShapeLayer *footerLayer = [CAShapeLayer layer];
    footerLayer.path = [UIBezierPath bezierPathWithRoundedRect:self.footer.bounds byRoundingCorners: UIRectCornerBottomLeft | UIRectCornerBottomRight cornerRadii: (CGSize){10.0, 10.0}].CGPath;
    self.footer.layer.mask = footerLayer;
    [self addSubview:self.footer];

    UIPanGestureRecognizer *dragMenuRecognizer = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(menuDragged:)];
    [self.header addGestureRecognizer:dragMenuRecognizer];

    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideMenu:)];
    tapGestureRecognizer.numberOfTapsRequired = 1;
    [self.header addGestureRecognizer:tapGestureRecognizer];

    [mainWindow addSubview:self];
    [self showMenuButton];

    return self;
}

// Detects whether the menu is being touched and sets a lastMenuLocation.
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    self.lastMenuLocation = CGPointMake(CGRectGetMinX(self.frame), CGRectGetMinY(self.frame));
    [super touchesBegan:touches withEvent:event];
}

// Update the menu's location when it's being dragged
- (void)menuDragged:(UIPanGestureRecognizer *)pan {
    CGPoint newLocation = [pan translationInView:self.superview];
    self.frame = CGRectMake(self.lastMenuLocation.x + newLocation.x, self.lastMenuLocation.y + newLocation.y, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
}

- (void)hideMenu:(UITapGestureRecognizer *)tap {
    if(tap.state == UIGestureRecognizerStateEnded) {
        [UIView animateWithDuration:0.5 animations:^ {
            self.alpha = 0.0f;
            menuButton.alpha = 1.0f;
        }];
    }
}

-(void)showMenu:(UITapGestureRecognizer *)tapGestureRecognizer {
    if(tapGestureRecognizer.state == UIGestureRecognizerStateEnded) {
        menuButton.alpha = 0.0f;
        [UIView animateWithDuration:0.5 animations:^ {
            self.alpha = 1.0f;
        }];
    }
    // We should only have to do this once (first launch)
    if(!hasRestoredLastSession) {
        restoreLastSession();
        hasRestoredLastSession = true;
    }
}

-(void) restoreForced {
    if(!hasRestoredLastSession) {
        restoreLastSession();
        hasRestoredLastSession = true;
    }
}

/**********************************************************************************************
     This function will be called when the menu has been opened for the first time on launch.
     It'll handle the correct background color and patches the switches do.
***********************************************************************************************/
void restoreLastSession() {
    UIColor *clearColor = [UIColor clearColor];
    BOOL isOn = false;

    for(id switch_ in scrollView.subviews) {
        if([switch_ isKindOfClass:[OffsetSwitch class]]) {
            isOn = [defaults boolForKey:[switch_ getPreferencesKey]];
            std::vector<MemoryPatch> memoryPatches = [switch_ getMemoryPatches];
            for(int i = 0; i < memoryPatches.size(); i++) {
                if(isOn){
                 memoryPatches[i].Modify();
                } else {
                 memoryPatches[i].Restore();
                }
            }
            ((OffsetSwitch*)switch_).backgroundColor = isOn ? switchOnColor : clearColor;
        }

        if([switch_ isKindOfClass:[TextFieldSwitch class]]) {
            isOn = [defaults boolForKey:[switch_ getPreferencesKey]];
            ((TextFieldSwitch*)switch_).backgroundColor = isOn ? switchOnColor : clearColor;
        }

        if([switch_ isKindOfClass:[SliderSwitch class]]) {
            isOn = [defaults boolForKey:[switch_ getPreferencesKey]];
            ((SliderSwitch*)switch_).backgroundColor = isOn ? switchOnColor : clearColor;
        }
    }
}

-(void)showMenuButton {
    NSData* data = [[NSData alloc] initWithBase64EncodedString:menuButtonBase64 options:0];
    UIImage* menuButtonImage = [UIImage imageWithData:data];

    menuButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    menuButton.frame = CGRectMake((mainWindow.frame.size.width/2), (mainWindow.frame.size.height/2), 50, 50);
    menuButton.backgroundColor = [UIColor clearColor];
    [menuButton setBackgroundImage:menuButtonImage forState:UIControlStateNormal];

    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showMenu:)];
    [menuButton addGestureRecognizer:tapGestureRecognizer];

    [menuButton addTarget:self action:@selector(buttonDragged:withEvent:)
       forControlEvents:UIControlEventTouchDragInside];
    [mainWindow addSubview:menuButton];
}

// handler for when the user is draggin the menu.
- (void)buttonDragged:(UIButton *)button withEvent:(UIEvent *)event {
    UITouch *touch = [[event touchesForView:button] anyObject];

    CGPoint previousLocation = [touch previousLocationInView:button];
    CGPoint location = [touch locationInView:button];
    CGFloat delta_x = location.x - previousLocation.x;
    CGFloat delta_y = location.y - previousLocation.y;

    button.center = CGPointMake(button.center.x + delta_x, button.center.y + delta_y);
}

// When the menu icon(on the header) has been tapped, we want to show proper credits!
-(void)menuIconTapped {
    [self showPopup:self.menuTitle.text description:credits];
    self.layer.opacity = 0.0f;
}

-(void)showPopup:(NSString *)title_ description:(NSString *)description_ {
    SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];

    alert.shouldDismissOnTapOutside = NO;
    alert.customViewColor = [UIColor purpleColor];
    alert.showAnimationType = SCLAlertViewShowAnimationFadeIn;

    [alert addButton: NSSENCRYPT("Ok!") actionBlock: ^(void) {
        self.layer.opacity = 1.0f;
    }];

    [alert showInfo:title_ subTitle:description_ closeButtonTitle:nil duration:9999999.0f];
}

/*******************************************************************
    This method adds the given switch to the menu's scrollview.
    it also add's an action for when the switch is being clicked.
********************************************************************/
- (void)addSwitchToMenu:(id)switch_ {
    [switch_ addTarget:self action:@selector(switchClicked:) forControlEvents:UIControlEventTouchDown];
    scrollViewHeight += 50;
    scrollView.contentSize = CGSizeMake(menuWidth, scrollViewHeight);
    [scrollView addSubview:switch_];
}

- (void)addInfoToMenu:(id)info_ {
    scrollViewHeight += [info_ getHeight];
    scrollView.contentSize = CGSizeMake(menuWidth, scrollViewHeight);
    [scrollView addSubview:info_];
}
- (void)changeSwitchBackground:(id)switch_ isSwitchOn:(BOOL)isSwitchOn_ {
    UIColor *clearColor = [UIColor clearColor];

    [UIView animateWithDuration:0.3 animations:^ {
        if([switch_ isKindOfClass:[TextFieldSwitch class]]) {
            ((TextFieldSwitch*)switch_).backgroundColor = isSwitchOn_ ? clearColor : switchOnColor;
        }
        if([switch_ isKindOfClass:[SliderSwitch class]]) {
            ((SliderSwitch*)switch_).backgroundColor = isSwitchOn_ ? clearColor : switchOnColor;
        }
        if([switch_ isKindOfClass:[OffsetSwitch class]]) {
            ((OffsetSwitch*)switch_).backgroundColor = isSwitchOn_ ? clearColor : switchOnColor;
        }
    }];

    [defaults setBool:!isSwitchOn_ forKey:[switch_ getPreferencesKey]];
}

/*********************************************************************************************
    This method does the following handles the behaviour when a switch has been clicked
    TextfieldSwitch and SliderSwitch only change from color based on whether it's on or not.
    A OffsetSwitch does too, but it also applies offset patches
***********************************************************************************************/
-(void)switchClicked:(id)switch_ {
    BOOL isOn = [defaults boolForKey:[switch_ getPreferencesKey]];

    if([switch_ isKindOfClass:[OffsetSwitch class]]) {
        std::vector<MemoryPatch> memoryPatches = [switch_ getMemoryPatches];
        for(int i = 0; i < memoryPatches.size(); i++) {
            if(!isOn){
                memoryPatches[i].Modify();
            } else {
                memoryPatches[i].Restore();
           }
        }
    }

    // Update switch background color and pref value.
    [self changeSwitchBackground:switch_ isSwitchOn:isOn];
}

-(void)setFrameworkName:(const char *)name_ {
    frameworkName = name_;
}

-(const char *)getFrameworkName {
    return frameworkName;
}
@end // End of menu class!

/********************************
    CATEGORY STARTS HERE!
*********************************/

@implementation Category {
    int Height;
}

- (id) initCategory:(NSString *)description_ height:(int)height_ {
    Height = height_;
    self = [super initWithFrame:CGRectMake(-1, scrollViewX + scrollViewHeight - 1, menuWidth + 2, Height)];
    self.backgroundColor = [UIColor clearColor];
    self.layer.borderWidth = 0.5f;
    self.layer.borderColor = [UIColor whiteColor].CGColor;

    categoryLabel = [[UILabel alloc]initWithFrame:CGRectMake(3, 0, menuWidth, Height)];
    categoryLabel.text = description_;
    categoryLabel.textAlignment = NSTextAlignmentCenter;
    categoryLabel.textColor = categoryColor;
    categoryLabel.font = [UIFont fontWithName:switchTitleFont size:14];
    [self addSubview:categoryLabel];
    return self;
}

-(int)getHeight {
    return Height;
}

@end //end of Category class
/********************************
    OFFSET SWITCH STARTS HERE!
*********************************/

@implementation OffsetSwitch {
    std::vector<MemoryPatch> memoryPatches;
}

- (id)initHackNamed:(NSString *)hackName_ description:(NSString *)description_ offsets:(std::vector<std::string>)offsets_ bytes:(std::vector<std::string>)bytes_ {
	NSString* hackName = hackName_;
    description = description_;
    preferencesKey = hackName_;
	UIColor* backBtnColor = [UIColor clearColor];
	UIColor* infoBtnColor = infoButtonColor;

    if(offsets_.size() != bytes_.size()){
        [menu showPopup:NSSENCRYPT("Invalid input count") description:[NSString stringWithFormat:NSSENCRYPT("Offsets array input count (%d) is not equal to the bytes array input count (%d)"), (int)offsets_.size(), (int)bytes_.size()]];
    } else {
        for(int i = 0; i < offsets_.size(); i++) {
            uintptr_t offset = strtoull(offsets_[i].c_str(), NULL, 0);

            uintptr_t address;
            if(offset != 0) {
                address = (uintptr_t)KittyMemory::getAbsoluteAddress([menu getFrameworkName], offset);
            } else {
                address = (uintptr_t)dlsym((void *)RTLD_DEFAULT, offsets_[i].c_str());
            }

            MemoryPatch patch;
            std::string data = bytes_[i];
            std::string asm_data = data;
            if(KittyUtils::String::ValidateHex(data)) {
                patch = MemoryPatch::createWithHex(address, data);
            } else {
#ifndef kNO_KEYSTONE
            patch = MemoryPatch::createWithAsm(address, MP_ASM_ARM64, asm_data, 0);
#else
			hackName = [NSSENCRYPT("[FAIL]") stringByAppendingString:hackName];
			description = NSSENCRYPT("Failed: Non-hex data provided and ASM not supported");
			backBtnColor = [UIColor brownColor];
			infoBtnColor = [UIColor redColor];
#endif
            }
            if(patch.isValid()) {
                memoryPatches.push_back(patch);
	        } else {
				hackName = [NSSENCRYPT("[FAIL]") stringByAppendingString:hackName];
				description = NSSENCRYPT("Failed: !patch.isValid");
				backBtnColor = [UIColor brownColor];
				infoBtnColor = [UIColor redColor];
            }
        }
    }

    self = [super initWithFrame:CGRectMake(-1, scrollViewX + scrollViewHeight - 1, menuWidth + 2, 50)];
    self.backgroundColor = backBtnColor;
    self.layer.borderWidth = 0.5f;
    self.layer.borderColor = [UIColor whiteColor].CGColor;

    switchLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, 0, menuWidth - 60, 50)];
    switchLabel.text = hackName;
    switchLabel.textColor = switchTitleColor;
    switchLabel.font = [UIFont fontWithName:switchTitleFont size:18];
    switchLabel.adjustsFontSizeToFitWidth = true;
    switchLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:switchLabel];

    UIButton *infoButton = [UIButton buttonWithType:UIButtonTypeInfoDark];
    infoButton.frame = CGRectMake(menuWidth - 30, 15, 20, 20);
    infoButton.tintColor = infoBtnColor;

    UITapGestureRecognizer *infoTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showInfo:)];
    [infoButton addGestureRecognizer:infoTap];
    [self addSubview:infoButton];

    return self;
}

-(void)showInfo:(UIGestureRecognizer *)gestureRec {
    if(gestureRec.state == UIGestureRecognizerStateEnded) {
        [menu showPopup:[self getPreferencesKey] description:[self getDescription]];
        menu.layer.opacity = 0.0f;
    }
}

-(NSString *)getPreferencesKey {
    return preferencesKey;
}

-(NSString *)getDescription {
    return description;
}

- (std::vector<MemoryPatch>)getMemoryPatches {
    return memoryPatches;
}

@end //end of OffsetSwitch class


/**************************************
    TEXTFIELD SWITCH STARTS HERE!
    - Note that this extends from OffsetSwitch.
***************************************/

@implementation TextFieldSwitch {
    UITextField *textfieldValue;
    UIColor *inputBorderColor;
}

- (id)initTextfieldNamed:(NSString *)hackName_ description:(NSString *)description_ inputBorderColor:(UIColor *)inputBorderColor_ {
    preferencesKey = hackName_;
    switchValueKey = [hackName_ stringByApplyingTransform:NSStringTransformLatinToCyrillic reverse:false];
    description = description_;
    inputBorderColor = inputBorderColor_;

    self = [super initWithFrame:CGRectMake(-1, scrollViewX + scrollViewHeight -1, menuWidth + 2, 50)];
    self.backgroundColor = [UIColor clearColor];
    self.layer.borderWidth = 0.5f;
    self.layer.borderColor = [UIColor whiteColor].CGColor;

    switchLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, 0, menuWidth - 60, 30)];
    switchLabel.text = hackName_;
    switchLabel.textColor = switchTitleColor;
    switchLabel.font = [UIFont fontWithName:switchTitleFont size:18];
    switchLabel.adjustsFontSizeToFitWidth = true;
    switchLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:switchLabel];

    textfieldValue = [[UITextField alloc]initWithFrame:CGRectMake(menuWidth / 4 - 10, switchLabel.self.bounds.origin.x - 5 + switchLabel.self.bounds.size.height, menuWidth / 2, 20)];
    textfieldValue.layer.borderWidth = 2.0f;
    textfieldValue.layer.borderColor = inputBorderColor.CGColor;
    textfieldValue.layer.cornerRadius = 10.0f;
    textfieldValue.textColor = switchTitleColor;
    textfieldValue.textAlignment = NSTextAlignmentCenter;
    textfieldValue.delegate = self;
    textfieldValue.backgroundColor = [UIColor clearColor];

    // get value from the plist & show it (if it's not empty).
    if([[NSUserDefaults standardUserDefaults] objectForKey:switchValueKey] != nil) {
        textfieldValue.text = [[NSUserDefaults standardUserDefaults] objectForKey:switchValueKey];
    }

    [self updateTextFieldAppearance];

    UIButton *infoButton = [UIButton buttonWithType:UIButtonTypeInfoDark];
    infoButton.frame = CGRectMake(menuWidth - 30, 15, 20, 20);
    infoButton.tintColor = infoButtonColor;

    UITapGestureRecognizer *infoTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showInfo:)];
    [infoButton addGestureRecognizer:infoTap];
    [self addSubview:infoButton];

    [self addSubview:textfieldValue];

    return self;
}

// so when click "return" the keyboard goes way, got it from internet. Common thing apparantly
-(BOOL)textFieldShouldReturn:(UITextField*)textfieldValue_ {
    switchValueKey = [[self getPreferencesKey] stringByApplyingTransform:NSStringTransformLatinToCyrillic reverse:false];
    [defaults setObject:textfieldValue_.text forKey:[self getSwitchValueKey]];
    [textfieldValue_ resignFirstResponder];

    [self updateTextFieldAppearance];
    return true;
}

- (void)updateTextFieldAppearance {
    if (textfieldValue.text.length > 0) {
        textfieldValue.layer.borderColor = inputBorderColor.CGColor;
    } else {
        textfieldValue.layer.borderColor = [UIColor grayColor].CGColor;
    }
}

-(NSString *)getSwitchValueKey {
    return switchValueKey;
}

@end // end of TextFieldSwitch Class


/*******************************
    SLIDER SWITCH STARTS HERE!
    - Note that this extends from TextFieldSwitch
 *******************************/
@implementation SliderSwitch {
    UISlider *sliderValue;
    float valueOfSlider;
    UIColor *sliderColor;
}

- (id)initSliderNamed:(NSString *)hackName_ description:(NSString *)description_ minimumValue:(float)minimumValue_ maximumValue:(float)maximumValue_ sliderColor:(UIColor *)sliderColor_ {
    preferencesKey = hackName_;
    switchValueKey = [hackName_ stringByApplyingTransform:NSStringTransformLatinToCyrillic reverse:false];
    description = description_;
    sliderColor = sliderColor_;

    self = [super initWithFrame:CGRectMake(-1, scrollViewX + scrollViewHeight -1, menuWidth + 2, 50)];
    self.backgroundColor = [UIColor clearColor];
    self.layer.borderWidth = 0.5f;
    self.layer.borderColor = [UIColor whiteColor].CGColor;

    switchLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, 0, menuWidth - 60, 30)];
    [self updateLabelText];
    switchLabel.font = [UIFont fontWithName:switchTitleFont size:18];
    switchLabel.adjustsFontSizeToFitWidth = true;
    switchLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:switchLabel];

    sliderValue = [[UISlider alloc]initWithFrame:CGRectMake(menuWidth / 4 - 20, switchLabel.self.bounds.origin.x - 4 + switchLabel.self.bounds.size.height, menuWidth / 2 + 20, 20)];
    [self updateSliderAppearance];
    sliderValue.minimumValue = minimumValue_;
    sliderValue.maximumValue = maximumValue_;
    sliderValue.continuous = true;
    [sliderValue addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    valueOfSlider = sliderValue.value;

    // get value from the plist & show it (if it's not empty).
    if([[NSUserDefaults standardUserDefaults] objectForKey:switchValueKey] != nil && [[NSUserDefaults standardUserDefaults] floatForKey:switchValueKey] != 0) {
        sliderValue.value = [[NSUserDefaults standardUserDefaults] floatForKey:switchValueKey];
        [self updateLabelText];
        [self updateSliderAppearance];
    }

    UIButton *infoButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
    infoButton.frame = CGRectMake(menuWidth - 30, 15, 20, 20);
    infoButton.tintColor = infoButtonColor;

    UITapGestureRecognizer *infoTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showInfo:)];
    [infoButton addGestureRecognizer:infoTap];
    [self addSubview:infoButton];

    [self addSubview:sliderValue];

    return self;
}

- (void)updateSliderAppearance {
    BOOL isZero = (sliderValue.value == 0.0f);

    sliderValue.thumbTintColor = isZero ? [UIColor grayColor] : sliderColor;
    sliderValue.minimumTrackTintColor = isZero ? [UIColor grayColor] : sliderColor;
    sliderValue.maximumTrackTintColor = [UIColor colorWithWhite:1.0 alpha:0.3];
}

- (void)updateLabelText {
    NSString *baseText = [self getPreferencesKey];
    NSString *valueText = [NSString stringWithFormat:NSSENCRYPT(" %.2f"), sliderValue.value];
    
    BOOL isZero = (sliderValue.value == 0.0f);
    UIColor *valueColor = isZero ? [UIColor grayColor] : sliderColor;
    
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] 
        initWithString:[baseText stringByAppendingString:valueText]];
    
    [attributedText addAttribute:NSForegroundColorAttributeName 
                          value:switchTitleColor 
                          range:NSMakeRange(0, baseText.length)];
    [attributedText addAttribute:NSForegroundColorAttributeName 
                          value:valueColor 
                          range:NSMakeRange(baseText.length, valueText.length)];
    switchLabel.attributedText = attributedText;
}

-(void)sliderValueChanged:(UISlider *)slider_ {
    switchValueKey = [[self getPreferencesKey] stringByApplyingTransform:NSStringTransformLatinToCyrillic reverse:false];
    
    [self updateLabelText];
    [self updateSliderAppearance];
    
    [defaults setFloat:slider_.value forKey:[self getSwitchValueKey]];
}
@end // end of SliderSwitch class



/*******************************
    BASE SWITCHES STARTS HERE!
 *******************************/
@implementation Switches

-(void)addInfo:(NSString *)description_ height:(std::string)height_ {
    int iheight = std::stoi(height_);
    Category *category = [[Category alloc]initCategory:description_ height:iheight];
    [menu addInfoToMenu:category];
}

-(void)addSwitch:(NSString *)hackName_ description:(NSString *)description_ {
    OffsetSwitch *offsetPatch = [[OffsetSwitch alloc]initHackNamed:hackName_ description:description_ offsets:std::vector<std::string>{} bytes:std::vector<std::string>{}];
    [menu addSwitchToMenu:offsetPatch];
}

- (void)addOffsetSwitch:(NSString *)hackName_ description:(NSString *)description_ offsets:(std::initializer_list<std::string>)offsets_ data:(std::initializer_list<std::string>)bytes_ {
    std::vector<std::string> offsetVector;
    std::vector<std::string> bytesVector;

    offsetVector.insert(offsetVector.begin(), offsets_.begin(), offsets_.end());
    bytesVector.insert(bytesVector.begin(), bytes_.begin(), bytes_.end());

    OffsetSwitch *offsetPatch = [[OffsetSwitch alloc]initHackNamed:hackName_ description:description_ offsets:offsetVector bytes:bytesVector];
    [menu addSwitchToMenu:offsetPatch];
}

- (void)addOffsetSwitch:(NSString *)hackName_ description:(NSString *)description_ roots:(std::initializer_list<std::string>)roots_ offsets:(std::initializer_list<std::string>)offsets_ data:(std::initializer_list<std::string>)bytes_ {
    
    std::vector<std::string> offsetVector;
    std::vector<std::string> bytesVector;
    
    auto rootIt = roots_.begin();
    auto offsetIt = offsets_.begin();
    auto bytesIt = bytes_.begin();
    
    for (; rootIt != roots_.end() && offsetIt != offsets_.end() && bytesIt != bytes_.end(); ++rootIt, ++offsetIt, ++bytesIt) {
        uintptr_t root = strtoull(rootIt->c_str(), NULL, 0);
        uintptr_t offset = strtoull(offsetIt->c_str(), NULL, 0);
        uintptr_t relativeAddress = root + offset;
        
        offsetVector.push_back(std::to_string(relativeAddress));
        bytesVector.push_back(*bytesIt);
    }
    
    OffsetSwitch *offsetPatch = [[OffsetSwitch alloc] initHackNamed:hackName_ description:description_ offsets:offsetVector bytes:bytesVector];
    [menu addSwitchToMenu:offsetPatch];
}

- (void)addTextfieldSwitch:(NSString *)hackName_ description:(NSString *)description_ inputBorderColor:(UIColor *)inputBorderColor_ {
    TextFieldSwitch *textfieldSwitch = [[TextFieldSwitch alloc]initTextfieldNamed:hackName_ description:description_ inputBorderColor:inputBorderColor_];
    [menu addSwitchToMenu:textfieldSwitch];
}

- (void)addSliderSwitch:(NSString *)hackName_ description:(NSString *)description_ minimumValue:(float)minimumValue_ maximumValue:(float)maximumValue_ sliderColor:(UIColor *)sliderColor_ {
    SliderSwitch *sliderSwitch = [[SliderSwitch alloc] initSliderNamed:hackName_ description:description_ minimumValue:minimumValue_ maximumValue:maximumValue_ sliderColor:sliderColor_];
    [menu addSwitchToMenu:sliderSwitch];
}

- (NSString *)getValueFromSwitch:(NSString *)name {

    //getting the correct key for the saved input.
    NSString *correctKey =  [name stringByApplyingTransform:NSStringTransformLatinToCyrillic reverse:false];

    if([[NSUserDefaults standardUserDefaults] objectForKey:correctKey]) {
        return [[NSUserDefaults standardUserDefaults] objectForKey:correctKey];
    }
    else if([[NSUserDefaults standardUserDefaults] floatForKey:correctKey]) {
        NSString *sliderValue = [NSString stringWithFormat:NSSENCRYPT("%f"), [[NSUserDefaults standardUserDefaults] floatForKey:correctKey]];
        return sliderValue;
    }

    return 0;
}

-(bool)isSwitchOn:(NSString *)switchName {
    return [[NSUserDefaults standardUserDefaults] boolForKey:switchName];
}

@end