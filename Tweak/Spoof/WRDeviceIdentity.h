#import <Foundation/Foundation.h>
#import "WRContainer.h"

@interface WRDeviceIdentityFactory : NSObject
+ (WRDeviceIdentity *)generateIdentity; // chip-aware, iOS 26/27 pool
+ (nullable NSDictionary *)deviceForMachine:(NSString *)machine;
+ (NSArray<NSDictionary*>*)allDevices;
+ (NSString *)randomSerial;
+ (NSString *)randomUUID;
@end
