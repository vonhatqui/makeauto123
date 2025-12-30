//
//  Macros.h
//  ModMenu
//
//  Created by Joey on 4/2/19.
//  Updated by ABS on 28/12/25.
//  Copyright © 2025 Joey. All rights reserved.
//

#import "KittyMemory/writeData.hpp"
#import "Obfuscate.h"
#import "Menu.h"

#include <dlfcn.h>
#include <stdlib.h>
#include <substrate.h>
#include <mach-o/dyld.h>

// definition at Menu.h
extern Menu *menu;
extern Switches *switches;

// thanks to shmoo for the usefull stuff under this comment.
#define timer(sec) dispatch_after(dispatch_time(DISPATCH_TIME_NOW, sec * NSEC_PER_SEC), dispatch_get_main_queue(), ^

/// default hook (offset || sym)
#define HOOK(off_sym, ptr, orig) MSHookFunction(getAbsoluteAddress(off_sym), (void *)ptr, (void **)&orig)
/// hook without original function (offset || sym)
#define HOOK_NO_ORIG(off_sym, ptr) MSHookFunction(getAbsoluteAddress(off_sym), (void *)ptr, NULL)

// Note to not prepend an underscore to the symbol (https://developer.apple.com/library/archive/documentation/System/Conceptual/ManPages_iPhoneOS/man3/dlsym.3.html)

void* getAbsoluteAddress(std::string relative) {
    uintptr_t offset = strtoull(relative.c_str(), NULL, 0);

    if(offset != 0) {
        return (void*)KittyMemory::getAbsoluteAddress([menu getFrameworkName], offset);
    } else {
        return dlsym((void *)RTLD_DEFAULT, relative.c_str());
    }
}

/// default patch (offset || sym) (hex || asm)
#define PATCH(off_sym, hex_asm) patchOffset(off_sym, hex_asm)

void patchOffset(std::string relative, std::string data) {
    auto address = (uintptr_t)getAbsoluteAddress(relative);

    MemoryPatch patch;
    std::string asm_data = data;
    if(KittyUtils::String::ValidateHex(data)) {
        patch = MemoryPatch::createWithHex(address, data);
    } else {
#ifndef kNO_KEYSTONE
        patch = MemoryPatch::createWithAsm(address, MP_ASM_ARM64, asm_data, 0);
#else
		[menu showPopup:NSSENCRYPT("PATCH !hex & !ASM") description:[NSString stringWithFormat:NSSENCRYPT("Non-hex data provided and ASM not supported: %s"), relative.c_str()]];
        return;
#endif
    }
	
	if(!patch.isValid()){
		[menu showPopup:NSSENCRYPT("Failed PATCH") description:[NSString stringWithFormat:NSSENCRYPT("Failed to create PATCH at: %s"), relative.c_str()]];
		return;
	}
    if(!patch.Modify()) {
		[menu showPopup:NSSENCRYPT("Failed PATCH") description:[NSString stringWithFormat:NSSENCRYPT("Failed to apply PATCH at: %s"), relative.c_str()]];
    }
}

/// relative patch (offset || sym) (offset) (hex || asm)
#define rPATCH(off_sym, add_off, hex_asm) patchRelativeOffset(off_sym, add_off, hex_asm);

void* getRelativeAddress(std::string rootOffset, std::string addOffset) {
    uintptr_t offset = strtoull(rootOffset.c_str(), NULL, 0);
    uintptr_t offset2 = strtoull(addOffset.c_str(), NULL, 0);

    if(offset != 0) {
        return (void*)KittyMemory::getAbsoluteAddress([menu getFrameworkName], offset + offset2);
    } else {
        return dlsym((void *)RTLD_DEFAULT, rootOffset.c_str());
    }
}

void patchRelativeOffset(std::string rootstr, std::string offsetstr, std::string data) {
    auto address = (uintptr_t)getRelativeAddress(rootstr, offsetstr);

	MemoryPatch patch;
    std::string asm_data = data;
    if(KittyUtils::String::ValidateHex(data)) {
        patch = MemoryPatch::createWithHex(address, data);
    } else {
#ifndef kNO_KEYSTONE
        patch = MemoryPatch::createWithAsm(address, MP_ASM_ARM64, asm_data, 0);
#else
        [menu showPopup:NSSENCRYPT("rPATCH !hex & !ASM") description:[NSString stringWithFormat:NSSENCRYPT("Non-hex data provided and ASM not supported: %s"), rootstr.c_str()]];
        return;
#endif
    }

	if(!patch.isValid()){
        [menu showPopup:NSSENCRYPT("Failed rPATCH") description:[NSString stringWithFormat:NSSENCRYPT("Failed to create rPATCH at: %s"), rootstr.c_str()]];
		return;
	}
    if(!patch.Modify()) {
        [menu showPopup:NSSENCRYPT("Failed rPATCH") description:[NSString stringWithFormat:NSSENCRYPT("Failed to apply rPATCH at: %s"), rootstr.c_str()]];
    }
}

/// dynamic asm patch (offset || sym) (asm pattern) (asm args)
#define dPATCH(off_sym, asms, ...) patchOffset(off_sym, KittyUtils::String::Fmt(asms, __VA_ARGS__))

/// dynamic asm with relative patch (offset || sym) (offset) (asm pattern) (asm args)
#define drPATCH(off_sym, add_off, asms, ...) patchRelativeOffset(off_sym, add_off, KittyUtils::String::Fmt(asms, __VA_ARGS__));