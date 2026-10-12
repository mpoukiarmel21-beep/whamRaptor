#import "WRTheme.h"
@implementation WRTheme
+ (UIColor*)bg { return [UIColor colorWithRed:0.043 green:0.043 blue:0.063 alpha:1]; } // #0B0B10
+ (UIColor*)bg2 { return [UIColor colorWithRed:0.067 green:0.067 blue:0.094 alpha:1]; } // #111118
+ (UIColor*)card { return [UIColor colorWithRed:0.102 green:0.102 blue:0.141 alpha:1]; } // #1A1A24
+ (UIColor*)cardSel { return [[self accent] colorWithAlphaComponent:0.14]; }
+ (UIColor*)accent { return [UIColor colorWithRed:0.486 green:0.229 blue:0.929 alpha:1]; } // #7C3AED
+ (UIColor*)accent2 { return [UIColor colorWithRed:0.659 green:0.333 blue:0.969 alpha:1]; } // #A855F7
+ (UIColor*)text { return UIColor.whiteColor; }
+ (UIColor*)subtext { return [UIColor colorWithRed:0.722 green:0.722 blue:0.784 alpha:1]; } // #B8B8C8 readable
+ (UIColor*)muted { return [UIColor colorWithRed:0.478 green:0.478 blue:0.545 alpha:1]; }
+ (UIColor*)border { return [UIColor colorWithRed:0.165 green:0.165 blue:0.212 alpha:1]; } // #2A2A36
+ (UIColor*)success { return [UIColor colorWithRed:0.063 green:0.725 blue:0.506 alpha:1]; }
+ (UIColor*)danger { return [UIColor colorWithRed:0.937 green:0.267 blue:0.267 alpha:1]; }
+ (UIFont*)titleFont { return [UIFont systemFontOfSize:18 weight:UIFontWeightSemibold]; }
+ (UIFont*)title2Font { return [UIFont systemFontOfSize:15 weight:UIFontWeightSemibold]; }
+ (UIFont*)bodyFont { return [UIFont systemFontOfSize:14 weight:UIFontWeightRegular]; }
+ (UIFont*)bodyBoldFont { return [UIFont systemFontOfSize:14 weight:UIFontWeightSemibold]; }
+ (UIFont*)smallFont { return [UIFont systemFontOfSize:12 weight:UIFontWeightRegular]; }
+ (UIFont*)captionFont { return [UIFont systemFontOfSize:11 weight:UIFontWeightMedium]; }
+ (CAGradientLayer*)accentGradientForFrame:(CGRect)f {
    CAGradientLayer *g=[CAGradientLayer layer]; g.frame=f; g.colors=@[(id)self.accent.CGColor,(id)self.accent2.CGColor]; g.startPoint=CGPointMake(0,0.5); g.endPoint=CGPointMake(1,0.5); g.cornerRadius=12; return g;
}
+ (UIVisualEffectView*)blurCard {
    UIVisualEffect *e=[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    UIVisualEffectView *v=[[UIVisualEffectView alloc] initWithEffect:e];
    v.layer.cornerRadius=16; v.clipsToBounds=YES; v.layer.borderColor=self.border.CGColor; v.layer.borderWidth=1;
    return v;
}
@end
