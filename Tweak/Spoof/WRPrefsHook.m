#import "WRPrefsHook.h"
#import "WRContainerStore.h"
#import "WRPaths.h"
#import <objc/runtime.h>

// Isolate NSUserDefaults suite com.burbn.instagram per container via file redirection
// Simplest: hook -[NSUserDefaults objectForKey:] etc not needed if HOME redirect covers Library/Preferences
// But also intercept suiteName init to use container path

@implementation WRPrefsHook
+ (void)install {
    // Hook NSUserDefaults initWithSuiteName: to redirect to container if active
    Method m=class_getInstanceMethod(NSUserDefaults.class, @selector(initWithSuiteName:));
    if (!m) return;
    IMP orig=method_getImplementation(m);
    IMP n=imp_implementationWithBlock(^NSUserDefaults* (NSUserDefaults *self, NSString *suite){
        WRContainer *c=WRContainerStore.shared.activeContainer;
        if (c && suite && [suite containsString:@"group.com.burbn.instagram"]) {
            NSString *scoped=[NSString stringWithFormat:@"%@.wr.%@", suite, c.containerID];
            return ((NSUserDefaults*(*)(id,SEL,NSString*))orig)(self,@selector(initWithSuiteName:),scoped);
        }
        return ((NSUserDefaults*(*)(id,SEL,NSString*))orig)(self,@selector(initWithSuiteName:),suite);
    });
    method_setImplementation(m, n);
}
@end
