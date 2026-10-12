#import "WRDeviceIdentity.h"
#import <sys/utsname.h>
#import <UIKit/UIKit.h>

@implementation WRDeviceIdentityFactory

// Host chip detection -> propose same-chip family
+ (NSString *)hostChip {
    NSString *machine=nil;
    struct utsname u; if (uname(&u)==0) machine=[NSString stringWithUTF8String:u.machine];
    NSDictionary *m=[self deviceForMachine:machine?:@""];
    return m[@"chip"] ?: @"A16";
}

+ (NSArray<NSDictionary*>*)allDevices {
    // iOS 26 (2025) + iOS 27 (2026) — two latest. Chip-aware families.
    // A13 (iPhone 11 family), A14 (12), A15 (13), A16 (14/15), A17 Pro (15 Pro), A18 (16), A19 (17 expected)
    return @[
        // A13 — iPhone 11
        @{@"machine":@"iPhone12,1",@"name":@"iPhone 11",@"chip":@"A13",@"family":@"A13"},
        @{@"machine":@"iPhone12,3",@"name":@"iPhone 11 Pro",@"chip":@"A13",@"family":@"A13"},
        @{@"machine":@"iPhone12,5",@"name":@"iPhone 11 Pro Max",@"chip":@"A13",@"family":@"A13"},
        // A14 — 12
        @{@"machine":@"iPhone13,1",@"name":@"iPhone 12 mini",@"chip":@"A14",@"family":@"A14"},
        @{@"machine":@"iPhone13,2",@"name":@"iPhone 12",@"chip":@"A14",@"family":@"A14"},
        @{@"machine":@"iPhone13,3",@"name":@"iPhone 12 Pro",@"chip":@"A14",@"family":@"A14"},
        @{@"machine":@"iPhone13,4",@"name":@"iPhone 12 Pro Max",@"chip":@"A14",@"family":@"A14"},
        // A15 — 13 / SE3
        @{@"machine":@"iPhone14,4",@"name":@"iPhone 13 mini",@"chip":@"A15",@"family":@"A15"},
        @{@"machine":@"iPhone14,5",@"name":@"iPhone 13",@"chip":@"A15",@"family":@"A15"},
        @{@"machine":@"iPhone14,2",@"name":@"iPhone 13 Pro",@"chip":@"A15",@"family":@"A15"},
        @{@"machine":@"iPhone14,3",@"name":@"iPhone 13 Pro Max",@"chip":@"A15",@"family":@"A15"},
        @{@"machine":@"iPhone14,6",@"name":@"iPhone SE (3rd gen)",@"chip":@"A15",@"family":@"A15"},
        // A16 — 14/15
        @{@"machine":@"iPhone14,7",@"name":@"iPhone 13 mini (alt)",@"chip":@"A15",@"family":@"A15"},
        @{@"machine":@"iPhone15,2",@"name":@"iPhone 14 Pro",@"chip":@"A16",@"family":@"A16"},
        @{@"machine":@"iPhone15,3",@"name":@"iPhone 14 Pro Max",@"chip":@"A16",@"family":@"A16"},
        @{@"machine":@"iPhone15,4",@"name":@"iPhone 15",@"chip":@"A16",@"family":@"A16"},
        @{@"machine":@"iPhone15,5",@"name":@"iPhone 15 Plus",@"chip":@"A16",@"family":@"A16"},
        @{@"machine":@"iPhone14,8",@"name":@"iPhone 14 Plus",@"chip":@"A15",@"family":@"A15"},
        @{@"machine":@"iPhone15,2",@"name":@"iPhone 14 Pro",@"chip":@"A16",@"family":@"A16"},
        // A17 Pro — 15 Pro
        @{@"machine":@"iPhone16,1",@"name":@"iPhone 15 Pro",@"chip":@"A17 Pro",@"family":@"A17P"},
        @{@"machine":@"iPhone16,2",@"name":@"iPhone 15 Pro Max",@"chip":@"A17 Pro",@"family":@"A17P"},
        // A18 — 16 family (2024-2025)
        @{@"machine":@"iPhone17,1",@"name":@"iPhone 16",@"chip":@"A18",@"family":@"A18"},
        @{@"machine":@"iPhone17,2",@"name":@"iPhone 16 Plus",@"chip":@"A18",@"family":@"A18"},
        @{@"machine":@"iPhone17,3",@"name":@"iPhone 16 Pro",@"chip":@"A18 Pro",@"family":@"A18P"},
        @{@"machine":@"iPhone17,4",@"name":@"iPhone 16 Pro Max",@"chip":@"A18 Pro",@"family":@"A18P"},
        @{@"machine":@"iPhone17,5",@"name":@"iPhone 16e",@"chip":@"A18",@"family":@"A18"},
        // A19 — 17 family (2026 expected, iOS 27)
        @{@"machine":@"iPhone18,1",@"name":@"iPhone 17",@"chip":@"A19",@"family":@"A19"},
        @{@"machine":@"iPhone18,2",@"name":@"iPhone 17 Plus",@"chip":@"A19",@"family":@"A19"},
        @{@"machine":@"iPhone18,3",@"name":@"iPhone 17 Pro",@"chip":@"A19 Pro",@"family":@"A19P"},
        @{@"machine":@"iPhone18,4",@"name":@"iPhone 17 Pro Max",@"chip":@"A19 Pro",@"family":@"A19P"},
        @{@"machine":@"iPhone18,5",@"name":@"iPhone Air",@"chip":@"A19 Pro",@"family":@"A19P"},
    ];
}
+ (NSDictionary*)deviceForMachine:(NSString*)m {
    for (NSDictionary *d in self.allDevices) if ([d[@"machine"] isEqualToString:m]) return d;
    return nil;
}

+ (NSString*)randomSerial {
    NSString *chars=@"ABCDEFGHJKLMNPQRSTUVWXYZ0123456789";
    NSMutableString *s=[NSMutableString string];
    for (int i=0;i<10;i++) [s appendFormat:@"%C",[chars characterAtIndex:arc4random_uniform((uint32_t)chars.length)]];
    return s;
}
+ (NSString*)randomUUID { return NSUUID.UUID.UUIDString; }

+ (WRDeviceIdentity*)generateIdentity {
    NSString *hostChip=[self hostChip];
    // Filter same family if possible for realism (e.g. A13 host -> propose A13 pool)
    NSString *hostFamily=nil;
    for (NSDictionary *d in self.allDevices) if ([d[@"chip"] isEqualToString:hostChip]) { hostFamily=d[@"family"]; break; }
    NSArray *pool=self.allDevices;
    if (hostFamily) {
        NSArray *same=[pool filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"family == %@", hostFamily]];
        if (same.count>=2) pool=same; // keep diversity but prefer same chip
    }
    NSDictionary *pick=pool[arc4random_uniform((uint32_t)pool.count)];
    WRDeviceIdentity *idn=[WRDeviceIdentity new];
    idn.model=pick[@"machine"];
    idn.machine=pick[@"machine"];
    idn.marketingName=pick[@"name"];
    idn.chip=pick[@"chip"];
    // iOS pool = 26.x and 27.x (two latest)
    NSArray *osPool=@[@"26.0",@"26.1",@"26.2",@"27.0",@"27.1"];
    idn.systemVersion=osPool[arc4random_uniform((uint32_t)osPool.count)];
    idn.systemName=@"iOS";
    idn.deviceName=@"iPhone";
    idn.serialNumber=self.randomSerial;
    idn.identifierForVendor=self.randomUUID;
    idn.advertisingIdentifier=self.randomUUID;
    return idn;
}
@end
