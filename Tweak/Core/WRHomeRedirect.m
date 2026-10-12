#import "WRHomeRedirect.h"
#import "WRContainerStore.h"
#import "WRPaths.h"
#import "fishhook.h"
#import <Foundation/Foundation.h>
#import <dlfcn.h>
#import <string.h>
#import <unistd.h>

static NSString *gOrigHome=nil;

@implementation WRHomeRedirect

static char *(*orig_getenv)(const char *) = NULL;
static const char *wr_getenv(const char *name) {
    if (name && strcmp(name,"HOME")==0) {
        NSString *h=[WRHomeRedirect activeHomePath];
        if (h) return h.UTF8String;
    }
    return orig_getenv ? orig_getenv(name) : NULL;
}

static NSString *(*orig_NSHomeDirectory)(void) = NULL;
static NSString *wr_NSHomeDirectory(void) {
    NSString *h=[WRHomeRedirect activeHomePath];
    if (h) return h;
    return orig_NSHomeDirectory ? orig_NSHomeDirectory() : @"/";
}

static NSString *(*orig_NSHomeDirectoryForUser)(NSString*) = NULL;
static NSString *wr_NSHomeDirectoryForUser(NSString *u) {
    NSString *h=[WRHomeRedirect activeHomePath];
    if (h && u==nil) return h;
    return orig_NSHomeDirectoryForUser ? orig_NSHomeDirectoryForUser(u) : nil;
}

+ (nullable NSString *)activeHomePath {
    WRContainer *c=WRContainerStore.shared.activeContainer;
    if (!c) return nil;
    NSString *p=[WRPaths containerHomeForID:c.containerID];
    // ensure exists
    if (![NSFileManager.defaultManager fileExistsAtPath:p]) [NSFileManager.defaultManager createDirectoryAtPath:p withIntermediateDirectories:YES attributes:nil error:nil];
    return p;
}

+ (void)install {
    gOrigHome=[NSHomeDirectory() copy];
    // fishhook low-level
    orig_getenv = dlsym(RTLD_DEFAULT, "getenv");
    rebind_symbols((struct rebinding[]){ {"getenv", wr_getenv, (void**)&orig_getenv} }, 1);
    // ObjC swizzle NSHomeDirectory
    Method m1=class_getClassMethod(NSClassFromString(@"NSFileManager") ?: [NSObject class], @selector(defaultManager));
    (void)m1;
    // Use fishhook for Foundation's NSHomeDirectory via dlsym rebind is more reliable:
    // also swizzle via method_exchange for safety
    // NSHomeDirectory is a C function, rebind already handles it if linked. Also hook via replacement function pointer if needed.
    // For NSHomeDirectory() we need to rebind the symbol itself
    void *hdl=dlopen("/System/Library/Frameworks/Foundation.framework/Foundation", RTLD_NOW);
    if (hdl) {
        void *sym=dlsym(hdl, "NSHomeDirectory");
        if (sym) {
            orig_NSHomeDirectory = (void*)sym;
            rebind_symbols((struct rebinding[]){ {"NSHomeDirectory", wr_NSHomeDirectory, (void**)&orig_NSHomeDirectory} }, 1);
        }
        void *sym2=dlsym(hdl, "NSHomeDirectoryForUser");
        if (sym2) {
            orig_NSHomeDirectoryForUser=(void*)sym2;
            rebind_symbols((struct rebinding[]){ {"NSHomeDirectoryForUser", wr_NSHomeDirectoryForUser, (void**)&orig_NSHomeDirectoryForUser} }, 1);
        }
        dlclose(hdl);
    }
    // Also set HOME env for current process
    NSString *h=[self activeHomePath];
    if (h) setenv("HOME", h.UTF8String, 1);
}

@end
