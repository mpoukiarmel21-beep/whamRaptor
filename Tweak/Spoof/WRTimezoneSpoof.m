#import "WRTimezoneSpoof.h"
#import "WRContainerStore.h"
#import <objc/runtime.h>
static NSTimeZone*(*orig_local)(id,SEL)=NULL;
static NSTimeZone *wr_local(id s,SEL _c){
    WRContainer *c=WRContainerStore.shared.activeContainer;
    if (c.hasLocation && c.location.timezoneName.length){ NSTimeZone *tz=[NSTimeZone timeZoneWithName:c.location.timezoneName]; if (tz) return tz; }
    return orig_local?orig_local(s,_c):[NSTimeZone systemTimeZone];
}
static NSTimeZone*(*orig_system)(id,SEL)=NULL;
static NSTimeZone *wr_system(id s,SEL _c){
    WRContainer *c=WRContainerStore.shared.activeContainer;
    if (c.hasLocation && c.location.timezoneName.length){ NSTimeZone *tz=[NSTimeZone timeZoneWithName:c.location.timezoneName]; if (tz) return tz; }
    return orig_system?orig_system(s,_c):orig_system?orig_system(s,_c):nil;
}
@implementation WRTimezoneSpoof
+ (void)install {
    Method m1=class_getClassMethod(NSTimeZone.class, @selector(localTimeZone));
    if (m1){ orig_local=(void*)method_getImplementation(m1); method_setImplementation(m1,(IMP)wr_local); }
    Method m2=class_getClassMethod(NSTimeZone.class, @selector(systemTimeZone));
    if (m2){ orig_system=(void*)method_getImplementation(m2); method_setImplementation(m2,(IMP)wr_system); }
    // also defaultTimeZone
    Method m3=class_getClassMethod(NSTimeZone.class, @selector(defaultTimeZone));
    if (m3){ static IMP origDef=NULL; origDef=method_getImplementation(m3); IMP n=imp_implementationWithBlock(^NSTimeZone* (id s){ WRContainer*c=WRContainerStore.shared.activeContainer; if(c.hasLocation&&c.location.timezoneName.length){ NSTimeZone*tz=[NSTimeZone timeZoneWithName:c.location.timezoneName]; if(tz) return tz; } return ((NSTimeZone*(*)(id,SEL))origDef)(s,@selector(defaultTimeZone)); }); method_setImplementation(m3,n); }
}
@end
