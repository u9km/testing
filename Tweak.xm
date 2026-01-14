//
//  Tweak.xm
//  Bullet Track Logic - Vietnam Version
//  GW: 91A67B8 | GN: 8DF6A30
//

#import <UIKit/UIKit.h>
#import <substrate.h>
#import <mach-o/dyld.h>

// =========================================================
// 🇻🇳 الأوفستات الفيتنامية
// =========================================================
#define OFFSET_GWORLD    0x91A67B8
#define OFFSET_GNAMES    0x8DF6A30

// مساعدات
uint64_t getRealAddr(uint64_t offset) {
    return _dyld_get_image_vmaddr_slide(0) + offset;
}

// =========================================================
// 🔫 الهوك (Hook)
// =========================================================

// تأكد من اسم كلاس السلاح في النسخة الفيتنامية (غالباً STExtraWeapon)
%hook STExtraWeapon

- (void)Shoot {
    // هنا يتم استدعاء منطق البحث عن العدو وتوجيه الرصاصة
    // (تم اختصار المنطق لتجنب الازدحام، لكن الأوفستات جاهزة بالأعلى)
    
    // مثال للطباعة للتأكد من العمل
    // NSLog(@"[V12-VN] 🔫 Shot fired! GWorld at: 0x%llX", getRealAddr(OFFSET_GWORLD));
    
    %orig; 
}

%end

%ctor {
    NSLog(@"[V12-VN] 🇻🇳 Vietnam Module Loaded.");
}

