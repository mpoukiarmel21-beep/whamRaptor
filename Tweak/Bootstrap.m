#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "Core/WRPaths.h"
#import "Core/WRContainerStore.h"
#import "Core/WRHomeRedirect.h"
#import "Spoof/WRFileHook.h"
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

#define WR_SafeInstall(expr) do { @try { expr; } @catch(NSException *e) { NSLog(@"[WhamRaptor] install exception %@: %@", @#expr, e); } } while(0)

__attribute__((constructor))
static void WRBootstrap(void){
    @autoreleasepool {
        @try { [WRPaths ensureBaseDirs]; } @catch(...) {}
        @try { [WRLaunchGuard check]; } @catch(...) {}
        BOOL safe = NO;
        @try { safe = [WRLaunchGuard isSafeMode]; } @catch(...) { safe = NO; }

        if (!safe){
            // Critical isolation before IG reads prefs/keychain/files — must be before UIKit init
            WR_SafeInstall([WRHomeRedirect install]);
            WR_SafeInstall([WRFileHook install]);
            WR_SafeInstall([WRKeychainHook install]);
            // Device/locale/timezone/location can be deferred but better early for first-launch
            WR_SafeInstall([WRDeviceSpoof install]);
            WR_SafeInstall([WRLocaleSpoof install]);
            WR_SafeInstall([WRTimezoneSpoof install]);
            WR_SafeInstall([WRLocationSpoof install]);
            WR_SafeInstall([WRHardening install]);
            // Defer container-group/pasteboard until UIKit ready
            dispatch_async(dispatch_get_main_queue(), ^{
                WR_SafeInstall([WRPrefsHook install]);
                WR_SafeInstall([WRAppGroupHook install]);
                WR_SafeInstall([WRPasteboardHook install]);
                NSLog(@"[WhamRaptor] deferred hooks installed");
            });
        } else {
            NSLog(@"[WhamRaptor] SAFE MODE — hooks disabled");
            @try { [WRDiagnostics log:@"SAFE MODE — hooks désactivés, containers conservés"]; } @catch(...) {}
        }

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.8*NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            @try {
                if (safe){
                    UIWindow *w=UIApplication.sharedApplication.keyWindow;
                    if (!w) w=UIApplication.sharedApplication.windows.firstObject;
                    if (w){
                        UIAlertController *a=[UIAlertController alertControllerWithTitle:[WRL10n t:@"safeTitle"] message:[WRL10n t:@"safeMsg"] preferredStyle:UIAlertControllerStyleAlert];
                        [a addAction:[UIAlertAction actionWithTitle:[WRL10n t:@"enable"] style:UIAlertActionStyleDefault handler:^(UIAlertAction*_){ @try{[WRLaunchGuard enableAgain];} @catch(...){} }]];
                        [a addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil]];
                        UIViewController *top=w.rootViewController; while(top.presentedViewController) top=top.presentedViewController;
                        [top presentViewController:a animated:YES completion:nil];
                    }
                } else {
                    WR_SafeInstall([WRFloatingButton install]);
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4*NSEC_PER_SEC)), dispatch_get_main_queue(), ^{ @try{[WRLaunchGuard markLaunchSuccess];} @catch(...){} });
                }
                @try {
                    WRContainer *ac=WRContainerStore.shared.activeContainer;
                    [WRDiagnostics log:[NSString stringWithFormat:@"launch %@ safe=%d containers=%lu active=%@", NSBundle.mainBundle.infoDictionary[@"CFBundleShortVersionString"]?:@"?", safe, (unsigned long)WRContainerStore.shared.allContainers.count, ac?ac.name:@"—"]];
                } @catch(...) {}
            } @catch(NSException *e) { NSLog(@"[WhamRaptor] bootstrap UI exception: %@", e); }
        });
    }
}
