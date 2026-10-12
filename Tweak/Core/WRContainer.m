#import "WRContainer.h"

@implementation WRDeviceIdentity
+ (BOOL)supportsSecureCoding { return YES; }
- (void)encodeWithCoder:(NSCoder *)c {
    [c encodeObject:self.model forKey:@"model"];
    [c encodeObject:self.machine forKey:@"machine"];
    [c encodeObject:self.systemVersion forKey:@"systemVersion"];
    [c encodeObject:self.systemName forKey:@"systemName"];
    [c encodeObject:self.deviceName forKey:@"deviceName"];
    [c encodeObject:self.serialNumber forKey:@"serialNumber"];
    [c encodeObject:self.identifierForVendor forKey:@"identifierForVendor"];
    [c encodeObject:self.advertisingIdentifier forKey:@"advertisingIdentifier"];
    [c encodeObject:self.chip forKey:@"chip"];
    [c encodeObject:self.marketingName forKey:@"marketingName"];
}
- (instancetype)initWithCoder:(NSCoder *)c {
    if ((self=[super init])) {
        _model=[c decodeObjectOfClass:NSString.class forKey:@"model"];
        _machine=[c decodeObjectOfClass:NSString.class forKey:@"machine"];
        _systemVersion=[c decodeObjectOfClass:NSString.class forKey:@"systemVersion"];
        _systemName=[c decodeObjectOfClass:NSString.class forKey:@"systemName"];
        _deviceName=[c decodeObjectOfClass:NSString.class forKey:@"deviceName"];
        _serialNumber=[c decodeObjectOfClass:NSString.class forKey:@"serialNumber"];
        _identifierForVendor=[c decodeObjectOfClass:NSString.class forKey:@"identifierForVendor"];
        _advertisingIdentifier=[c decodeObjectOfClass:NSString.class forKey:@"advertisingIdentifier"];
        _chip=[c decodeObjectOfClass:NSString.class forKey:@"chip"];
        _marketingName=[c decodeObjectOfClass:NSString.class forKey:@"marketingName"];
    }
    return self;
}
@end

@implementation WRLocation
+ (BOOL)supportsSecureCoding { return YES; }
- (void)encodeWithCoder:(NSCoder *)c {
    [c encodeObject:self.city forKey:@"city"];
    [c encodeObject:self.country forKey:@"country"];
    [c encodeObject:self.countryCode forKey:@"countryCode"];
    [c encodeObject:self.timezoneName forKey:@"timezoneName"];
    [c encodeObject:self.languageCode forKey:@"languageCode"];
    [c encodeObject:self.localeIdentifier forKey:@"localeIdentifier"];
    [c encodeDouble:self.latitude forKey:@"lat"];
    [c encodeDouble:self.longitude forKey:@"lon"];
    [c encodeDouble:self.altitude forKey:@"alt"];
    [c encodeDouble:self.horizontalAccuracy forKey:@"acc"];
}
- (instancetype)initWithCoder:(NSCoder *)c {
    if ((self=[super init])) {
        _city=[c decodeObjectOfClass:NSString.class forKey:@"city"];
        _country=[c decodeObjectOfClass:NSString.class forKey:@"country"];
        _countryCode=[c decodeObjectOfClass:NSString.class forKey:@"countryCode"];
        _timezoneName=[c decodeObjectOfClass:NSString.class forKey:@"timezoneName"];
        _languageCode=[c decodeObjectOfClass:NSString.class forKey:@"languageCode"];
        _localeIdentifier=[c decodeObjectOfClass:NSString.class forKey:@"localeIdentifier"];
        _latitude=[c decodeDoubleForKey:@"lat"];
        _longitude=[c decodeDoubleForKey:@"lon"];
        _altitude=[c decodeDoubleForKey:@"alt"];
        _horizontalAccuracy=[c decodeDoubleForKey:@"acc"];
        if (_horizontalAccuracy==0) _horizontalAccuracy=15;
    }
    return self;
}
@end

@implementation WRContainer
+ (BOOL)supportsSecureCoding { return YES; }
- (void)encodeWithCoder:(NSCoder *)c {
    [c encodeObject:self.containerID forKey:@"cid"];
    [c encodeObject:self.name forKey:@"name"];
    [c encodeObject:self.colorHex forKey:@"colorHex"];
    [c encodeObject:self.device forKey:@"device"];
    [c encodeObject:self.location forKey:@"location"];
    [c encodeDouble:self.createdAt forKey:@"createdAt"];
    [c encodeBool:self.hasLocation forKey:@"hasLocation"];
}
- (instancetype)initWithCoder:(NSCoder *)c {
    if ((self=[super init])) {
        _containerID=[c decodeObjectOfClass:NSString.class forKey:@"cid"];
        _name=[c decodeObjectOfClass:NSString.class forKey:@"name"];
        _colorHex=[c decodeObjectOfClass:NSString.class forKey:@"colorHex"];
        _device=[c decodeObjectOfClass:WRDeviceIdentity.class forKey:@"device"];
        _location=[c decodeObjectOfClass:WRLocation.class forKey:@"location"];
        _createdAt=[c decodeDoubleForKey:@"createdAt"];
        _hasLocation=[c decodeBoolForKey:@"hasLocation"];
    }
    return self;
}
- (NSString *)displaySubtitle {
    NSMutableArray *parts=[NSMutableArray array];
    if (self.device.marketingName) [parts addObject:self.device.marketingName];
    if (self.device.systemVersion) [parts addObject:[@"iOS " stringByAppendingString:self.device.systemVersion]];
    if (self.hasLocation && self.location.city) [parts addObject:self.location.city];
    return [parts componentsJoinedByString:@" · "];
}
@end
