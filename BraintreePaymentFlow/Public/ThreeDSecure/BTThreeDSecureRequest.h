#import <Foundation/Foundation.h>
#if __has_include("BraintreeCore.h")
#import "BraintreeCore.h"
#else
#import <BraintreeCore/BraintreeCore.h>
#endif
#import "BTPaymentFlowRequest.h"
#import "BTPaymentFlowDriver.h"
#import "BTThreeDSecurePostalAddress.h"

NS_ASSUME_NONNULL_BEGIN

/**
 Used to initialize a 3D Secure payment flow
 */
@interface BTThreeDSecureRequest : BTPaymentFlowRequest <BTPaymentFlowRequestDelegate>

/**
 A nonce to be verified by ThreeDSecure
 */
@property (nonatomic, copy) NSString *nonce;

/**
 The amount for the transaction
 */
@property (nonatomic, copy) NSDecimalNumber *amount;

/**
 Optional. The billing address used for verification
 @see BTThreeDSecurePostalAddress
 */
@property (nonatomic, nullable, copy) BTThreeDSecurePostalAddress *billingAddress;

/**
 Optional. The mobile phone number used for verification
 @note Only numbers. Remove dashes, parentheses and other characters
 */
@property (nonatomic, nullable, copy) NSString *mobilePhoneNumber;

/**
 Optional. The email used for verification
 */
@property (nonatomic, nullable, copy) NSString *email;

/**
 Optional. The 2-digit string indicating the shipping method chosen for the transaction
 Possible Values:
 01 Same Day
 02 Overnight / Expedited
 03 Priority (2-3 Days)
 04 Ground
 05 Electronic Delivery
 06 Ship to Store
 */
@property (nonatomic, nullable, copy) NSString *shippingMethod;

@end

NS_ASSUME_NONNULL_END
