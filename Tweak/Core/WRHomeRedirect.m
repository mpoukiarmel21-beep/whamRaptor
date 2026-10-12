#import "WRHomeRedirect.h"
#import "WRContainerStore.h"
#import "WRPaths.h"
#import "fishhook.h"
#import <Foundation/Foundation.h>
#import <dlfcn.h>
#import <string.h>
#import <unistd.h>
#import <objc/runtime.h>
#import <stdlib.h>

static char gRealHomeBuf[1024];
static BOOL gRealHomeInit = NO;
static void wr_initRealHome(void) {
    if (gRealHomeInit) return;
    gRealHomeInit = YES;
    const char *env = getenv("HOME");
    if (env && env[0]) { strncpy(gRealHomeBuf, env, sizeof(gRealHomeBuf)-1); return; }
    // Fallback via Foundation before we hook anything
    NSString *h = nil;
    @try { h = [NSHomeDirectory() copy]; } @catch(...) {}
    if (h.length) { strncpy(gRealHomeBuf, h.UTF8String, sizeof(gRealHomeBuf)-1); return; }
    // Last resort: /var/mobile
    strncpy(gRealHomeBuf, "/var/mobile", sizeof(gRealHomeBuf)-1);
}

@implementation WRHomeRedirect

// Must return a stable C-string. Never return autoreleased UTF8String.
static char *(*orig_getenv)(const char *) = NULL;
static char *wr_getenv(const char *name) {
    if (name && strcmp(name, "HOME") == 0) {
        NSString *h = [WRHomeRedirect activeHomePath];
        if (h) {
            // Use a thread-local static so caller can read it before next getenv.
            // We cannot return [h UTF8String] directly because it may be freed.
            static _Thread_local char buf[1024];
            strncpy(buf, h.UTF8String, sizeof(buf)-1);
            buf[sizeof(buf)-1] = '\0';
            return buf;
        }
    }
    return orig_getenv ? orig_getenv(name) : NULL;
}

+ (NSString *)realHomePath {
    wr_initRealHome();
    return gRealHomeBuf[0] ? [NSString stringWithUTF8String:gRealHomeBuf] : @"/var/mobile";
}

+ (nullable NSString *)activeHomePath {
    NSString *active = nil;
    @try { active = [[WRContainerStore shared] activeContainer] ? [WRPaths containerHomeForID:[WRContainerStore shared].activeContainer.containerID] : nil; } @catch(...) {}
    if (!active) return nil;
    // Ensure exists without calling NSHomeDirectory or getenv recursively
    NSFileManager *fm = NSFileManager.defaultManager;
    @try {
        if (![fm fileExistsAtPath:active]) [fm createDirectoryAtPath:active withIntermediateDirectories:YES attributes:nil error:nil];
    } @catch(...) {}
    return active;
}

+ (void)install {
    // Capture real HOME before any hook
    wr_initRealHome();
    // Install getenv hook last — it depends on WRPaths/Store which we want to read unhooked first
    orig_getenv = dlsym(RTLD_DEFAULT, "getenv");
    rebind_symbols((struct rebinding[]){{"getenv", (void *)wr_getenv, (void **)&orig_getenv}}, 1);
    // Set HOME env for child processes to active container if any
    @try {
        NSString *h = [self activeHomePath];
        if (h) setenv("HOME", h.UTF8String, 1);
    } @catch(...) {}
}

@end
