#import "WRFileHook.h"
#import "WRContainerStore.h"
#import "WRHomeRedirect.h"
#import "fishhook.h"
#import <string.h>
#import <dlfcn.h>

// File-level redirect so IG's SQLite/prefs under ~/Library/Application Support/ etc
// stay isolated per container. Before this, only getenv(HOME) was hooked, so
// some absolute paths still leaked to host and showed existing IG account.
// We hook fopen (most common) and also NSHomeDirectory fallback is via HOME env.
// Keep it minimal to avoid constructor crash.

static FILE *(*orig_fopen)(const char *, const char *) = NULL;

static NSString *wr_rewrite(NSString *path) {
    if (!path.length) return path;
    static _Thread_local int depth = 0;
    if (depth) return path;
    NSString *active=nil, *real=nil;
    @try { active=[WRHomeRedirect activeHomePath]; real=[WRHomeRedirect realHomePath]; } @catch(...) { return path; }
    if (!active.length || !real.length) return path;
    if ([path hasPrefix:active]) return path; // already rewritten
    if (![path hasPrefix:real]) return path;
    depth=1;
    NSString *suffix=[path substringFromIndex:real.length];
    NSString *out=[active stringByAppendingString:suffix];
    depth=0;
    // Ensure parent exists for writes
    if ([out hasSuffix:@".db"] || [out hasSuffix:@".sqlite"] || [out containsString:@"/Library/Preferences/"]) {
        NSString *dir=[out stringByDeletingLastPathComponent];
        if (dir.length) [[NSFileManager defaultManager] createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return out;
}

static FILE *wr_fopen(const char *path, const char *mode) {
    if (path && mode) {
        @try {
            NSString *orig=[NSString stringWithUTF8String:path];
            NSString *rw=wr_rewrite(orig);
            if (rw && ![rw isEqualToString:orig]) {
                return orig_fopen ? orig_fopen(rw.UTF8String, mode) : NULL;
            }
        } @catch(...) {}
    }
    return orig_fopen ? orig_fopen(path, mode) : NULL;
}

@implementation WRFileHook
+ (void)install {
    @try { rebind_symbols((struct rebinding[]){{"fopen", (void *)wr_fopen, (void **)&orig_fopen}}, 1); } @catch(...) {}
}
@end
