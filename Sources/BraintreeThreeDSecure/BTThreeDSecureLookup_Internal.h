#if __has_include(<Braintree/BraintreeThreeDSecure.h>)
#import <Braintree/BTThreeDSecureLookup.h>
#else
#import <BraintreeThreeDSecure/BTThreeDSecureLookup.h>
#endif

@class BTJSON;

NS_ASSUME_NONNULL_BEGIN

@interface BTThreeDSecureLookup ()

- (instancetype)initWithJSON:(BTJSON *)JSON;

@end

NS_ASSUME_NONNULL_END
