#import "WRKeychainHook.h"
#import "WRContainerStore.h"
#import "fishhook.h"
#import <Security/Security.h>

// Prefix all Keychain items with wr.<containerID>. so containers never see host's accounts.
// Host (no active container) = untouched — no ghost account appears.
// Container switching requires relaunch so SecItem reads happen after prefix is set.

static OSStatus (*orig_SecItemAdd)(CFDictionaryRef, CFTypeRef*)=NULL;
static OSStatus (*orig_SecItemCopyMatching)(CFDictionaryRef, CFTypeRef*)=NULL;
static OSStatus (*orig_SecItemUpdate)(CFDictionaryRef, CFDictionaryRef)=NULL;
static OSStatus (*orig_SecItemDelete)(CFDictionaryRef)=NULL;

static NSString *wr_prefix(void){
    WRContainer *c=nil;
    @try { c=WRContainerStore.shared.activeContainer; } @catch(...) {}
    return c ? [NSString stringWithFormat:@"wr.%@.", c.containerID] : nil;
}
static CFDictionaryRef wr_scoped(CFDictionaryRef q){
    NSString *prefix=wr_prefix(); if (!prefix || !q) return q;
    @try {
        NSMutableDictionary *m=[(__bridge NSDictionary*)q mutableCopy];
        if (!m) return q;
        // Only scope IG / FB related services; leave system services untouched
        NSString *svc=m[(__bridge id)kSecAttrService];
        NSString *acct=m[(__bridge id)kSecAttrAccount];
        // Scope any service that looks like IG/FB or is non-empty; don't scope empty service (could be system)
        if ([svc isKindOfClass:NSString.class] && svc.length && ![svc hasPrefix:prefix]) {
            // Avoid double-scope on already-prefixed items
            m[(__bridge id)kSecAttrService]=[prefix stringByAppendingString:svc];
        } else if ((!svc || !svc.length) && [acct isKindOfClass:NSString.class] && acct.length && ![acct hasPrefix:prefix]) {
            // Fallback: some IG items use account as key
            // Leave as-is for now; service is primary isolation.
        }
        return (__bridge_retained CFDictionaryRef)m;
    } @catch(...) { return q; }
}

static OSStatus wr_SecItemAdd(CFDictionaryRef q, CFTypeRef *r){ CFDictionaryRef nq=wr_scoped(q); OSStatus s=orig_SecItemAdd?orig_SecItemAdd(nq,r):errSecParam; if(nq!=q) CFRelease(nq); return s; }
static OSStatus wr_SecItemCopyMatching(CFDictionaryRef q, CFTypeRef *r){
    CFDictionaryRef nq=wr_scoped(q);
    OSStatus s=orig_SecItemCopyMatching ? orig_SecItemCopyMatching(nq, r) : errSecParam;
    if(nq!=q) CFRelease(nq);
    // Empty result for containers that haven't stored anything yet — IG will show login screen
    return s;
}
static OSStatus wr_SecItemUpdate(CFDictionaryRef q, CFDictionaryRef a){ CFDictionaryRef nq=wr_scoped(q); OSStatus s=orig_SecItemUpdate?orig_SecItemUpdate(nq,a):errSecParam; if(nq!=q) CFRelease(nq); return s; }
static OSStatus wr_SecItemDelete(CFDictionaryRef q){ CFDictionaryRef nq=wr_scoped(q); OSStatus s=orig_SecItemDelete?orig_SecItemDelete(nq):errSecParam; if(nq!=q) CFRelease(nq); return s; }

@implementation WRKeychainHook
+ (void)install {
    @try {
        rebind_symbols((struct rebinding[]){
            {"SecItemAdd", (void *)wr_SecItemAdd, (void **)&orig_SecItemAdd},
            {"SecItemCopyMatching", (void *)wr_SecItemCopyMatching, (void **)&orig_SecItemCopyMatching},
            {"SecItemUpdate", (void *)wr_SecItemUpdate, (void **)&orig_SecItemUpdate},
            {"SecItemDelete", (void *)wr_SecItemDelete, (void **)&orig_SecItemDelete},
        },4);
    } @catch(...) {}
}
@end
