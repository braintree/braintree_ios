#if __has_include(<Braintree/BraintreeCore.h>)
#import <Braintree/BTPreferredPaymentMethodsResult.h>
#else
#import <BraintreeCore/BTPreferredPaymentMethodsResult.h>
#endif

@class BTAPIClient;

NS_ASSUME_NONNULL_BEGIN

/**
 :nodoc:
 Fetches information about which payment methods are preferred on the device.
 Used to determine which payment methods are given preference in your UI,
 not whether they are presented entirely.

 This class is currently in beta and may change in future releases.
*/
@interface BTPreferredPaymentMethods : NSObject

/**
 :nodoc:
 Creates an instance of BTPreferredPaymentMethods.

 @param apiClient An API client
*/
- (instancetype)initWithAPIClient:(BTAPIClient *)apiClient NS_DESIGNATED_INITIALIZER NS_EXTENSION_UNAVAILABLE("Uses APIs (i.e UIApplication.sharedApplication) not available for use in App Extensions.");

/**
 :nodoc:
 Base initializer - do not use.
*/
- (instancetype)init __attribute__((unavailable("Please use initWithAPIClient:")));

/**
 :nodoc:
 Fetches information about which payment methods are preferred on the device.

 @param completion A completion block that is invoked when preferred payment methods are available.
*/
- (void)fetchPreferredPaymentMethods:(void (^)(BTPreferredPaymentMethodsResult *))completion;

@end

NS_ASSUME_NONNULL_END
