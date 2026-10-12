#import <UIKit/UIKit.h>
#import "WRContainer.h"
@interface WRWorldCities : NSObject
+ (NSArray<NSDictionary*>*)allCities;
+ (nullable NSDictionary*)cityForName:(NSString*)name;
@end

@interface WRMapPickerVC : UIViewController
@property (nonatomic, copy) void(^onPick)(WRLocation*);
@end
