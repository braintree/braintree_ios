#if __has_include(<Braintree/BraintreeThreeDSecure.h>)
#import <Braintree/BTPaymentFlowResult.h>
#else
#import <BraintreePaymentFlow/BTPaymentFlowResult.h>
#endif

@class BTCardNonce;
@class BTThreeDSecureLookup;

NS_ASSUME_NONNULL_BEGIN

/**
 The result of a 3D Secure payment flow
 */
@interface BTThreeDSecureResult : BTPaymentFlowResult

/**
 The `BTCardNonce` resulting from the 3D Secure flow
 */
@property (nonatomic, nullable, readonly, strong) BTCardNonce *tokenizedCard;

/**
 The result of a 3D Secure lookup. Contains liability shift and challenge information.
 */
@property (nonatomic, nullable, readonly, strong) BTThreeDSecureLookup *lookup;

/**
 The error message when the 3D Secure flow is unsuccessful
 */
@property (nonatomic, nullable, readonly, copy) NSString *errorMessage;

@end

NS_ASSUME_NONNULL_END
