#import "WRDeviceSpoof.h"
#import "WRContainerStore.h"
#import "fishhook.h"
#import <UIKit/UIKit.h>
#import <sys/utsname.h>
#import <objc/runtime.h>

static WRContainer *wr_active(void){ return WRContainerStore.shared.activeContainer; }

// UIDevice swizzle helpers
static NSString *(*orig_model)(UIDevice*,SEL)=NULL;
static NSString *wr_model(UIDevice *self, SEL _cmd){
    WRContainer *c=wr_active(); if (c.device.model) return c.device.model; return orig_model?orig_model(self,_cmd):@"iPhone";
}
static NSString *(*orig_name)(UIDevice*,SEL)=NULL;
static NSString *wr_name(UIDevice*self, SEL _c){ WRContainer*c=wr_active(); if (c.device.deviceName) return c.device.deviceName; return orig_name?orig_name(self,_c):@"iPhone"; }
static NSString *(*orig_systemVersion)(UIDevice*,SEL)=NULL;
static NSString *wr_systemVersion(UIDevice*self, SEL _c){ WRContainer*c=wr_active(); if (c.device.systemVersion) return c.device.systemVersion; return orig_systemVersion?orig_systemVersion(self,_c):@"26.0"; }
static NSString *(*orig_systemName)(UIDevice*,SEL)=NULL;
static NSString *wr_systemName(UIDevice*self, SEL _c){ WRContainer*c=wr_active(); if (c.device.systemName) return c.device.systemName; return orig_systemName?orig_systemName(self,_c):@"iOS"; }
static NSUUID *(*orig_idfv)(UIDevice*,SEL)=NULL;
static NSUUID *wr_idfv(UIDevice*self, SEL _c){
    WRContainer*c=wr_active(); if (c.device.identifierForVendor) return [[NSUUID alloc] initWithUUIDString:c.device.identifierForVendor] ?: (orig_idfv?orig_idfv(self,_c):nil); return orig_idfv?orig_idfv(self,_c):nil;
}

// ASIdentifierManager
static NSUUID *(*orig_adId)(id,SEL)=NULL;
static NSUUID *wr_adId(id self, SEL _c){ WRContainer*c=wr_active(); if (c.device.advertisingIdentifier) return [[NSUUID alloc] initWithUUIDString:c.device.advertisingIdentifier] ?: (orig_adId?orig_adId(self,_c):nil); return orig_adId?orig_adId(self,_c):nil; }

// sysctl/uname fishhook
static int (*orig_uname)(struct utsname*)=NULL;
static int wr_uname(struct utsname *u){ int r=orig_uname?orig_uname(u):-1; WRContainer*c=wr_active(); if (c && r==0 && c.device.machine) { strncpy(u->machine, c.device.machine.UTF8String, sizeof(u->machine)-1); if (c.device.systemVersion) strncpy(u->release, c.device.systemVersion.UTF8String, sizeof(u->release)-1); } return r; }
static int (*orig_sysctlbyname)(const char*,void*,size_t*,void*,size_t)=NULL;
static int wr_sysctlbyname(const char *name, void *oldp, size_t *oldlenp, void *newp, size_t newlen){
    WRContainer*c=wr_active();
    if (c && name && strcmp(name,"hw.machine")==0 && oldp && oldlenp) {
        const char *v=c.device.machine.UTF8String; size_t l=strlen(v)+1; if (*oldlenp>=l){ memcpy(oldp,v,l); *oldlenp=l; return 0;} else { *oldlenp=l; return -1; }
    }
    if (c && name && strcmp(name,"hw.model")==0 && oldp && oldlenp) {
        const char *v=c.device.model.UTF8String; size_t l=strlen(v)+1; if (*oldlenp>=l){ memcpy(oldp,v,l); *oldlenp=l; return 0;} else { *oldlenp=l; return -1; }
    }
    return orig_sysctlbyname?orig_sysctlbyname(name,oldp,oldlenp,newp,newlen):-1;
}

static void swizzle(Class cls, SEL sel, IMP newImp, IMP *origOut){
    Method m=class_getInstanceMethod(cls, sel);
    if (!m) return;
    *origOut=method_getImplementation(m);
    method_setImplementation(m, newImp);
}

@implementation WRDeviceSpoof
+ (void)install {
    // UIDevice
    swizzle(UIDevice.class, @selector(model), (IMP)wr_model, (IMP*)&orig_model);
    swizzle(UIDevice.class, @selector(name), (IMP)wr_name, (IMP*)&orig_name);
    swizzle(UIDevice.class, @selector(systemVersion), (IMP)wr_systemVersion, (IMP*)&orig_systemVersion);
    swizzle(UIDevice.class, @selector(systemName), (IMP)wr_systemName, (IMP*)&orig_systemName);
    swizzle(UIDevice.class, @selector(identifierForVendor), (IMP)wr_idfv, (IMP*)&orig_idfv);
    // ASIdentifierManager if present
    Class asCls=NSClassFromString(@"ASIdentifierManager");
    if (asCls) swizzle(asCls, @selector(advertisingIdentifier), (IMP)wr_adId, (IMP*)&orig_adId);
    // fishhook uname/sysctl
    rebind_symbols((struct rebinding[]){
        {"uname", wr_uname, (void**)&orig_uname},
        {"sysctlbyname", wr_sysctlbyname, (void**)&orig_sysctlbyname},
    }, 2);
}
@end
