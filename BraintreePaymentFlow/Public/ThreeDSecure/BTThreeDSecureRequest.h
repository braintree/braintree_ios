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
 @brief Used to initialize a 3D Secure payment flow
 */
@interface BTThreeDSecureRequest : BTPaymentFlowRequest <BTPaymentFlowRequestDelegate>

/**
 @brief The nonce to be verified by ThreeDSecure
 */
@property (nonatomic, copy) NSString *nonce;

/**
 @brief The amount for the transaction
 */
@property (nonatomic, copy) NSDecimalNumber *amount;

/**
 @brief Optional. The billing address used for verification
 @see BTThreeDSecurePostalAddress
 */
@property (nonatomic, copy) BTThreeDSecurePostalAddress *billingAddress;

/**
 @brief Optional. The mobile phone number used for verification
 @note Only numbers. Remove dashes, parentheses and other characters
 */
@property (nonatomic, copy) NSString *mobilePhoneNumber;

/**
 @brief Optional. The email used for verification
 */
@property (nonatomic, copy) NSString *email;

/**
 @brief Optional. The 2-digit string indicating the shipping method chosen for the transaction
 @discussion Possible Values:
 01 Same Day
 02 Overnight / Expedited
 03 Priority (2-3 Days)
 04 Ground
 05 Electronic Delivery
 06 Ship to Store
 */
@property (nonatomic, copy) NSString *shippingMethod;

@end

NS_ASSUME_NONNULL_END
