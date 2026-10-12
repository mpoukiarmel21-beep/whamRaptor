#import <Foundation/Foundation.h>
#import "WRContainer.h"
NS_ASSUME_NONNULL_BEGIN
@interface WRDeviceIdentityFactory : NSObject
+ (WRDeviceIdentity *)generateIdentity;
+ (nullable NSDictionary *)deviceForMachine:(NSString * _Nullable)machine;
+ (NSArray<NSDictionary*>*)allDevices;
+ (NSString *)randomSerial;
+ (NSString *)randomUUID;
@end
NS_ASSUME_NONNULL_END
