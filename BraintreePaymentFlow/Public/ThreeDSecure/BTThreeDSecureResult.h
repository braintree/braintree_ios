#import <Foundation/Foundation.h>
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
 True if the 3D Secure flow was successful
 */
@property (nonatomic, assign) BOOL success DEPRECATED_MSG_ATTRIBUTE("Use the liabilityShiftPossible and liabilityShifted flags instead.");

/**
 Indicates whether the liability for fraud has been shifted away from the merchant
 */
@property (nonatomic, assign) BOOL liabilityShifted;

/**
 Indicates whether the card was eligible for 3D Secure
 */
@property (nonatomic, assign) BOOL liabilityShiftPossible;

/**
 The `BTCardNonce` resulting from the 3D Secure flow
 */
@property (nonatomic, strong) BTCardNonce *tokenizedCard;

/**
 The error message when the 3D Secure flow is unsuccessful
 */
@property (nonatomic, copy) NSString *errorMessage;

/**
 Initialize a BTThreeDSecureResult
 
 @param JSON BTJSON used to initialize the BTThreeDSecureResult
 */
- (instancetype)initWithJSON:(BTJSON *)JSON;

@end
