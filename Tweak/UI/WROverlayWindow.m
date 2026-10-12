#import "WROverlayWindow.h"

@implementation WROverlayWindow
// Fenêtre 100% passthrough sauf sur le bouton flottant.
// On override hitTest pour ne capter que la zone du bouton (tag 9999).
// Tout le reste passe directement à Instagram.

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    // Toujours YES pour que hitTest soit appelé
    return YES;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *btn = [self viewWithTag:9999];
    if (btn && !btn.hidden && btn.alpha > 0.01) {
        // Convert point from window coords to btn.superview coords
        CGPoint p = [btn.superview convertPoint:point fromView:self];
        if (CGRectContainsPoint(btn.frame, p)) {
            // Laisse le bouton (ou ses subviews) gérer le touch
            UIView *hit = [btn hitTest:[btn convertPoint:point fromView:self] withEvent:event];
            return hit ?: btn;
        }
    }
    return nil; // passthrough — Instagram reçoit tout
}
@end
