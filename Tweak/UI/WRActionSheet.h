#import <UIKit/UIKit.h>
@interface WRActionSheet : NSObject
+ (void)showFrom:(UIViewController*)vc title:(NSString*)title actions:(NSArray<NSDictionary*>*)actions; // @{@"title":,@"style":@"destructive"/@"default"/@"cancel", @"block":^(void)}
@end
