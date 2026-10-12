#import "WRFloatingButton.h"
#import "WRPanelVC.h"
#import "WRTheme.h"
#import "WROverlayWindow.h"

static WROverlayWindow *gWin=nil;
static UIButton *gBtn=nil;
static NSTimer *gFadeTimer=nil;

@implementation WRFloatingButton
+ (void)install {
    // Gère aussi pre-iOS 13 (sans scène)
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0*NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self ensureWindow];
    });
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidBecomeActiveNotification object:nil queue:NSOperationQueue.mainQueue usingBlock:^(NSNotification*n){ [WRFloatingButton ensureWindow]; }];
    [[NSNotificationCenter defaultCenter] addObserverForName:UISceneDidActivateNotification object:nil queue:NSOperationQueue.mainQueue usingBlock:^(NSNotification*n){ if (!gWin || gWin.hidden) [WRFloatingButton ensureWindow]; }];
}
+ (UIWindowScene*)activeScene {
    for (UIScene *s in UIApplication.sharedApplication.connectedScenes) {
        if ([s isKindOfClass:UIWindowScene.class] && s.activationState == UISceneActivationStateForegroundActive) return (UIWindowScene*)s;
    }
    for (UIScene *s in UIApplication.sharedApplication.connectedScenes) if ([s isKindOfClass:UIWindowScene.class]) return (UIWindowScene*)s;
    return nil;
}
+ (void)ensureWindow {
    if (gWin && !gWin.hidden) { if (gBtn) gBtn.hidden=NO; return; }
    if (gWin) { gWin.hidden=NO; if (gBtn) gBtn.hidden=NO; return; }

    UIWindowScene *scene=[self activeScene];
    if (@available(iOS 13.0,*)) {
        if (!scene) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.8*NSEC_PER_SEC)), dispatch_get_main_queue(), ^{ [self ensureWindow]; });
            return;
        }
        gWin=[[WROverlayWindow alloc] initWithWindowScene:scene];
        gWin.frame=scene.screen.bounds;
    } else {
        gWin=[[WROverlayWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
    }
    gWin.windowLevel=UIWindowLevelAlert - 1;
    gWin.backgroundColor=UIColor.clearColor;
    gWin.opaque=NO;
    gWin.userInteractionEnabled=YES;
    gWin.rootViewController=[UIViewController new];
    gWin.rootViewController.view.backgroundColor=UIColor.clearColor;
    gWin.rootViewController.view.userInteractionEnabled=NO; // passthrough
    gWin.hidden=NO;
    // Important: makeKeyWindow NO — on reste overlay

    gBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    gBtn.tag = 9999;
    gBtn.frame=CGRectMake(10, 160, 50, 50);
    gBtn.layer.cornerRadius=25; gBtn.clipsToBounds=NO;
    gBtn.userInteractionEnabled=YES;
    CAGradientLayer *grad=[WRTheme accentGradientForFrame:gBtn.bounds];
    grad.cornerRadius=25;
    [gBtn.layer insertSublayer:grad atIndex:0];
    gBtn.layer.shadowColor=[WRTheme.accent colorWithAlphaComponent:0.55].CGColor;
    gBtn.layer.shadowOpacity=0.95; gBtn.layer.shadowRadius=10; gBtn.layer.shadowOffset=CGSizeMake(0,4);
    gBtn.alpha=0.92;
    [gBtn setTitle:@"◈" forState:UIControlStateNormal];
    gBtn.titleLabel.font=[UIFont systemFontOfSize:22 weight:UIFontWeightBold];
    [gBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    gBtn.layer.borderColor=[UIColor colorWithWhite:1 alpha:0.55].CGColor; gBtn.layer.borderWidth=1.2;
    // TouchUpInside ne marche pas si superview a userInteraction NO; on force via addTarget sur window
    [gBtn addTarget:self action:@selector(tapped) forControlEvents:UIControlEventTouchUpInside];

    UIPanGestureRecognizer *pan=[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panned:)];
    pan.cancelsTouchesInView=NO;
    [gBtn addGestureRecognizer:pan];

    // Ajouter directement à la window (pas via rootVC.view qui a userInteraction NO)
    // Mais UROverlayWindow.hitTest passe par view hierarchy, donc on met sur rootView mais on active son touch
    gWin.rootViewController.view.userInteractionEnabled=YES;
    gWin.rootViewController.view.backgroundColor=UIColor.clearColor;
    // La view reste passthrough via hitTest qui ne retourne nil hors bouton
    [gWin.rootViewController.view addSubview:gBtn];
    gBtn.userInteractionEnabled=YES;
    [self scheduleFade];
    NSLog(@"[WhamRaptor] floating button installed at %@", NSStringFromCGRect(gBtn.frame));
}
+ (void)scheduleFade {
    [gFadeTimer invalidate];
    gFadeTimer=[NSTimer scheduledTimerWithTimeInterval:4.0 repeats:NO block:^(NSTimer*t){
        if (gBtn) [UIView animateWithDuration:0.5 animations:^{ gBtn.alpha=0.45; }];
    }];
}
+ (void)panned:(UIPanGestureRecognizer*)pan {
    static CGPoint startCenter;
    if (pan.state==UIGestureRecognizerStateBegan){ startCenter=gBtn.center; gBtn.alpha=1; [gFadeTimer invalidate]; }
    else if (pan.state==UIGestureRecognizerStateChanged){
        CGPoint tr=[pan translationInView:gWin.rootViewController.view];
        CGPoint c=CGPointMake(startCenter.x+tr.x, startCenter.y+tr.y);
        CGFloat r=25; c.x=MAX(r+4, MIN(gWin.bounds.size.width-r-4, c.x)); c.y=MAX(r+60, MIN(gWin.bounds.size.height-r-34, c.y));
        gBtn.center=c;
    } else if (pan.state==UIGestureRecognizerStateEnded || pan.state==UIGestureRecognizerStateCancelled){
        [self scheduleFade];
        CGFloat mid=gWin.bounds.size.width/2; CGFloat targetX = gBtn.center.x<mid? 10+25 : gWin.bounds.size.width-10-25;
        [UIView animateWithDuration:0.3 delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:0 options:0 animations:^{ gBtn.center=CGPointMake(targetX, gBtn.center.y);} completion:nil];
    }
}
+ (void)tapped {
    NSLog(@"[WhamRaptor] tapped");
    if (gBtn) { gBtn.alpha=1; [self scheduleFade]; }
    // Trouver le top ViewController et présenter
    UIWindow *key=nil;
    if (@available(iOS 13.0,*)) {
        for (UIWindow *w in UIApplication.sharedApplication.windows) if (w.isKeyWindow) { key=w; break; }
        if (!key) {
            UIWindowScene *scene=[self activeScene];
            if (scene) for (UIWindow *w in scene.windows) if (w.isKeyWindow) { key=w; break; }
        }
    } else {
        key=UIApplication.sharedApplication.keyWindow;
    }
    if (!key) key=UIApplication.sharedApplication.windows.firstObject;
    UIViewController *top=key.rootViewController;
    if (!top) { NSLog(@"[WhamRaptor] no top VC"); return; }
    // éviter double-present du même panel
    if ([top.presentedViewController isKindOfClass:UINavigationController.class]) {
        UINavigationController *nav=(UINavigationController*)top.presentedViewController;
        if ([nav.viewControllers.firstObject isKindOfClass:NSClassFromString(@"WRPanelVC")]) return;
    }
    while (top.presentedViewController) top=top.presentedViewController;
    WRPanelVC *p=[WRPanelVC new];
    UINavigationController *nav=[[UINavigationController alloc] initWithRootViewController:p];
    nav.modalPresentationStyle=UIModalPresentationPageSheet;
    if (@available(iOS 15.0,*)) {
        UISheetPresentationController *s=nav.sheetPresentationController;
        s.detents=@[UISheetPresentationControllerDetent.mediumDetent, UISheetPresentationControllerDetent.largeDetent];
        s.prefersGrabberVisible=YES; s.prefersScrollingExpandsWhenScrolledToEdge=YES;
    }
    [top presentViewController:nav animated:YES completion:^{ NSLog(@"[WhamRaptor] panel presented"); }];
}
+ (void)show { if (gWin) gWin.hidden=NO; if (gBtn) { gBtn.hidden=NO; gBtn.alpha=0.92; [self scheduleFade]; } }
+ (void)hide { if (gWin) gWin.hidden=YES; }
@end
