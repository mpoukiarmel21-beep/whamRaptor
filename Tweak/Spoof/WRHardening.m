#import "WRHardening.h"
#import "fishhook.h"
#import <objc/runtime.h>
#import <dlfcn.h>
#import <sys/stat.h>
#import <string.h>
#import <errno.h>

static BOOL wr_pathIsBlocked(const char *path) {
    if (!path) return NO;
    // Pure C, no ObjC alloc — safe from constructor re-entrancy
    if (strstr(path, "/var/jb")) return YES;
    if (strstr(path, "Cydia")) return YES;
    if (strstr(path, "Substrate")) return YES;
    if (strstr(path, "WhamRaptor")) return YES;
    return NO;
}

static int (*orig_stat)(const char*, struct stat*)=NULL;
static int wr_stat(const char *path, struct stat *buf){
    if (wr_pathIsBlocked(path)) { errno=ENOENT; return -1; }
    return orig_stat ? orig_stat(path, buf) : -1;
}
static int (*orig_access)(const char*, int)=NULL;
static int wr_access(const char *path, int mode){
    if (wr_pathIsBlocked(path)) { errno=ENOENT; return -1; }
    return orig_access ? orig_access(path, mode) : -1;
}

@implementation WRHardening
+ (void)install {
    @try {
        rebind_symbols((struct rebinding[]){{"stat", (void *)wr_stat, (void **)&orig_stat},{"access", (void *)wr_access, (void **)&orig_access}}, 2);
    } @catch(...) {}
    @try {
        Class dc=NSClassFromString(@"DCDevice");
        if (dc){
            Method m=class_getInstanceMethod(dc, @selector(generateTokenWithCompletionHandler:));
            if (m){
                IMP n=imp_implementationWithBlock(^(id _self, void(^completion)(NSData*,NSError*)){
                    if (completion) completion(nil,[NSError errorWithDomain:@"DCErrorDomain" code:1 userInfo:@{NSLocalizedDescriptionKey:@"not supported"}]);
                });
                method_setImplementation(m, n);
            }
        }
    } @catch(...) {}
    @try {
        Class attest=NSClassFromString(@"DCAppAttestService");
        if (attest){
            for (NSString *selStr in @[@"generateKeyWithCompletionHandler:",@"attestKey:clientDataHash:completionHandler:",@"generateAssertion:clientDataHash:completionHandler:"]){
                Method mm=class_getInstanceMethod(attest, NSSelectorFromString(selStr));
                if (mm){
                    IMP n=imp_implementationWithBlock(^(id _self, id a, id b, void(^c)(id,NSError*)){ if(c) c(nil,[NSError errorWithDomain:@"AppAttest" code:1 userInfo:nil]); });
                    method_setImplementation(mm, n);
                }
            }
        }
    } @catch(...) {}
}
@end
