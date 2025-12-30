# iOS Mod Menu Template for Theos!

<div style="text-align: center;">
<b>Sample UI of the Menu:</b><br>

![](imgur-rOKkoXA.gif)
</div>

<br>

### Features:
* Customizable UI
* Customizable menu & button image icon
* 4 types of patches without switches:
  * PATCH - default
  * rPATCH - relative PATCH (root + additional offset)
  * dPATCH - dynamic ASM PATCH (runtime building ASM instructions)
  * drPATCH - dynamic + relative
* 4 types of switches:
  * Offset Patcher Switch (Default and Relative variants)
  * Empty Switch
  * Textfield Switch
  * Slider Switch
* Supports any mix offset/symbol, hex/asm instructions

* Backend Offset Patcher Switch is based on [KittyMemory](https://github.com/MJx0/KittyMemory)
  * Original bytes are **not** required
  * Supports MSHookMemory
  * Write unlimited bytes to a offset
  * Supports ASM instructions (Keystone assembler)(iOS 14+)

* Adaptive initialisation for all devices
* Compile-time string encryption
* Open Source Menu

<br>

### Installation:

You can download the template here: [Latest Release](https://github.com/joeyjurjens/iOS-Mod-Menu-Template-for-Theos/releases/latest). <br>
**iOS**
1. In the makefile on line 22, you've to set the path to your SDK. This menu has been tested with the "iPhoneOS11.2.sdk" SDK from [theos/sdks](https://github.com/theos/sdks)
2. I use initializer_list in this project, iOS doesn't have this included by itself. You can download it [**here**](https://raw.githubusercontent.com/joeyjurjens/iOS-Mod-Menu-Template-for-Theos/977e9ff2c626d6b1308eed7e17f1daf0a610e8e9/template/KittyMemory/initializer_list), save it as "initializer_list" and copy the file to: "$THEOS/sdks/iPhoneOS11.2.sdk/usr/include/c++/4.2.1/" <br>

**MacOS:**
1. Install xCode if you haven't already.
1. In the Makefile of the project, change "MOBILE_THEOS=1" to "MOBILE_THEOS=0" <br>

### Menu setup:

**Changing the menu images**
Inside the **Tweak.xm**, you'll setup the menu under the function "setupMenu". 
Here you'll see two options under the menu: menuIcon & menuButton, those require a base64 image string.
In order to get a base64 string from the image, upload the image here: https://www.browserling.com/tools/image-to-base64

Images 50x50 are recommended, you can get a sample of my images by copying the standard(in tweak.xm) base64 string & use this website to show the picture: https://base64.guru/converter/decode/image

**Setting a framework as executable**
You can set this in the function setupMenu() inside Tweak.xm
```obj-c
[menu setFrameworkName:"FrameworkName"];
```

### Menu usage:

**Encryption**

A quick note before showing all the switch examples; You can and *should* encrypt offsets, symbols, ASM, hexes, c-strings and NSStrings. Below you can find the proper syntax per string-type.

**C-strings, Offsets:**
```c
ENCRYPT("I am a c-string")
```

**NSStrings:**
```c
NSSENCRYPT("Copperplate-Bold")
```

**Offsets:**
<br>Is DEPRECATED because the new macros automatically detects the input data type, but the code is still available if you need your own implementation (new macros, hook functions and etc.).
<br>Using it in the new macros will cause errors.
<br>So in the new implementation it is enough to use a ENCRYPT.
```c
ENCRYPTOFFSET("0x10047FD90")
```

~~**Hexes:**~~
<br>Is DEPRECATED because the new macros automatically detects the input data type, but the code is still available if you need your own implementation.
<br>It was originally completely equivalent to ENCRYPT, so you can still use it if you want without errors.
<br>So in the new macros it is enough to use a ENCRYPT.
```c
ENCRYPTHEX("0x00F0271E0008201EC0035FD6")
```

<b> Patches without switch: </b>
* PATCH - default
```c
// this base (offset, hex) variant:
PATCH(ENCRYPT("0x1002DB3C8"), ENCRYPT("0xC0035FD6"));
// hex: you can write as many bytes as you want to an offset
PATCH(ENCRYPT("0x10020D3A8"), ENCRYPT("0x00F0271E0008201EC0035FD6"));
// or
PATCH(ENCRYPT("0x10020D3A8"), ENCRYPT("00F0271E0008201EC0035FD6"));
// spaces are fine too
PATCH(ENCRYPT("0x10020D3A8"), ENCRYPT("00 F0 27 1E 00 08 20 1E C0 03 5F D6"));
  
// alt possibles new usage variants:
// symbol, hex
PATCH(ENCRYPT("example__sym"), ENCRYPT("0xC0035FD6"));
// offset, asm
PATCH(ENCRYPT("0x1002DB3C8"), ENCRYPT("ret"));
// symbol, asm
PATCH(ENCRYPT("example__sym"), ENCRYPT("ret"));
// asm allows you to avoid using hex code, as it is generated automatically from the instructions
// - this is the awesome option if you know what you're doing
// recommended insert ';' to separate statements, example: "mov x0, #1; ret"
// don't forget enable ASM_SUPPORT in makefile for usage
```
* rPATCH - relative PATCH (root + additional offset)
<br>Relative patches allow you to speed up patch creation if you are sure that the offsets within methods rarely change.
<br>This is an extremely unstable due to the hard offsets... don't forget to check the logs to identify outdated offsets.
```c
// this base (offset, offset, hex) variant:
rPATCH(ENCRYPT("0x4B3F18"), ENCRYPT("0x11C"), ENCRYPT("30 00 00 14"));
  
// alt possibles usage variants:
// symbol, offset, hex
rPATCH(ENCRYPT("example__sym"), ENCRYPT("0x11C"), ENCRYPT("30 00 00 14"));
// offset, offset, asm
rPATCH(ENCRYPT("0x4B3F18"), ENCRYPT("0x11C"), ENCRYPT("b #0xc0"));
// symbol, offset, asm
rPATCH(ENCRYPT("example__sym"), ENCRYPT("0x11C"), ENCRYPT("b #0xc0"));
```
* dPATCH - dynamic ASM PATCH (runtime building ASM instructions)
<br>ASM can be especially useful with creating dynamic deep patches:
```c
// (offset, asm pattern, ... asm args)
dPATCH(ENCRYPT("0x4B3F18"), ENCRYPT("mov w%d, #%d"), 0, 222);
// (symbol, asm pattern, ... asm args)
dPATCH(ENCRYPT("example__sym"), ENCRYPT("mov w%d, #%d"), 0, 222);
// standard formatting specifiers are supported (%d, %i, %x, %s, etc.)
```
* drPATCH - dynamic + relative
```c
// (offset, offset, asm pattern, ... asm args)
drPATCH(ENCRYPT("0x4B3F18"), ENCRYPT("0x11C"), ENCRYPT("mov w%d, #%d"), 0, 222);
// (symbol, offset, asm pattern, ... asm args)
drPATCH(ENCRYPT("example__sym"), ENCRYPT("0x11C"), ENCRYPT("mov w%d, #%d"), 0, 222);
```

<b> HOOKS: </b>
```c
void (*old_Update_CarLight)(void *instance);
void Update_CarLight(void *instance) {
	if (instance != nullptr && [switches isSwitchOn:NSSENCRYPT("CarLight")]) {
		// ...
	} else {
		// ...
	}
	return old_Update_CarLight(instance);
}

void Player_Killed(void *instance, bool needKill) {
	// ...
}

void setup() {
...
// offset variant:
HOOK(ENCRYPT("0x4B3F18"), Update_CarLight, old_Update_CarLight);
// symbol:
HOOK(ENCRYPT("example__sym"), Update_CarLight, old_Update_CarLight);
// no orig:
HOOK_NO_ORIG(ENCRYPT("0x4B3F18"), Player_Killed);
// or symbol variant:
HOOK_NO_ORIG(ENCRYPT("example__sym"), Player_Killed);
...
}
```

<b> Offset Patcher Switch: </b>
* default variant
```obj-c
  // you can unhindered mix offset/sym and hex/asm if need
  [switches addOffsetSwitch:NSSENCRYPT("One Hit Kill")
    description:NSSENCRYPT("Enemy will die instantly")
    offsets: { // offset/sym
      ENCRYPT("0x1001BB2C0"),
      ENCRYPT("example__sym"),
      ENCRYPT("0x1002CB3B8")
    }
    data: { // hex/asm
      ENCRYPT("mov w0, #0xffffff; ret"),
      ENCRYPT("0xC0035FD6"),
      ENCRYPT("0x00F0271E0008201EC0035FD6")
    }
  ];
```
* relative variant
```obj-c
  [switches addOffsetSwitch:NSSENCRYPT("One Hit Kill")
    description:NSSENCRYPT("Enemy will die instantly")
    roots: { // offset/sym
      ENCRYPT("0x4B3F18"),
      ENCRYPT("0x1001BB2C0"),
      ENCRYPT("example__sym")
    }
    offsets: { // only offset
      ENCRYPT("0x210"),
      ENCRYPT("0x18"),
      ENCRYPT("0x58")
    }
    data: { // hex/asm
      ENCRYPT("0x1002CB3B8"),
      ENCRYPT("mov w0, #0xffffff; ret"),
      ENCRYPT("01 18 28 1E")
    }
  ];
```

<b> Empty Switch: </b>
```obj-c
[switches addSwitch:NSSENCRYPT("Masskill")
  description:NSSENCRYPT("Teleport all enemies to you without them knowing")
];
```
<b> Textfield Switch: </b>
```obj-c
[switches addTextfieldSwitch:NSSENCRYPT("Custom Gold")
  description:NSSENCRYPT("Here you can enter your own gold amount")
  inputBorderColor:UIColorFromHex(0xBD0000)
];
```
<b> Slider Switch: </b>
```obj-c
[switches addSliderSwitch:NSSENCRYPT("Custom Move Speed")
  description:NSSENCRYPT("Set your custom move speed")
  minimumValue:0
  maximumValue:10
  sliderColor:UIColorFromHex(0xBD0000)
];
```

<b> Category: </b>
```obj-c
// Just text, useful for grouping and placing other information
[switches addInfo:NSSENCRYPT("Category 1") height:ENCRYPT("20")];
```

<b> Checking if a switch is on:
```obj-c
bool isOn = [switches isSwitchOn:NSSENCRYPT("Switch Name Goes Here")];
if(isOn) {
  //Do stuff
}

//Or check directly:
if([switches isSwitchOn:NSSENCRYPT("Switch Name Goes Here")]) {
    // Do stuff
}
```
<b> Getting textfield or slider value: </b>
```obj-c
int userValue = [[switches getValueFromSwitch:NSSENCRYPT("Switch Name Goes Here")] intValue];
float userValue2 = [[switches getValueFromSwitch:NSSENCRYPT("Switch Name Goes Here")] floatValue];
```

### Credits:
* Me
* [MJx0](https://github.com/MJx0)
  * For [KittyMemory](https://github.com/MJx0/KittyMemory)
  * For contributions
* [bR34Kr](https://github.com/bR34Kr)
  * For contributions
* [dogo](https://github.com/dogo)
  * For [SCLAlertView](https://github.com/dogo/SCLAlertView)
* [Rednick16](https://github.com/Rednick16)
  * For contributions
* [busmanl30](https://github.com/busmanl30)
  * For contributions
