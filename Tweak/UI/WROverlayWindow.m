#import "WROverlayWindow.h"
@implementation WROverlayWindow
// Window that only eats touches on the floating button, passes everything else through
- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    // Only capture touches inside the floating button's frame
    UIView *btn = nil;
    for (UIView *v in self.subviews) {
        for (UIView *sv in v.subviews) if (sv.tag == 9999) btn = sv;
    }
    if (btn) {
        CGPoint p = [self convertPoint:point toView:btn.superview];
        if (CGRectContainsPoint(btn.frame, p)) return YES;
    }
    return NO;
}
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *hit = [super hitTest:point withEvent:event];
    if (hit == self) return nil; // window background is passthrough
    return hit;
}
@end
