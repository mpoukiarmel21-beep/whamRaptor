#import "WRLocationSpoof.h"
#import "WRContainerStore.h"
#import <CoreLocation/CoreLocation.h>
#import <objc/runtime.h>

// Fix anti-spinner: garde gInDelivery + delivery synchrone main + fallback didFailWithError
// + isActive = hasLocation sinon pass-through natif
// + hooks minimaux: location / startUpdatingLocation / requestLocation uniquement

static BOOL gInDelivery=NO;

@implementation WRLocationSpoof

+ (BOOL)isActive {
    WRContainer *c=WRContainerStore.shared.activeContainer;
    return c.hasLocation && c.location!=nil;
}

+ (CLLocation*)fakeLocation {
    WRContainer *c=WRContainerStore.shared.activeContainer;
    if (!c.hasLocation || !c.location) return nil;
    CLLocationCoordinate2D coord=CLLocationCoordinate2DMake(c.location.latitude, c.location.longitude);
    CLLocation *loc=[[CLLocation alloc] initWithCoordinate:coord altitude:c.location.altitude horizontalAccuracy:c.location.horizontalAccuracy verticalAccuracy:10 timestamp:NSDate.date];
    return loc;
}

+ (void)deliverTo:(CLLocationManager*)mgr {
    if (gInDelivery) return;
    CLLocation *loc=self.fakeLocation; if (!loc) return;
    id<CLLocationManagerDelegate> del=mgr.delegate;
    BOOL canUpdate = del && [del respondsToSelector:@selector(locationManager:didUpdateLocations:)];
    BOOL canFail = del && [del respondsToSelector:@selector(locationManager:didFailWithError:)];
    void (^doDeliver)(void)=^{
        gInDelivery=YES;
        @try {
            if (canUpdate) [del locationManager:mgr didUpdateLocations:@[loc]];
            else if (canFail) [del locationManager:mgr didFailWithError:[NSError errorWithDomain:kCLErrorDomain code:kCLErrorDenied userInfo:nil]];
        } @finally { gInDelivery=NO; }
    };
    if (NSThread.isMainThread) doDeliver();
    else dispatch_sync(dispatch_get_main_queue(), doDeliver);
}

+ (void)install {
    Class cls=NSClassFromString(@"CLLocationManager");
    if (!cls) return;

    // location property getter
    Method mLoc=class_getInstanceMethod(cls, @selector(location));
    if (mLoc){
        IMP orig=method_getImplementation(mLoc);
        IMP n=imp_implementationWithBlock(^CLLocation* (CLLocationManager*self){
            if (WRLocationSpoof.isActive) { CLLocation *f=WRLocationSpoof.fakeLocation; if (f) return f; }
            return ((CLLocation*(*)(id,SEL))orig)(self,@selector(location));
        });
        method_setImplementation(mLoc, n);
    }
    // startUpdatingLocation
    Method mStart=class_getInstanceMethod(cls, @selector(startUpdatingLocation));
    if (mStart){
        IMP orig=method_getImplementation(mStart);
        IMP n=imp_implementationWithBlock(^(CLLocationManager*self){
            if (WRLocationSpoof.isActive) { [WRLocationSpoof deliverTo:self]; return; }
            ((void(*)(id,SEL))orig)(self,@selector(startUpdatingLocation));
        });
        method_setImplementation(mStart, n);
    }
    // requestLocation
    Method mReq=class_getInstanceMethod(cls, @selector(requestLocation));
    if (mReq){
        IMP orig=method_getImplementation(mReq);
        IMP n=imp_implementationWithBlock(^(CLLocationManager*self){
            if (WRLocationSpoof.isActive) { [WRLocationSpoof deliverTo:self]; return; }
            ((void(*)(id,SEL))orig)(self,@selector(requestLocation));
        });
        method_setImplementation(mReq, n);
    }
    // Do NOT hook requestLocationWithCompletionHandler: (source deadlock spinner)
}

@end
