#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString * const BTCrashReportKey;

/// Notify Braintree when your app encounters an uncaught exception (i.e. crash).
/// This behavior is opt-in, and it does not send any private data about your app,
/// the device, or your users.

@interface BTReporting : NSObject

/// Enables crash reporting.
///
/// This should be called at the end of `application:didFinishLaunchingWithOptions:`.
///
/// @remark It is worthwhile to verify that any other crash reporting you use (e.g. Crashlytics)
/// is still working correctly.
+ (void)enable;

@end

NS_ASSUME_NONNULL_END
