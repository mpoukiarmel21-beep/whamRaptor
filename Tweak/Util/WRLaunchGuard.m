#import "WRLaunchGuard.h"
#import "WRPaths.h"
@implementation WRLaunchGuard
+ (NSMutableDictionary*)loadState {
    NSDictionary *d=[NSDictionary dictionaryWithContentsOfFile:WRPaths.launchGuardPath];
    return d? [d mutableCopy] : [NSMutableDictionary dictionary];
}
+ (void)saveState:(NSDictionary*)s{ [s writeToFile:WRPaths.launchGuardPath atomically:YES]; }
+ (void)check {
    NSMutableDictionary *s=[self loadState];
    NSInteger streak=[s[@"crashStreak"] integerValue];
    NSTimeInterval last=[s[@"lastLaunch"] doubleValue];
    NSTimeInterval now=NSDate.date.timeIntervalSince1970;
    // if last launch < 25s ago, consider crash
    if (last>0 && now-last<25) streak++;
    else if (now-last>120) streak=0;
    s[@"lastLaunch"]=@(now);
    s[@"crashStreak"]=@(streak);
    [self saveState:s];
}
+ (BOOL)isSafeMode {
    NSDictionary *s=[NSDictionary dictionaryWithContentsOfFile:WRPaths.launchGuardPath];
    return [s[@"crashStreak"] integerValue]>=3;
}
+ (void)markLaunchSuccess {
    NSMutableDictionary *s=[self loadState];
    s[@"crashStreak"]=@0;
    [self saveState:s];
}
+ (void)enableAgain { NSMutableDictionary *s=[self loadState]; s[@"crashStreak"]=@0; s[@"safeAcknowledged"]=@(NSDate.date.timeIntervalSince1970); [self saveState:s]; }
@end
