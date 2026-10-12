#import "WRLocaleSpoof.h"
#import "WRContainerStore.h"
#import <objc/runtime.h>
static NSArray*(*orig_preferredLanguages)(id,SEL)=NULL;
static NSArray *wr_preferredLanguages(id self, SEL _c){
    WRContainer *c=WRContainerStore.shared.activeContainer;
    if (c.hasLocation && c.location.languageCode.length) return @[c.location.languageCode];
    return orig_preferredLanguages?orig_preferredLanguages(self,_c):@[ @"en" ];
}
static NSLocale*(*orig_currentLocale)(id,SEL)=NULL;
static NSLocale *wr_currentLocale(id self, SEL _c){
    WRContainer *c=WRContainerStore.shared.activeContainer;
    if (c.hasLocation && c.location.localeIdentifier.length) return [[NSLocale alloc] initWithLocaleIdentifier:c.location.localeIdentifier];
    return orig_currentLocale?orig_currentLocale(self,_c):[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
}
@implementation WRLocaleSpoof
+ (void)install {
    Method m1=class_getClassMethod(NSLocale.class, @selector(preferredLanguages));
    if (m1){ orig_preferredLanguages=(void*)method_getImplementation(m1); method_setImplementation(m1, (IMP)wr_preferredLanguages); }
    Method m2=class_getClassMethod(NSLocale.class, @selector(currentLocale));
    if (m2){ orig_currentLocale=(void*)method_getImplementation(m2); method_setImplementation(m2, (IMP)wr_currentLocale); }
    // NSUserDefaults AppleLanguages
    // hook via swizzle objectForKey
    Method m3=class_getInstanceMethod(NSUserDefaults.class, @selector(objectForKey:));
    if (m3){
        static IMP orig=NULL; orig=method_getImplementation(m3);
        IMP newImp=imp_implementationWithBlock(^id(NSUserDefaults *self, NSString *k){
            if ([k isEqualToString:@"AppleLanguages"]) {
                WRContainer *c=WRContainerStore.shared.activeContainer;
                if (c.hasLocation && c.location.languageCode.length) return @[c.location.languageCode];
            }
            if ([k isEqualToString:@"AppleLocale"]) {
                WRContainer *c=WRContainerStore.shared.activeContainer;
                if (c.hasLocation && c.location.localeIdentifier.length) return c.location.localeIdentifier;
            }
            return ((id(*)(id,SEL,id))orig)(self,@selector(objectForKey:),k);
        });
        method_setImplementation(m3, newImp);
    }
}
@end
