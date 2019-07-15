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
#import "BTThreeDSecureResult.h"

/**
 The result of a 3DS lookup.

 Contains laibility shift and challenge information as well as a nonce.
 */
@interface BTThreeDSecureLookup : BTPaymentFlowResult

/**
 Do not change. The "PAReq" or "Payment Authentication Request" is the encoded request message used to initiate authentication.
 */
@property (nonatomic, copy) NSString *PAReq;

/**
 Do not change. This a the unique 3DS identifier assigned by Braintree to track the 3DS call as it progresses.
 */
@property (nonatomic, copy) NSString *MD;

/**
 Do not change. The URL which the customer will be redirected to for a 3DS Interface. In 3DS 1, there will always be an acsURL surfaced even if there isn't a password challenge. In 3DS 2, the presense of an acsURL indicates there is a challenge as it would otherwise frictionlessly complete without an acsURL.
 */
@property (nonatomic, copy) NSURL *acsURL;

/**
 Do not change. The termURL is the fully qualified URL that the customer will be redirected to once the authenticaiton completes.
 */
@property (nonatomic, copy) NSURL *termURL;

/**
 The full version string of the 3DS lookup result.
 */
@property (nonatomic, copy) NSString *threeDSecureVersion;

/**
 Indicates a 3DS 2 lookup result.
 */
@property (readonly, nonatomic) BOOL isThreeDSecureVersion2;

/**
 Do not change. This a secondary unique 3DS identifier assigned by Braintree to track the 3DS call as it progresses.
 */
@property (nonatomic, copy) NSString *transactionId;

/**
 The 3DS flow result which contains a BTCardNonce and liability shift information.

 @note If a challenge is required, liability will not be shifted on this nonce.
 */
@property (nonatomic, strong) BTThreeDSecureResult *threeDSecureResult;

/**
 Initialize a BTThreeDSecureLookup

 @param JSON BTJSON used to initialize the BTThreeDSecureLookup
 */
- (instancetype)initWithJSON:(BTJSON *)JSON;

/**
 Indicates if a challenge is required.

 @return A bool that is true if a challenge is required.
 */
- (BOOL)requiresUserAuthentication;

@end
