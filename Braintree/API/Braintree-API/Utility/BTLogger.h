@import Foundation;

#import "BTLogLevel.h"

@interface BTLogger : NSObject

+ (instancetype)sharedLogger;

- (void)log:(NSString *)format, ...;
- (void)critical:(NSString *)format, ...;
- (void)error:(NSString *)format, ...;
- (void)warning:(NSString *)format, ...;
- (void)info:(NSString *)format, ...;
- (void)debug:(NSString *)format, ...;

@property (nonatomic, assign) BTLogLevel level;

/// Custom block for handling log messages
@property (nonatomic, copy) void (^logBlock)(BTLogLevel, NSString *);

@end
