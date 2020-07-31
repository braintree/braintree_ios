#if __has_include("BraintreeCore.h")
#import "BraintreeCore.h"
#else
#import <BraintreeCore/BraintreeCore.h>
#endif
#if __has_include("BraintreeCard.h")
#import "BTCardNonce.h"
#else
#import <BraintreeCard/BTCardNonce.h>
#endif
#import "BTPaymentFlowResult.h"

/**
 The result of a 3D Secure payment flow
 */
@interface BTThreeDSecureResult : BTPaymentFlowResult

/**
 The `BTCardNonce` resulting from the 3D Secure flow
 */
@property (nonatomic, strong) BTCardNonce *tokenizedCard;

/**
 Initialize a BTThreeDSecureResult
 
 @param JSON BTJSON used to initialize the BTThreeDSecureResult
 */
- (instancetype)initWithJSON:(BTJSON *)JSON;

@end
