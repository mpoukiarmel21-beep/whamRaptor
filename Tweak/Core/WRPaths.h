#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface WRPaths : NSObject
+ (NSString *)rootDir;
+ (NSString *)containersDir;
+ (NSString *)storePlistPath;
+ (NSString *)activeContainerIDPath;
+ (NSString *)launchGuardPath;
+ (NSString *)diagnosticsLogPath;
+ (NSString *)containerDirForID:(NSString *)cid;
+ (NSString *)containerHomeForID:(NSString *)cid;
+ (NSString *)containerLibraryForID:(NSString *)cid;
+ (NSString *)containerTmpForID:(NSString *)cid;
+ (void)ensureBaseDirs;
@end

NS_ASSUME_NONNULL_END
