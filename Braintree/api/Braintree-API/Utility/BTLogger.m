#import "BTLogger.h"

@implementation BTLogger

+ (instancetype)sharedLogger {
    static BTLogger *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [self new];
    });

    return instance;
}

- (void)log:(NSString *)message {
    NSLog(@"%@", message);
}

@end
