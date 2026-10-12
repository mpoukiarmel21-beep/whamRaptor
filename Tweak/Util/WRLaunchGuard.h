#import <Foundation/Foundation.h>
@interface WRLaunchGuard : NSObject
+ (void)check; // call early
+ (BOOL)isSafeMode;
+ (void)markLaunchSuccess;
+ (void)enableAgain;
@end
