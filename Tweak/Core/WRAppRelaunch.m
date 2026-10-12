#import "WRAppRelaunch.h"
#import <UIKit/UIKit.h>
@implementation WRAppRelaunch
+ (void)relaunch { [self relaunchWithDelay:0.45]; }
+ (void)relaunchWithDelay:(NSTimeInterval)s {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(s*NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // Preferred: exit gracefully so Sideloadly launch restarts with new HOME
        // Show brief overlay then exit
        UIWindow *w=UIApplication.sharedApplication.keyWindow;
        UIView *ov=[[UIView alloc] initWithFrame:w.bounds];
        ov.backgroundColor=[UIColor colorWithWhite:0 alpha:0.45];
        UILabel *lb=[[UILabel alloc] initWithFrame:CGRectMake(0,0,260,60)];
        lb.center=CGPointMake(w.bounds.size.width/2, w.bounds.size.height/2);
        lb.text=@"Changement de container…";
        lb.textAlignment=NSTextAlignmentCenter; lb.textColor=UIColor.whiteColor; lb.font=[UIFont boldSystemFontOfSize:15];
        lb.backgroundColor=[UIColor colorWithWhite:0.15 alpha:0.9]; lb.layer.cornerRadius=12; lb.clipsToBounds=YES;
        [ov addSubview:lb]; [w addSubview:ov];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.35*NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            exit(0);
        });
    });
}
@end
