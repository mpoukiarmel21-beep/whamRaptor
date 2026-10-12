#import "WRDiagnostics.h"
#import "WRPaths.h"
@implementation WRDiagnostics
+ (void)log:(NSString*)m{
    NSString *line=[NSString stringWithFormat:@"[%@] %@\n", [NSDateFormatter localizedStringFromDate:NSDate.date dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterMediumStyle], m];
    NSFileHandle *h=[NSFileHandle fileHandleForWritingAtPath:WRPaths.diagnosticsLogPath];
    if (!h){ [line writeToFile:WRPaths.diagnosticsLogPath atomically:YES encoding:NSUTF8StringEncoding error:nil]; }
    else { [h seekToEndOfFile]; [h writeData:[line dataUsingEncoding:NSUTF8StringEncoding]]; [h closeFile]; }
    NSLog(@"[WhamRaptor] %@", m);
}
+ (NSString*)dump{
    NSString *s=[NSString stringWithContentsOfFile:WRPaths.diagnosticsLogPath encoding:NSUTF8StringEncoding error:nil];
    return s?:@"(vide)";
}
@end
