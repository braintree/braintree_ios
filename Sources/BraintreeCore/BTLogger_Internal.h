#if __has_include(<Braintree/BraintreeCore.h>)
#import <Braintree/BTLogger.h>
#else
#import <BraintreeCore/BTLogger.h>
#endif

@interface BTLogger ()

- (void)log:(NSString *)format, ...;
- (void)critical:(NSString *)format, ...;
- (void)error:(NSString *)format, ...;
- (void)warning:(NSString *)format, ...;
- (void)info:(NSString *)format, ...;
- (void)debug:(NSString *)format, ...;

/**
 Custom block for handling log messages
*/
@property (nonatomic, copy) void (^logBlock)(BTLogLevel level, NSString *message);

@end
