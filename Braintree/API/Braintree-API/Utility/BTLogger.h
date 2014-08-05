#import <Foundation/Foundation.h>

@interface BTLogger : NSObject

+ (instancetype)sharedLogger;

- (void)log:(NSString *)message;
@end
