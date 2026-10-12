#import "WRKeychainHook.h"
#import "WRContainerStore.h"
#import "fishhook.h"
#import <Security/Security.h>

static OSStatus (*orig_SecItemAdd)(CFDictionaryRef, CFTypeRef*)=NULL;
static OSStatus (*orig_SecItemCopyMatching)(CFDictionaryRef, CFTypeRef*)=NULL;
static OSStatus (*orig_SecItemUpdate)(CFDictionaryRef, CFDictionaryRef)=NULL;
static OSStatus (*orig_SecItemDelete)(CFDictionaryRef)=NULL;

static NSString *wr_prefix(void){
    WRContainer *c=WRContainerStore.shared.activeContainer;
    return c? [NSString stringWithFormat:@"wr.%@.", c.containerID] : nil;
}
static CFDictionaryRef wr_scoped(CFDictionaryRef q){
    NSString *prefix=wr_prefix(); if (!prefix) return q;
    NSMutableDictionary *m=[(__bridge NSDictionary*)q mutableCopy] ?: [NSMutableDictionary dictionary];
    NSString *svc=m[(__bridge id)kSecAttrService];
    if ([svc isKindOfClass:NSString.class] && ![svc hasPrefix:prefix]) m[(__bridge id)kSecAttrService]=[prefix stringByAppendingString:svc];
    // also tag account for extra isolation if service missing
    return (__bridge_retained CFDictionaryRef)m;
}

static OSStatus wr_SecItemAdd(CFDictionaryRef q, CFTypeRef *r){ CFDictionaryRef nq=wr_scoped(q); OSStatus s=orig_SecItemAdd?orig_SecItemAdd(nq,r):errSecParam; if(nq!=q) CFRelease(nq); return s; }
static OSStatus wr_SecItemCopyMatching(CFDictionaryRef q, CFTypeRef *r){ CFDictionaryRef nq=wr_scoped(q); OSStatus s=orig_SecItemCopyMatching?orig_SecItemCopyMatching(nq,r):errSecParam; if(nq!=q) CFRelease(nq); return s; }
static OSStatus wr_SecItemUpdate(CFDictionaryRef q, CFDictionaryRef a){ CFDictionaryRef nq=wr_scoped(q); OSStatus s=orig_SecItemUpdate?orig_SecItemUpdate(nq,a):errSecParam; if(nq!=q) CFRelease(nq); return s; }
static OSStatus wr_SecItemDelete(CFDictionaryRef q){ CFDictionaryRef nq=wr_scoped(q); OSStatus s=orig_SecItemDelete?orig_SecItemDelete(nq):errSecParam; if(nq!=q) CFRelease(nq); return s; }

@implementation WRKeychainHook
+ (void)install {
    rebind_symbols((struct rebinding[]){
        {"SecItemAdd", wr_SecItemAdd, (void**)&orig_SecItemAdd},
        {"SecItemCopyMatching", wr_SecItemCopyMatching, (void**)&orig_SecItemCopyMatching},
        {"SecItemUpdate", wr_SecItemUpdate, (void**)&orig_SecItemUpdate},
        {"SecItemDelete", wr_SecItemDelete, (void**)&orig_SecItemDelete},
    },4);
}
@end
