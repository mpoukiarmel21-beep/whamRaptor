#import "WRGlass.h"
@implementation WRGlass
+ (instancetype)glass {
    UIVisualEffect *e=[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    WRGlass *v=[[WRGlass alloc] initWithEffect:e];
    v.layer.cornerRadius=14; v.clipsToBounds=YES; v.layer.borderColor=[UIColor colorWithWhite:1 alpha:0.12].CGColor; v.layer.borderWidth=0.6;
    return v;
}
@end
