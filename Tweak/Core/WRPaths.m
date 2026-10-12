#import "WRPaths.h"
#import "WRHomeRedirect.h"

@implementation WRPaths
+ (NSString *)rootDir {
    // Must NOT call NSHomeDirectory (it may be hooked or recurse via WRContainerStore → WRPaths)
    NSString *home = [WRHomeRedirect realHomePath];
    return [home stringByAppendingPathComponent:@"Documents/WhamRaptor"];
}
+ (NSString *)containersDir { return [[self rootDir] stringByAppendingPathComponent:@"containers"]; }
+ (NSString *)storePlistPath { return [[self rootDir] stringByAppendingPathComponent:@"containers.plist"]; }
+ (NSString *)activeContainerIDPath { return [[self rootDir] stringByAppendingPathComponent:@"active.txt"]; }
+ (NSString *)launchGuardPath { return [[self rootDir] stringByAppendingPathComponent:@"launch_guard.plist"]; }
+ (NSString *)diagnosticsLogPath { return [[self rootDir] stringByAppendingPathComponent:@"diagnostics.log"]; }
+ (NSString *)containerDirForID:(NSString *)cid { return [[self containersDir] stringByAppendingPathComponent:cid]; }
+ (NSString *)containerHomeForID:(NSString *)cid { return [[self containerDirForID:cid] stringByAppendingPathComponent:@"Home"]; }
+ (NSString *)containerLibraryForID:(NSString *)cid { return [[self containerHomeForID:cid] stringByAppendingPathComponent:@"Library"]; }
+ (NSString *)containerTmpForID:(NSString *)cid { return [[self containerHomeForID:cid] stringByAppendingPathComponent:@"tmp"]; }
+ (void)ensureBaseDirs {
    NSFileManager *fm = NSFileManager.defaultManager;
    for (NSString *p in @[self.rootDir, self.containersDir]) {
        if (![fm fileExistsAtPath:p]) [fm createDirectoryAtPath:p withIntermediateDirectories:YES attributes:nil error:nil];
    }
}
@end
