#import "WRHardening.h"
#import "fishhook.h"
#import <objc/runtime.h>
#import <dlfcn.h>
#import <sys/stat.h>

static int (*orig_stat)(const char*, struct stat*)=NULL;
static int wr_stat(const char *path, struct stat *buf){
    if (path){
        NSString *p=[NSString stringWithUTF8String:path];
        if ([p containsString:@"/var/jb"]||[p containsString:@"Cydia"]||[p containsString:@"Substrate"]||[p containsString:@"WhamRaptor"]){
            errno=ENOENT; return -1;
        }
    }
    return orig_stat?orig_stat(path,buf):-1;
}
static int (*orig_access)(const char*, int)=NULL;
static int wr_access(const char *path, int mode){
    if (path){
        NSString *p=[NSString stringWithUTF8String:path];
        if ([p containsString:@"/var/jb"]||[p containsString:@"Cydia"]||[p containsString:@"Substrate"]){
            errno=ENOENT; return -1;
        }
    }
    return orig_access?orig_access(path,mode):-1;
}

@implementation WRHardening
+ (void)install {
    rebind_symbols((struct rebinding[]){{"stat", wr_stat, (void**)&orig_stat},{"access", wr_access, (void**)&orig_access}},2);
    // DeviceCheck / AppAttest bypass
    Class dc=NSClassFromString(@"DCDevice");
    if (dc){
        Method m=class_getInstanceMethod(dc, @selector(generateTokenWithCompletionHandler:));
        if (m){
            IMP n=imp_implementationWithBlock(^(id self, void(^completion)(NSData*,NSError*)){
                if (completion) completion(nil,[NSError errorWithDomain:@"DCErrorDomain" code:1 userInfo:@{NSLocalizedDescriptionKey:@"not supported"}]);
            });
            method_setImplementation(m, n);
        }
        Method m2=class_getClassMethod(dc, @selector(currentDevice));
        // leave as is
    }
    Class attest=NSClassFromString(@"DCAppAttestService");
    if (attest){
        for (NSString *selStr in @[@"generateKeyWithCompletionHandler:",@"attestKey:clientDataHash:completionHandler:",@"generateAssertion:clientDataHash:completionHandler:"]){
            Method mm=class_getInstanceMethod(attest, NSSelectorFromString(selStr));
            if (mm){
                IMP n=imp_implementationWithBlock(^(id self, id a, id b, void(^c)(id,NSError*)){ if(c) c(nil,[NSError errorWithDomain:@"AppAttest" code:1 userInfo:nil]); });
                // different signatures but block will still be called with error
                method_setImplementation(mm, n);
            }
        }
    }
}
@end
