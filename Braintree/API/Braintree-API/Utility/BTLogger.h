@import Foundation;

typedef NS_ENUM(NSUInteger, BTLoggerLevel) {
    BTLoggerLevelNone     = 0,
    BTLoggerLevelCritical = 1,
    BTLoggerLevelError    = 2,
    BTLoggerLevelWarning  = 3,
    BTLoggerLevelInfo     = 4,
    BTLoggerLevelDebug    = 5
};

@interface BTLogger : NSObject

+ (instancetype)sharedLogger;

- (void)log:(NSString *)format, ...;
- (void)critical:(NSString *)format, ...;
- (void)error:(NSString *)format, ...;
- (void)warning:(NSString *)format, ...;
- (void)info:(NSString *)format, ...;
- (void)debug:(NSString *)format, ...;

@property (nonatomic, assign) BTLoggerLevel level;
@property (nonatomic, copy) void (^logBlock)(NSString *);

@end
