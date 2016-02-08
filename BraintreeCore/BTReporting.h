#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString * const BTCrashReportKey;

@interface BTReporting : NSObject

/// The BTReporting singleton used by the Braintree SDK
+ (instancetype)sharedInstance;

@end

NS_ASSUME_NONNULL_END
