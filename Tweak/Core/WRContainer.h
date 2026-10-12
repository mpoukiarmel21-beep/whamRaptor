#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface WRDeviceIdentity : NSObject <NSSecureCoding>
@property (nonatomic, copy) NSString *model;           // e.g. iPhone12,1
@property (nonatomic, copy) NSString *machine;         // hw.machine same
@property (nonatomic, copy) NSString *systemVersion;   // e.g. 26.1
@property (nonatomic, copy) NSString *systemName;      // iPhone OS
@property (nonatomic, copy) NSString *deviceName;      // iPhone
@property (nonatomic, copy) NSString *serialNumber;
@property (nonatomic, copy) NSString *identifierForVendor;
@property (nonatomic, copy) NSString *advertisingIdentifier;
@property (nonatomic, copy) NSString *chip;            // A13, A17 Pro...
@property (nonatomic, copy) NSString *marketingName;   // iPhone 11
@end

@interface WRLocation : NSObject <NSSecureCoding>
@property (nonatomic, copy) NSString *city;
@property (nonatomic, copy) NSString *country;
@property (nonatomic, copy) NSString *countryCode;
@property (nonatomic, copy) NSString *timezoneName; // Europe/Paris
@property (nonatomic, copy) NSString *languageCode; // fr
@property (nonatomic, copy) NSString *localeIdentifier; // fr_FR
@property (nonatomic, assign) double latitude;
@property (nonatomic, assign) double longitude;
@property (nonatomic, assign) double altitude;
@property (nonatomic, assign) double horizontalAccuracy;
@end

@interface WRContainer : NSObject <NSSecureCoding>
@property (nonatomic, copy) NSString *containerID; // uuid
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *colorHex; // UI accent
@property (nonatomic, strong) WRDeviceIdentity *device;
@property (nonatomic, strong, nullable) WRLocation *location;
@property (nonatomic, assign) NSTimeInterval createdAt;
@property (nonatomic, assign) BOOL hasLocation;
- (NSString *)displaySubtitle;
@end

NS_ASSUME_NONNULL_END
