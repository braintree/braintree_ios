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
 3D Secure version
 */
typedef NS_ENUM(NSInteger, BTThreeDSecureVersion) {
    /// 3DS 1.0
    BTThreeDSecureVersion1,

    /// 3DS 2.0
    BTThreeDSecureVersion2
};

/**
 The account type
 */
typedef NS_ENUM(NSInteger, BTThreeDSecureAccountType) {
    /// Unspecified
    BTThreeDSecureAccountTypeUnspecified,

    /// Credit
    BTThreeDSecureAccountTypeCredit,

    /// Debit
    BTThreeDSecureAccountTypeDebit
};

/**
 The shipping method
 */
typedef NS_ENUM(NSInteger, BTThreeDSecureShippingMethod) {
    /// Unspecified
    BTThreeDSecureShippingMethodUnspecified,

    /// Same Day
    BTThreeDSecureShippingMethodSameDay,

    /// Overnight / Expedited
    BTThreeDSecureShippingMethodExpedited,

    /// Priority
    BTThreeDSecureShippingMethodPriority,

    /// Ground
    BTThreeDSecureShippingMethodGround,

    /// Electronic Delivery
    BTThreeDSecureShippingMethodElectronicDelivery,

    /// Ship to Store
    BTThreeDSecureShippingMethodShipToStore
};

/**
 The card add challenge request
 */
typedef NS_ENUM(NSInteger, BTThreeDSecureCardAddChallenge) {
    /// Unspecified
    BTThreeDSecureCardAddChallengeUnspecified,
    
    /// Requested
    BTThreeDSecureCardAddChallengeRequested,
    
    /// Not Requested
    BTThreeDSecureCardAddChallengeNotRequested
};

/**
 3D Secure requested exemption type
 */
typedef NS_ENUM(NSInteger, BTThreeDSecureRequestedExemptionType) {
    /// Unspecified
    BTThreeDSecureRequestedExemptionTypeUnspecified,

    /// Low value
    BTThreeDSecureRequestedExemptionTypeLowValue,

    /// Secure corporate
    BTThreeDSecureRequestedExemptionTypeSecureCorporate,

    /// Trusted beneficiary
    BTThreeDSecureRequestedExemptionTypeTrustedBeneficiary,

    /// Transaction risk analysis
    BTThreeDSecureRequestedExemptionTypeTransactionRiskAnalysis
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
 Optional. The account type selected by the cardholder

 @note Some cards can be processed using either a credit or debit account and cardholders have the option to choose which account to use.
 */
@property (nonatomic, assign) BTThreeDSecureAccountType accountType;

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
 Optional. The shipping method chosen for the transaction
 */
@property (nonatomic, assign) BTThreeDSecureShippingMethod shippingMethod;

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
 Optional. The exemption type to be requested. If an exemption is requested and the exemption's conditions are satisfied, then it will be applied.
 */
@property (nonatomic, assign) BTThreeDSecureRequestedExemptionType requestedExemptionType;

/**
 :nodoc:
 */
@property (nonatomic) BOOL dataOnlyRequested;

/**
 Optional. An authentication created using this property should only be used for adding a payment method to the merchant's vault and not for creating transactions.
 
 Defaults to BTThreeDSecureAddCardChallengeUnspecified.
 
 If set to BTThreeDSecureAddCardChallengeRequested, the authentication challenge will be requested from the issuer to confirm adding new card to the merchant's vault.
 If set to BTThreeDSecureAddCardChallengeNotRequested the authentication challenge will not be requested from the issuer.
 If set to BTThreeDSecureAddCardChallengeUnspecified, when the amount is 0, the authentication challenge will be requested from the issuer.
 If set to BTThreeDSecureAddCardChallengeUnspecified, when the amount is greater than 0, the authentication challenge will not be requested from the issuer.
 */
@property (nonatomic, assign) BTThreeDSecureCardAddChallenge cardAddChallenge;

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
