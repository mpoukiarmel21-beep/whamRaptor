#import "WRPasteboardHook.h"
#import "WRContainerStore.h"
#import <UIKit/UIKit.h>
#import <objc/runtime.h>
@implementation WRPasteboardHook
+ (void)install {
    // Isolate general pasteboard by namespacing when a container is active
    // Hook +generalPasteboard to return a named board per container
    Method m=class_getClassMethod(UIPasteboard.class, @selector(generalPasteboard));
    if (!m) return;
    IMP orig=method_getImplementation(m);
    IMP n=imp_implementationWithBlock(^UIPasteboard* (id self){
        WRContainer *c=WRContainerStore.shared.activeContainer;
        if (c) {
            NSString *name=[NSString stringWithFormat:@"com.whamraptor.pb.%@", c.containerID];
            UIPasteboard *named=[UIPasteboard pasteboardWithName:name create:YES];
            if (named) return named;
        }
        return ((UIPasteboard*(*)(id,SEL))orig)(self,@selector(generalPasteboard));
    });
    method_setImplementation(m, n);
}
@end
