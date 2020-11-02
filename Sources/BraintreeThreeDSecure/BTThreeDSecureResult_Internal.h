#if __has_include(<Braintree/BraintreeThreeDSecure.h>)
#import <Braintree/BTThreeDSecureResult.h>
#else
#import <BraintreeThreeDSecure/BTThreeDSecureResult.h>
#endif

@class BTJSON;

NS_ASSUME_NONNULL_BEGIN

@interface BTThreeDSecureResult ()

@property (nonatomic, nullable, strong, readwrite) BTCardNonce *tokenizedCard;

- (instancetype)initWithJSON:(BTJSON *)JSON;

@end

NS_ASSUME_NONNULL_END
