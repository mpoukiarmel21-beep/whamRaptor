#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "Core/WRPaths.h"
#import "Core/WRContainerStore.h"
#import "Core/WRHomeRedirect.h"
#import "Spoof/WRDeviceIdentity.h"
#import "Spoof/WRDeviceSpoof.h"
#import "Spoof/WRLocaleSpoof.h"
#import "Spoof/WRTimezoneSpoof.h"
#import "Spoof/WRLocationSpoof.h"
#import "Spoof/WRHardening.h"
#import "Spoof/WRKeychainHook.h"
#import "Spoof/WRPrefsHook.h"
#import "Spoof/WRAppGroupHook.h"
#import "Spoof/WRPasteboardHook.h"
#import "UI/WRFloatingButton.h"
#import "UI/WRL10n.h"
#import "Util/WRLaunchGuard.h"
#import "Util/WRDiagnostics.h"

__attribute__((constructor))
static void WRBootstrap(void){
    @autoreleasepool {
        [WRPaths ensureBaseDirs];
        [WRLaunchGuard check];
        BOOL safe=[WRLaunchGuard isSafeMode];

        if (!safe){
            // Critical: HOME redirect before anything reads prefs/keychain
            [WRHomeRedirect install];
            [WRDeviceSpoof install];
            [WRLocaleSpoof install];
            [WRTimezoneSpoof install];
            [WRLocationSpoof install];
            [WRHardening install];
            [WRKeychainHook install];
            [WRPrefsHook install];
            [WRAppGroupHook install];
            [WRPasteboardHook install];
        } else {
            [WRDiagnostics log:@"SAFE MODE — hooks désactivés, containers conservés"];
        }

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.8*NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (safe){
                UIWindow *w=UIApplication.sharedApplication.keyWindow;
                if (!w) w=UIApplication.sharedApplication.windows.firstObject;
                if (w){
                    UIAlertController *a=[UIAlertController alertControllerWithTitle:[WRL10n t:@"safeTitle"] message:[WRL10n t:@"safeMsg"] preferredStyle:UIAlertControllerStyleAlert];
                    [a addAction:[UIAlertAction actionWithTitle:[WRL10n t:@"enable"] style:UIAlertActionStyleDefault handler:^(UIAlertAction*_){ [WRLaunchGuard enableAgain]; }]];
                    [a addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil]];
                    UIViewController *top=w.rootViewController; while(top.presentedViewController) top=top.presentedViewController;
                    [top presentViewController:a animated:YES completion:nil];
                }
            } else {
                [WRFloatingButton install];
                // mark success after UI appears
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4*NSEC_PER_SEC)), dispatch_get_main_queue(), ^{ [WRLaunchGuard markLaunchSuccess]; });
            }
            WRContainer *ac=WRContainerStore.shared.activeContainer;
            [WRDiagnostics log:[NSString stringWithFormat:@"launch %@ safe=%d containers=%lu active=%@", NSBundle.mainBundle.infoDictionary[@"CFBundleShortVersionString"], safe, (unsigned long)WRContainerStore.shared.allContainers.count, ac?ac.name:@"—"]];
        });
    }
}
