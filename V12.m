//
//  V12.m
//  V12 Ultimate Protection (Universal & Non-JB Safe)
//  Fixed for Compiler Errors
//  Developed for: Muntadhar
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <sys/sysctl.h>
#import <dlfcn.h>
#import <mach/mach.h>
#import <objc/runtime.h>

// تعريف ptrace ديناميكياً
typedef int (*ptrace_ptr_t)(int _request, pid_t _pid, caddr_t _addr, int _data);
#define PT_DENY_ATTACH 31

@interface V12Shield : NSObject
@end

@implementation V12Shield

// ------------------------------------------------------------------
// 🛡️ 1. نظام منع التصحيح (Stealth Anti-Debug)
// ------------------------------------------------------------------
+ (void)applyAntiDebug {
    void *handle = dlopen(0, RTLD_GLOBAL | RTLD_NOW);
    if (handle) {
        ptrace_ptr_t ptrace_ptr = (ptrace_ptr_t)dlsym(handle, "ptrace");
        if (ptrace_ptr) {
            ptrace_ptr(PT_DENY_ATTACH, 0, 0, 0);
        }
        dlclose(handle);
    }
}

// ------------------------------------------------------------------
// 🔍 2. فحص الأدوات المحظورة (Process Scan)
// ------------------------------------------------------------------
+ (BOOL)scanForThreats {
    NSArray *threats = @[
        @"Cydia", @"Sileo", @"Zebra", @"Filza", 
        @"iGameGod", @"DLGMemor", @"CheatEngine", 
        @"frida-server", @"cycript", @"Satella",
        @"FLEX", @"Jailed"
    ];

    int mib[4] = {CTL_KERN, KERN_PROC, KERN_PROC_ALL, 0};
    size_t size;
    // التأكد من نجاح الاستدعاء الأول
    if (sysctl(mib, 4, NULL, &size, NULL, 0) == -1) return NO;

    struct kinfo_proc *procs = malloc(size);
    // التأكد من نجاح الاستدعاء الثاني وتوفر الذاكرة
    if (procs == NULL || sysctl(mib, 4, procs, &size, NULL, 0) == -1) {
        if (procs) free(procs);
        return NO;
    }

    int count = (int)(size / sizeof(struct kinfo_proc));
    BOOL found = NO;

    for (int i = 0; i < count; i++) {
        // ✅ التصحيح: التحقق من أن الاسم ليس فارغاً بدلاً من التحقق من المصفوفة نفسها
        if (procs[i].kp_proc.p_comm[0] != '\0') {
            NSString *procName = [NSString stringWithUTF8String:procs[i].kp_proc.p_comm];
            
            // حماية إضافية: التأكد من أن تحويل السترينغ نجح
            if (procName) {
                for (NSString *threat in threats) {
                    if ([procName localizedCaseInsensitiveContainsString:threat]) {
                        found = YES;
                        break;
                    }
                }
            }
        }
        if (found) break;
    }
    
    free(procs);
    return found;
}

// ------------------------------------------------------------------
// 🎭 3. نظام التمويه (Device Spoofing)
// ------------------------------------------------------------------
+ (void)activateSpoofing {
    Method originalVer = class_getInstanceMethod([UIDevice class], @selector(systemVersion));
    Method swizzledVer = class_getInstanceMethod([self class], @selector(fakeVersion));
    method_exchangeImplementations(originalVer, swizzledVer);

    Method originalName = class_getInstanceMethod([UIDevice class], @selector(name));
    Method swizzledName = class_getInstanceMethod([self class], @selector(fakeName));
    method_exchangeImplementations(originalName, swizzledName);
}

- (NSString *)fakeVersion { return @"18.2"; }
- (NSString *)fakeName { return @"iPhone 16 Pro Max"; }

@end

// ------------------------------------------------------------------
// ⚡ المحرك التلقائي (Auto-Constructor)
// ------------------------------------------------------------------
__attribute__((constructor))
static void V12_Entry() {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSLog(@"[V12] 🦅 Protection Engine Started.");
            [V12Shield applyAntiDebug];
            [V12Shield activateSpoofing];
            if ([V12Shield scanForThreats]) {
                NSLog(@"[V12] ⚠️ Security Warning: Unsafe environment detected.");
            }
            NSLog(@"[V12] ✅ Environment Secured.");
        });
    });
}
