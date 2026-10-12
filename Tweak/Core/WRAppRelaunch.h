#import <Foundation/Foundation.h>
@interface WRAppRelaunch : NSObject
+ (void)relaunch; // exit + springboard will relaunch or user reopens
+ (void)relaunchWithDelay:(NSTimeInterval)s;
@end
