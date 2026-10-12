#import "WRContainerStore.h"
#import "WRPaths.h"
#import "WRDeviceIdentity.h"
#import <Security/Security.h>

@interface WRContainerStore ()
@property (nonatomic, strong) NSMutableArray<WRContainer*>* containers;
@property (nonatomic, copy, nullable) NSString *activeID;
@end

@implementation WRContainerStore
+ (instancetype)shared { static WRContainerStore *s; static dispatch_once_t t; dispatch_once(&t, ^{ s=[WRContainerStore new]; [s reload]; }); return s; }

- (void)reload {
    [WRPaths ensureBaseDirs];
    NSDictionary *d=[NSDictionary dictionaryWithContentsOfFile:WRPaths.storePlistPath];
    NSArray *arr=d[@"containers"];
    NSMutableArray *out=[NSMutableArray array];
    for (NSData *data in arr) {
        if (![data isKindOfClass:NSData.class]) continue;
        NSError *e=nil;
        WRContainer *c=[NSKeyedUnarchiver unarchivedObjectOfClass:WRContainer.class fromData:data error:&e];
        if (c) [out addObject:c];
    }
    self.containers=out;
    NSString *aid=[NSString stringWithContentsOfFile:WRPaths.activeContainerIDPath encoding:NSUTF8StringEncoding error:nil];
    aid=[aid stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
    self.activeID=aid.length?aid:nil;
}

- (void)save {
    [WRPaths ensureBaseDirs];
    NSMutableArray *arr=[NSMutableArray array];
    for (WRContainer *c in self.containers) {
        NSError *e=nil;
        NSData *d=[NSKeyedArchiver archivedDataWithRootObject:c requiringSecureCoding:YES error:&e];
        if (d) [arr addObject:d];
    }
    NSDictionary *d=@{@"containers": arr, @"version": @1};
    [d writeToFile:WRPaths.storePlistPath atomically:YES];
    if (self.activeID) [self.activeID writeToFile:WRPaths.activeContainerIDPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    else [[NSFileManager defaultManager] removeItemAtPath:WRPaths.activeContainerIDPath error:nil];
}

- (NSArray<WRContainer*>*)allContainers { return [self.containers copy]; }
- (WRContainer*)activeContainer { return self.activeID? [self containerForID:self.activeID] : nil; }
- (WRContainer*)containerForID:(NSString*)cid { for (WRContainer*c in self.containers) if ([c.containerID isEqualToString:cid]) return c; return nil; }
- (void)setActiveContainerID:(NSString*)cid {
    self.activeID=cid;
    [self save];
}

- (WRContainer*)createContainerWithName:(NSString*)name {
    WRContainer *c=[WRContainer new];
    c.containerID=[[NSUUID UUID] UUIDString];
    c.name=name.length?name:[NSString stringWithFormat:@"Container %lu",(unsigned long)self.containers.count+1];
    c.colorHex=@[@"#FF3B30",@"#34C759",@"#007AFF",@"#AF52DE",@"#FF9500",@"#5856D6",@"#FF2D55"][self.containers.count%7];
    c.device=[WRDeviceIdentityFactory generateIdentity];
    c.createdAt=NSDate.date.timeIntervalSince1970;
    c.hasLocation=NO;
    [self.containers addObject:c];
    [self save];
    // create dirs
    NSFileManager *fm=NSFileManager.defaultManager;
    for (NSString *p in @[[WRPaths containerDirForID:c.containerID],[WRPaths containerHomeForID:c.containerID],[WRPaths containerLibraryForID:c.containerID],[WRPaths containerTmpForID:c.containerID]]) {
        if (![fm fileExistsAtPath:p]) [fm createDirectoryAtPath:p withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return c;
}
- (void)updateContainer:(WRContainer*)c { [self save]; }

- (void)deleteContainerID:(NSString*)cid {
    WRContainer *c=[self containerForID:cid];
    if (!c) return;
    // if active -> clear
    if ([self.activeID isEqualToString:cid]) self.activeID=nil;
    [self.containers removeObject:c];
    [self save];
    // rm -rf container dir (isolated storage, never touches main app)
    NSString *dir=[WRPaths containerDirForID:cid];
    [[NSFileManager defaultManager] removeItemAtPath:dir error:nil];
    // purge keychain items prefixed by container (service contains cid)
    [self purgeKeychainForContainerID:cid];
    // purge prefs files if any
    NSString *prefsDir=[[WRPaths containerHomeForID:cid] stringByAppendingPathComponent:@"Library/Preferences"];
    [[NSFileManager defaultManager] removeItemAtPath:prefsDir error:nil];
}

- (void)purgeKeychainForContainerID:(NSString*)cid {
    // Best-effort: iterate all generic password items and delete those matching our prefix
    // We tag items with service = com.burbn.instagram.wr.<cid>.* so we can filter
    // For safety, also delete by accessGroup if present
    NSDictionary *q=@{ (__bridge id)kSecClass: (__bridge id)kSecClassGenericPassword, (__bridge id)kSecMatchLimit: (__bridge id)kSecMatchLimitAll, (__bridge id)kSecReturnAttributes: @YES };
    CFTypeRef res=NULL;
    if (SecItemCopyMatching((__bridge CFDictionaryRef)q, &res)==errSecSuccess && res) {
        NSArray *items=(__bridge NSArray*)res;
        for (NSDictionary *it in items) {
            NSString *svc=it[(__bridge id)kSecAttrService];
            if ([svc containsString:cid]) {
                NSDictionary *del=@{ (__bridge id)kSecClass: (__bridge id)kSecClassGenericPassword, (__bridge id)kSecAttrService: svc };
                SecItemDelete((__bridge CFDictionaryRef)del);
            }
        }
        CFRelease(res);
    }
}
@end
