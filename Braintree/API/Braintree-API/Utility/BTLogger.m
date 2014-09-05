#import "BTLogger.h"

#define variadicLogLevel(level) \
    va_list args; \
    va_start(args, format); \
    [self logLevel:level format:format arguments:args]; \
    va_end(args);


@implementation BTLogger

+ (instancetype)sharedLogger {
    static BTLogger *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [self new];
    });

    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _level = BTLoggerLevelInfo;
    }
    return self;
}

- (void)log:(NSString *)format, ... {
    variadicLogLevel(BTLoggerLevelInfo)
}

- (void)critical:(NSString *)format, ... {
    variadicLogLevel(BTLoggerLevelCritical)
}

- (void)error:(NSString *)format, ... {
    variadicLogLevel(BTLoggerLevelError)
}

- (void)warning:(NSString *)format, ... {
    variadicLogLevel(BTLoggerLevelWarning)
}

- (void)info:(NSString *)format, ... {
    variadicLogLevel(BTLoggerLevelInfo)
}

- (void)debug:(NSString *)format, ... {
    variadicLogLevel(BTLoggerLevelDebug)
}

- (void)logLevel:(BTLoggerLevel)level format:(NSString *)format arguments:(va_list)arguments {
    if (level <= self.level) {
        if (self.logBlock) {
            NSString *message = [[NSString alloc] initWithFormat:format arguments:arguments];
            self.logBlock(message);
        } else {
            NSLogv(format, arguments);
        }
    }
}

@end
