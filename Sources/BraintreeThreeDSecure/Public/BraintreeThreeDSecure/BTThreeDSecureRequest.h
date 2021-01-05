#if __has_include(<Braintree/BraintreeThreeDSecure.h>)
#import <Braintree/BTPaymentFlowRequest.h>
#import <Braintree/BTPaymentFlowDriver.h>
#import <Braintree/BTThreeDSecureV2UICustomization.h>
#else
#import <BraintreePaymentFlow/BTPaymentFlowRequest.h>
#import <BraintreePaymentFlow/BTPaymentFlowDriver.h>
#import <BraintreeThreeDSecure/BTThreeDSecureV2UICustomization.h>
#endif

@class BTThreeDSecureRequest;
@class BTThreeDSecureLookup;
@class BTThreeDSecureResult;
@class BTThreeDSecurePostalAddress;
@class BTThreeDSecureAdditionalInformation;
@class BTThreeDSecureV1UICustomization;
@class UiCustomization;
@protocol BTThreeDSecureRequestDelegate;

NS_ASSUME_NONNULL_BEGIN

/**
 Error codes that describe errors that occur during 3D Secure.
 */
typedef NS_ENUM(NSInteger, BTThreeDSecureVersion){
    /// 3DS 1.0
    BTThreeDSecureVersion1,

    /// 3DS 2.0
    BTThreeDSecureVersion2
};

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

/**
 Optional. The additional information used for verification
 @see BTThreeDSecureAdditionalInformation
 */
@property (nonatomic, nullable, strong) BTThreeDSecureAdditionalInformation *additionalInformation;

/**
 Optional. Set to BTThreeDSecureVersion2 if ThreeDSecure V2 flows are desired, when possible. Defaults to BTThreeDSecureVersion2
 */
@property (nonatomic, assign) BTThreeDSecureVersion versionRequested;

/**
 Optional. If set to true, an authentication challenge will be forced if possible.
 */
@property (nonatomic) BOOL challengeRequested;

/**
 Optional. If set to true, an exemption to the authentication challenge will be requested.
 */
@property (nonatomic) BOOL exemptionRequested;

/**
 Optional. UI Customization for 3DS2 challenge views.
 */
@property (nonatomic, nullable, strong) BTThreeDSecureV2UICustomization *v2UICustomization;

/**
 Optional. UI Customization for 3DS1 challenge views.
 */
@property (nonatomic, nullable, strong) BTThreeDSecureV1UICustomization *v1UICustomization;

/**
 A delegate for receiving information about the ThreeDSecure payment flow.
 */
@property (nonatomic, nullable, weak) id<BTThreeDSecureRequestDelegate> threeDSecureRequestDelegate;

@end

/**
 Protocol for ThreeDSecure Request flow
 */
@protocol BTThreeDSecureRequestDelegate

@required

/**
 Required delegate method which returns the ThreeDSecure lookup result before the flow continues.
 Use this to do any UI preparation or custom lookup result handling. Use the `next()` callback to continue the flow.
 */
- (void)onLookupComplete:(BTThreeDSecureRequest *)request lookupResult:(BTThreeDSecureResult *)result next:(void(^)(void))next;

@end

NS_ASSUME_NONNULL_END
