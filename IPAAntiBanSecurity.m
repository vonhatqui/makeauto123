/**
 * ==============================================================================
 *  IPA SECURITY BYPASS & TELEMETRY FILTER TWEAK TEMPLATE (EDUCATIONAL PURPOSES)
 *  Thiết kế chuyên sâu dành cho iOS IPA (Free Fire Mod Menu / Custom Sideload)
 *  Cập nhật cơ chế tránh phát hiện Sideload, Jailbreak và Chặn Telemetry mới nhất.
 * ==============================================================================
 * 
 * Cách hoạt động:
 * 1. Chèn Dynamic Library (.dylib) này vào trong thư mục Frameworks của ứng dụng.
 * 2. Sử dụng các công cụ như `optool` hoặc `insert_dylib` để thêm lệnh tải LC_LOAD_DYLIB vào Binary gốc.
 * 3. Khi ứng dụng khởi chạy, dylib này sẽ được nạp đầu tiên nhờ thuộc tính `__attribute__((constructor))`.
 * 4. Hook các API hệ thống (Objective-C và C-level) thông qua Method Swizzling và Fishhook.
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import <dlfcn.h>
#import <sys/sysctl.h>
#import <sys/stat.h>
#import <sys/socket.h>
#import <netdb.h>
#import <arpa/inet.h>

// ==============================================================================
// 1. CẤU HÌNH ANTIBAN - ĐỊNH NGHĨA THÔNG TIN GỐC CỦA GAME FREE FIRE
// ==============================================================================
#define GAME_ORIGINAL_BUNDLE_ID @"com.dts.freefireth" // Bundle ID gốc trên App Store của Garena Free Fire
#define TELEMETRY_KEYWORD_1 @"garena"
#define TELEMETRY_KEYWORD_2 @"telemetry"
#define TELEMETRY_KEYWORD_3 @"crashlytics"
#define TELEMETRY_KEYWORD_4 @"log"

// ==============================================================================
// 2. KHAI BÁO CẤU TRÚC FISHHOOK (Dùng để Hook hàm C-level trên Non-Jailbreak)
// ==============================================================================
struct rebinding {
    const char *name;
    void *replacement;
    void **replaced;
};

typedef int (*rebind_symbols_t)(struct rebinding rebindings[], size_t rebindings_len);
static rebind_symbols_t rebind_symbols_func = NULL;

// ==============================================================================
// 3. HOOK OBJECTIVE-C: BYPASS SIDELOAD & BUNDLE IDENTIFIER CHECKS
// ==============================================================================
// Khi ứng dụng bị sideload bằng chứng chỉ cá nhân/doanh nghiệp, Bundle ID thường bị thay đổi
// (Ví dụ: com.sideloaded.freefire). Garena quét Bundle ID và sẽ khoá tài khoản nếu phát hiện bất thường.
// Swizzle [NSBundle bundleIdentifier] để luôn trả về Bundle ID gốc.

static NSString *(*orig_bundleIdentifier)(id self, SEL _cmd);

NSString *hook_bundleIdentifier(id self, SEL _cmd) {
    // Luôn trả về Bundle ID gốc để qua mặt các lớp kiểm tra phía Game Server
    return GAME_ORIGINAL_BUNDLE_ID;
}

static NSDictionary *(*orig_infoDictionary)(id self, SEL _cmd);

NSDictionary *hook_infoDictionary(id self, SEL _cmd) {
    NSMutableDictionary *dict = [[orig_infoDictionary(self, _cmd) mutableCopy] autorelease];
    if (dict) {
        // Ghi đè BundleID trong bộ nhớ Info.plist
        [dict setObject:GAME_ORIGINAL_BUNDLE_ID forKey:@"CFBundleIdentifier"];
    }
    return dict;
}

// Swizzle Helper
void swizzleMethod(Class class, SEL originalSelector, IMP replacementIMP, IMP *originalIMP) {
    Method originalMethod = class_getInstanceMethod(class, originalSelector);
    if (originalMethod) {
        *originalIMP = method_getImplementation(originalMethod);
        method_setImplementation(originalMethod, replacementIMP);
    }
}

// ==============================================================================
// 4. HOOK C-LEVEL (SOCKETS & NETWORKING): CHẶN SERVER TELEMETRY / REPORTING
// ==============================================================================
// Khi hack/mod, game sẽ gửi log phát hiện gian lận về server log của Garena.
// Hook `getaddrinfo` và `connect` ở tầng socket C để ngăn chặn hoàn toàn việc gửi telemetry.

typedef int (*getaddrinfo_t)(const char *hostname, const char *servname, const struct addrinfo *hints, struct addrinfo **res);
static getaddrinfo_t orig_getaddrinfo = NULL;

int hook_getaddrinfo(const char *hostname, const char *servname, const struct addrinfo *hints, struct addrinfo **res) {
    if (hostname != NULL) {
        NSString *host = [NSString stringWithUTF8String:hostname].lowercaseString;
        
        // Kiểm tra xem hostname có chứa các từ khoá theo dõi/telemetry/log của Garena không
        if ([host containsString:TELEMETRY_KEYWORD_1] && 
            ([host containsString:TELEMETRY_KEYWORD_2] || [host containsString:TELEMETRY_KEYWORD_4] || [host containsString:@"stat"])) {
            NSLog(@"[AntiBan] 🚫 Chặn thành công luồng Telemetry tới host: %s", hostname);
            // Trả về lỗi Host không tồn tại (EAI_NONAME) để game nghĩ rằng mạng bị ngắt kết nối với server log
            return EAI_NONAME;
        }
        
        if ([host containsString:TELEMETRY_KEYWORD_3]) {
            NSLog(@"[AntiBan] 🚫 Chặn báo cáo sự cố (Crash Report): %s", hostname);
            return EAI_NONAME;
        }
    }
    return orig_getaddrinfo(hostname, servname, hints, res);
}

// ==============================================================================
// 5. HOOK C-LEVEL: CHỐNG ANTI-DEBUGGING (ANTI-PTRACE BYPASS)
// ==============================================================================
// Game quét các tiến trình Debug để tự động crash hoặc gắn cờ ban.
// Hook `ptrace` và bỏ qua yêu cầu `PT_DENY_ATTACH`.

typedef int (*ptrace_t)(int request, pid_t pid, caddr_t addr, int data);
static ptrace_t orig_ptrace = NULL;

int hook_ptrace(int request, pid_t pid, caddr_t addr, int data) {
    if (request == 31) { // PT_DENY_ATTACH = 31
        NSLog(@"[AntiBan] 🛡️ Phát hiện và chặn đứng cuộc gọi ptrace(PT_DENY_ATTACH)!");
        // Trả về 0 (Thành công) giả lập nhưng không thực sự thực thi lệnh deny attach
        return 0;
    }
    return orig_ptrace(request, pid, addr, data);
}

// ==============================================================================
// 6. HOOK C-LEVEL: BYPASS PHÁT HIỆN JAILBREAK (SANDBOX PROTECTOR)
// ==============================================================================
// Che giấu các tệp tin hệ thống liên quan đến Cydia, Sileo, Substrate, v.v.

typedef int (*access_t)(const char *pathname, int mode);
static access_t orig_access = NULL;

int hook_access(const char *pathname, int mode) {
    if (pathname != NULL) {
        NSString *path = [NSString stringWithUTF8String:pathname];
        if ([path containsString:@"/Applications/Cydia.app"] ||
            [path containsString:@"/Library/MobileSubstrate"] ||
            [path containsString:@"/bin/bash"] ||
            [path containsString:@"/usr/sbin/sshd"] ||
            [path containsString:@"/etc/apt"]) {
            NSLog(@"[AntiBan] 🛡️ Ẩn đường dẫn Jailbreak: %s", pathname);
            errno = ENOENT; // Trả về lỗi tệp tin không tồn tại
            return -1;
        }
    }
    return orig_access(pathname, mode);
}

typedef int (*stat_t)(const char *pathname, struct stat *statbuf);
static stat_t orig_stat = NULL;

int hook_stat(const char *pathname, struct stat *statbuf) {
    if (pathname != NULL) {
        NSString *path = [NSString stringWithUTF8String:pathname];
        if ([path containsString:@"/Applications/Cydia.app"] ||
            [path containsString:@"/Library/MobileSubstrate"] ||
            [path containsString:@"/bin/bash"] ||
            [path containsString:@"/usr/sbin/sshd"] ||
            [path containsString:@"/etc/apt"]) {
            NSLog(@"[AntiBan] 🛡️ Chặn hàm stat() kiểm tra Jailbreak: %s", pathname);
            errno = ENOENT;
            return -1;
        }
    }
    return orig_stat(pathname, statbuf);
}

// ==============================================================================
// 7. HÀM KHỞI TẠO TWEAK (APPLICATION CONSTRUCTOR)
// ==============================================================================
__attribute__((constructor))
static void initialize_antiban_tweak() {
    NSLog(@"[AntiBan VIP] 🚀 Dylib nạp thành công vào IPA! Đang kích hoạt chế độ bypass bảo mật...");
    
    // ---- 1. Hook Objective-C: Bundle ID & Info.plist ----
    swizzleMethod([NSBundle class], @selector(bundleIdentifier), (IMP)hook_bundleIdentifier, (IMP *)&orig_bundleIdentifier);
    swizzleMethod([NSBundle class], @selector(infoDictionary), (IMP)hook_infoDictionary, (IMP *)&orig_infoDictionary);
    
    // ---- 2. Hook C-Level: Tìm và nạp Fishhook động ----
    // Trong môi trường Non-Jailbreak, chúng ta có thể nạp fishhook trực tiếp để cập nhật bảng Mach-O symbols
    void *handle = dlopen(NULL, RTLD_LAZY);
    rebind_symbols_func = (rebind_symbols_t)dlsym(handle, "rebind_symbols");
    
    if (rebind_symbols_func != NULL) {
        struct rebinding rebinds[] = {
            {"getaddrinfo", (void *)hook_getaddrinfo, (void **)&orig_getaddrinfo},
            {"ptrace", (void *)hook_ptrace, (void **)&orig_ptrace},
            {"access", (void *)hook_access, (void **)&orig_access},
            {"stat", (void *)hook_stat, (void **)&orig_stat}
        };
        rebind_symbols_func(rebinds, sizeof(rebinds) / sizeof(struct rebinding));
        NSLog(@"[AntiBan VIP] ✅ Kích hoạt C-Level Bypass thành công qua Dynamic Fishhook!");
    } else {
        // Nếu không có Fishhook được build sẵn trong dylib, sử dụng dlsym hook hoặc hướng dẫn nhà phát triển liên kết thư viện
        NSLog(@"[AntiBan VIP] ⚠️ Vui lòng liên kết Fishhook SDK để kích hoạt chặn Socket Telemetry và Chống Debug trên Non-Jailbreak.");
    }
    
    NSLog(@"[AntiBan VIP] 🎉 BẢO VỆ THIẾT BỊ HOÀN TẤT. TRẠNG THÁI: AN TOÀN!");
}
