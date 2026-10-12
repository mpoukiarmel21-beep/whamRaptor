#import "WRTheme.h"
@implementation WRTheme
+ (UIColor*)bg { return [UIColor colorWithRed:0.06 green:0.06 blue:0.08 alpha:1]; }
+ (UIColor*)card { return [UIColor colorWithWhite:0.13 alpha:1]; }
+ (UIColor*)accent { return [UIColor colorWithRed:0.55 green:0.36 blue:1 alpha:1]; }
+ (UIColor*)text { return UIColor.whiteColor; }
+ (UIColor*)subtext { return [UIColor colorWithWhite:0.7 alpha:1]; }
+ (UIColor*)border { return [UIColor colorWithWhite:0.22 alpha:1]; }
+ (UIFont*)titleFont { return [UIFont boldSystemFontOfSize:17]; }
+ (UIFont*)bodyFont { return [UIFont systemFontOfSize:14]; }
+ (UIFont*)smallFont { return [UIFont systemFontOfSize:11]; }
@end
