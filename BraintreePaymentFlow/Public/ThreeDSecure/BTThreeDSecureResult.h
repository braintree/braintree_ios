#if __has_include("BraintreeCard.h")
#import "BTCardNonce.h"
#else
#import <BraintreeCard/BTCardNonce.h>
#endif
#import "BTPaymentFlowResult.h"
#import "BTThreeDSecureLookup.h"

NS_ASSUME_NONNULL_BEGIN

/**
 The result of a 3D Secure payment flow
 */
@interface BTThreeDSecureResult : BTPaymentFlowResult

/**
 The `BTCardNonce` resulting from the 3D Secure flow
 */
@property (nonatomic, nullable, readonly, strong) BTCardNonce *tokenizedCard;

@property (nonatomic, nullable, readonly, strong) BTThreeDSecureLookup *lookup;

@property (nonatomic, nullable, readonly, copy) NSString *errorMessage;

@end

NS_ASSUME_NONNULL_END
