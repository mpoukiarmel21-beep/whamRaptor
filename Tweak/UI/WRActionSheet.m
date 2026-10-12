#import "WRActionSheet.h"
@implementation WRActionSheet
+ (void)showFrom:(UIViewController*)vc title:(NSString*)t actions:(NSArray<NSDictionary*>*)acts {
    UIAlertController *a=[UIAlertController alertControllerWithTitle:t message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    for (NSDictionary *d in acts){
        NSString *title=d[@"title"]; NSString *style=d[@"style"]; void(^blk)(void)=d[@"block"];
        UIAlertActionStyle st=UIAlertActionStyleDefault;
        if ([style isEqualToString:@"destructive"]) st=UIAlertActionStyleDestructive;
        if ([style isEqualToString:@"cancel"]) st=UIAlertActionStyleCancel;
        [a addAction:[UIAlertAction actionWithTitle:title style:st handler:^(UIAlertAction*_){ if(blk) blk(); }]];
    }
    a.popoverPresentationController.sourceView=vc.view;
    a.popoverPresentationController.sourceRect=CGRectMake(vc.view.bounds.size.width/2, vc.view.bounds.size.height-40, 1, 1);
    [vc presentViewController:a animated:YES completion:nil];
}
@end
