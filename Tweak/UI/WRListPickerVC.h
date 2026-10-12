#import <UIKit/UIKit.h>
#import "WRContainer.h"
@interface WRListPickerVC : UIViewController
@property (nonatomic, copy) void(^onPick)(WRLocation*);
@end
