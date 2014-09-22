@import Foundation;

@interface BTLogger : NSObject

+ (instancetype)sharedLogger;

- (void)log:(NSString *)message;
@end
