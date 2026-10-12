#import "WRFloatingButton.h"
#import "WRPanelVC.h"
#import "WRTheme.h"
static UIWindow *gWin=nil;
static UIButton *gBtn=nil;
static NSTimer *gFadeTimer=nil;

@implementation WRFloatingButton
+ (void)install {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.2*NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self ensureWindow];
    });
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidBecomeActiveNotification object:nil queue:NSOperationQueue.mainQueue usingBlock:^(NSNotification*n){ [WRFloatingButton ensureWindow]; }];
}
+ (void)ensureWindow {
    if (gWin) { gWin.hidden=NO; return; }
    UIWindowScene *scene=nil;
    for (UIScene *s in UIApplication.sharedApplication.connectedScenes) if ([s isKindOfClass:UIWindowScene.class]) { scene=(UIWindowScene*)s; break; }
    gWin=[[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
    if (scene) gWin.windowScene=scene;
    gWin.windowLevel=UIWindowLevelAlert+10;
    gWin.backgroundColor=UIColor.clearColor;
    gWin.userInteractionEnabled=YES;
    UIViewController *vc=[UIViewController new]; vc.view.backgroundColor=UIColor.clearColor; vc.view.userInteractionEnabled=NO;
    gWin.rootViewController=vc;
    gWin.hidden=NO;

    gBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    gBtn.frame=CGRectMake(12, 180, 46, 46);
    gBtn.layer.cornerRadius=23; gBtn.clipsToBounds=YES;
    gBtn.backgroundColor=[WRTheme.accent colorWithAlphaComponent:0.92];
    gBtn.layer.shadowColor=UIColor.blackColor.CGColor; gBtn.layer.shadowOpacity=0.28; gBtn.layer.shadowRadius=8; gBtn.layer.shadowOffset=CGSizeMake(0,4);
    gBtn.alpha=0.55;
    [gBtn setTitle:@"◈" forState:UIControlStateNormal];
    gBtn.titleLabel.font=[UIFont boldSystemFontOfSize:20];
    [gBtn addTarget:self action:@selector(tapped) forControlEvents:UIControlEventTouchUpInside];

    UIPanGestureRecognizer *pan=[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panned:)];
    [gBtn addGestureRecognizer:pan];
    UILongPressGestureRecognizer *lp=[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressed:)];
    lp.minimumPressDuration=0.35; [gBtn addGestureRecognizer:lp];

    [vc.view addSubview:gBtn];
    vc.view.userInteractionEnabled=YES;
    gBtn.userInteractionEnabled=YES;
    // fade after idle
    [self scheduleFade];
    // make window hit-test only button area
    // Achieve translucency
    gBtn.layer.borderColor=[UIColor colorWithWhite:1 alpha:0.35].CGColor; gBtn.layer.borderWidth=0.7;
}
+ (void)scheduleFade {
    [gFadeTimer invalidate];
    gFadeTimer=[NSTimer scheduledTimerWithTimeInterval:3.0 repeats:NO block:^(NSTimer*t){
        [UIView animateWithDuration:0.45 animations:^{ gBtn.alpha=0.25; }];
    }];
}
+ (void)panned:(UIPanGestureRecognizer*)pan {
    static CGPoint startCenter;
    if (pan.state==UIGestureRecognizerStateBegan){ startCenter=gBtn.center; gBtn.alpha=0.92; [gFadeTimer invalidate]; }
    else if (pan.state==UIGestureRecognizerStateChanged){
        CGPoint tr=[pan translationInView:gWin.rootViewController.view];
        CGPoint c=CGPointMake(startCenter.x+tr.x, startCenter.y+tr.y);
        CGFloat r=23; c.x=MAX(r, MIN(gWin.bounds.size.width-r, c.x)); c.y=MAX(r+60, MIN(gWin.bounds.size.height-r-60, c.y));
        gBtn.center=c;
    } else if (pan.state==UIGestureRecognizerStateEnded){ [self scheduleFade];
        // snap to left/right
        CGFloat mid=gWin.bounds.size.width/2; CGFloat targetX = gBtn.center.x<mid? 12+23 : gWin.bounds.size.width-12-23;
        [UIView animateWithDuration:0.28 delay:0 usingSpringWithDamping:0.82 initialSpringVelocity:0 options:0 animations:^{ gBtn.center=CGPointMake(targetX, gBtn.center.y);} completion:nil];
    }
}
+ (void)longPressed:(UILongPressGestureRecognizer*)lp { if (lp.state==UIGestureRecognizerStateBegan){ gBtn.alpha=0.92; [gFadeTimer invalidate]; } }
+ (void)tapped {
    gBtn.alpha=0.92; [self scheduleFade];
    UIWindow *key=UIApplication.sharedApplication.keyWindow;
    UIViewController *top=key.rootViewController;
    while (top.presentedViewController) top=top.presentedViewController;
    WRPanelVC *p=[WRPanelVC new];
    UINavigationController *nav=[[UINavigationController alloc] initWithRootViewController:p];
    nav.modalPresentationStyle=UIModalPresentationPageSheet;
    if (@available(iOS 15.0,*)) { UISheetPresentationController *s=nav.sheetPresentationController; s.detents=@[UISheetPresentationControllerDetent.mediumDetent, UISheetPresentationControllerDetent.largeDetent]; s.prefersGrabberVisible=YES; }
    [top presentViewController:nav animated:YES completion:nil];
}
+ (void)show { gWin.hidden=NO; gBtn.alpha=0.55; [self scheduleFade]; }
+ (void)hide { gWin.hidden=YES; }
@end
