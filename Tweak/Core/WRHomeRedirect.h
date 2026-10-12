#import <Foundation/Foundation.h>
NS_ASSUME_NONNULL_BEGIN
@interface WRHomeRedirect : NSObject
+ (void)install;
+ (nullable NSString *)activeHomePath; // nil = main app
@end
NS_ASSUME_NONNULL_END
