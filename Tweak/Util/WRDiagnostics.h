#import <Foundation/Foundation.h>
@interface WRDiagnostics : NSObject
+ (void)log:(NSString*)msg;
+ (NSString*)dump;
@end
