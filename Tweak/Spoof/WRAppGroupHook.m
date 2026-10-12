#import "WRAppGroupHook.h"
#import "WRContainerStore.h"
#import "WRPaths.h"
#import <objc/runtime.h>
@implementation WRAppGroupHook
+ (void)install {
    Class cls=NSFileManager.class;
    Method m=class_getInstanceMethod(cls, @selector(containerURLForSecurityApplicationGroupIdentifier:));
    if (!m) return;
    IMP orig=method_getImplementation(m);
    IMP n=imp_implementationWithBlock(^NSURL* (NSFileManager*self, NSString*gid){
        WRContainer *c=WRContainerStore.shared.activeContainer;
        NSURL *origURL=((NSURL*(*)(id,SEL,NSString*))orig)(self,@selector(containerURLForSecurityApplicationGroupIdentifier:),gid);
        if (!c || !origURL) return origURL;
        NSString *base=[WRPaths containerHomeForID:c.containerID];
        NSString *scoped=[base stringByAppendingPathComponent:[NSString stringWithFormat:@"Library/GroupContainers/%@", gid]];
        [[NSFileManager defaultManager] createDirectoryAtPath:scoped withIntermediateDirectories:YES attributes:nil error:nil];
        return [NSURL fileURLWithPath:scoped];
    });
    method_setImplementation(m, n);
}
@end
