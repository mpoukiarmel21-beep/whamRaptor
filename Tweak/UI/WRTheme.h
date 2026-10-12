#import <UIKit/UIKit.h>
@interface WRTheme : NSObject
// Premium dark — high contrast, readable on OLED
+ (UIColor*)bg;          // #0B0B10
+ (UIColor*)bg2;         // #111118
+ (UIColor*)card;        // #1A1A24 with border
+ (UIColor*)cardSel;     // accent 12%
+ (UIColor*)accent;      // #7C3AED
+ (UIColor*)accent2;     // #A855F7 gradient
+ (UIColor*)text;        // #FFFFFF
+ (UIColor*)subtext;     // #B8B8C8  (readable, not washed)
+ (UIColor*)muted;       // #7A7A8A
+ (UIColor*)border;      // #2A2A36
+ (UIColor*)success;     // #10B981
+ (UIColor*)danger;      // #EF4444
+ (UIFont*)titleFont;    // 18 semibold
+ (UIFont*)title2Font;   // 15 semibold
+ (UIFont*)bodyFont;     // 14 regular
+ (UIFont*)bodyBoldFont; // 14 semibold
+ (UIFont*)smallFont;    // 12 regular
+ (UIFont*)captionFont;  // 11 medium
+ (CAGradientLayer*)accentGradientForFrame:(CGRect)f;
+ (UIVisualEffectView*)blurCard;
@end
