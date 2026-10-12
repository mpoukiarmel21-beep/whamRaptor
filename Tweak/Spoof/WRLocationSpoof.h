#import <Foundation/Foundation.h>
@interface WRLocationSpoof : NSObject
+ (void)install;
+ (BOOL)isActive; // hasLocation
@end
