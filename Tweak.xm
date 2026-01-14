#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <dlfcn.h>
#import <mach-o/dyld.h>
#import <sys/stat.h>
#import <sys/sysctl.h>
#import <objc/runtime.h>
#import <mach/mach.h>
#import <vector>
#import <string>
#import <thread>
#import <chrono>

// --- حل مشكلة PT_DENY_ATTACH ---
#ifndef PT_DENY_ATTACH
#define PT_DENY_ATTACH 31
#endif

// تعريف دالة ptrace
extern "C" int ptrace(int request, pid_t pid, caddr_t addr, int data);

// ==================================================================
// 1. دوال المساعدة (Helper Functions)
// ==================================================================

uint64_t getShadowBase() {
    uint32_t count = _dyld_image_count();
    for (uint32_t i = 0; i < count; i++) {
        const char *name = _dyld_get_image_name(i);
        if (name && strstr(name, "ShadowTrackerExtra")) {
            return (uint64_t)_dyld_get_image_header(i);
        }
    }
    return 0;
}

std::vector<uint8_t> hexToBytes(const std::string& hex) {
    std::vector<uint8_t> bytes;
    for (unsigned int i = 0; i < hex.length(); i += 2) {
        std::string byteString = hex.substr(i, 2);
        uint8_t byte = (uint8_t)strtol(byteString.c_str(), NULL, 16);
        bytes.push_back(byte);
    }
    return bytes;
}

void v12(uint64_t offset, std::string hex) {
    static uint64_t base = 0;
    if (base == 0) base = getShadowBase();
    if (base == 0) return;

    uint64_t address = base + offset;
    std::vector<uint8_t> data = hexToBytes(hex);
    
    kern_return_t kret = vm_protect(mach_task_self(), (vm_address_t)address, data.size(), 0, VM_PROT_READ | VM_PROT_WRITE | VM_PROT_COPY);
    if (kret == KERN_SUCCESS) {
        vm_write(mach_task_self(), address, (vm_offset_t)data.data(), data.size());
    }
}

// ==================================================================
// 2. منطق تشغيل الهاك (مفصول لتجنب الأخطاء)
// ==================================================================

void StartHacks() {
    // ننتظر حتى يتم تحميل ShadowTrackerExtra
    // نحاول لمدة 60 ثانية كحد أقصى لتجنب تعليق الثريد للأبد
    int attempts = 0;
    while (getShadowBase() == 0 && attempts < 600) { // 600 * 100ms = 60 seconds
        std::this_thread::sleep_for(std::chrono::milliseconds(100));
        attempts++;
    }

    if (getShadowBase() == 0) return; // لم نجد اللعبة، نخرج

    // انتظار بسيط للاستقرار
    std::this_thread::sleep_for(std::chrono::seconds(3));

    // --- تفعيل الأكواد ---

    // Aimbot
    v12(0x2A606EC, "08F0271E");

    // Recoil
    v12(0x2ECF414, "C0035FD6");

    // Small Aim
    v12(0x2ECC204, "E003271E");

    // White Color
    v12(0x60444C0, "0849B85228593AB8");
}

// ==================================================================
// 3. نظام الحماية (Protection System)
// ==================================================================

@interface ExternalAppDetector : NSObject
- (void)hideExternalApps;
@end
@implementation ExternalAppDetector
- (void)hideExternalApps { NSLog(@"[BYTEPASS] 🛡️ External Apps Hidden"); }
@end

@interface ProcessProtector : NSObject
- (void)antiDebug;
@end
@implementation ProcessProtector
- (void)antiDebug { ptrace(PT_DENY_ATTACH, 0, 0, 0); }
@end

// ==================================================================
// 4. التشغيل (Constructor)
// ==================================================================

%ctor {
    @autoreleasepool {
        // تشغيل الحماية في المسار الرئيسي
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            ExternalAppDetector *detector = [ExternalAppDetector new];
            [detector hideExternalApps];
            
            ProcessProtector *protector = [ProcessProtector new];
            [protector antiDebug];
            
            NSLog(@"[MuntadharMod] Protection Active");
        });

        // تشغيل الهاك في ثريد منفصل (بدون تداخل أقواس)
        std::thread(StartHacks).detach();
    }
}
