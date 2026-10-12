#import <Foundation/Foundation.h>
#import "WRContainer.h"
NS_ASSUME_NONNULL_BEGIN
@interface WRContainerStore : NSObject
+ (instancetype)shared;
- (NSArray<WRContainer *> *)allContainers;
- (nullable WRContainer *)activeContainer;
- (nullable WRContainer *)containerForID:(NSString *)cid;
- (void)setActiveContainerID:(nullable NSString *)cid;
- (WRContainer *)createContainerWithName:(NSString *)name; // auto device identity
- (void)updateContainer:(WRContainer *)c;
- (void)deleteContainerID:(NSString *)cid; // rm -rf + keychain purge + prefs
- (void)reload;
- (void)save;
@end
NS_ASSUME_NONNULL_END
