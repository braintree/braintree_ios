#import <Foundation/Foundation.h>
#if __has_include("BraintreeCore.h")
#import "BraintreeCore.h"
#else
#import <BraintreeCore/BraintreeCore.h>
#endif
#import "BTThreeDSecureInfo.h"
#import "BTAuthenticationInsight.h"

NS_ASSUME_NONNULL_BEGIN

/**
 Contains information about a tokenized card.
 */
@interface BTCardNonce : BTPaymentMethodNonce

/**
 The card network.
*/
@property (nonatomic, readonly, assign) BTCardNetwork cardNetwork;

/**
 The expiration month of the card, if available.
*/
@property (nonatomic, nullable, readonly, copy) NSString *expirationMonth;

/**
 The expiration year of the card, if available.
*/
@property (nonatomic, nullable, readonly, copy) NSString *expirationYear;

/**
 The name of the cardholder, if available.
*/
@property (nonatomic, nullable, readonly, copy) NSString *cardholderName;

/**
 The last two digits of the card, if available.
*/
@property (nonatomic, nullable, readonly, copy) NSString *lastTwo;

/**
 The last four digits of the card, if available.
*/
@property (nonatomic, nullable, readonly, copy) NSString *lastFour;

/**
 The BIN number of the card, if available.
 */
@property (nonatomic, nullable, readonly, copy) NSString *bin;

/**
 The BIN data for the card number associated with this nonce.
 */
@property (nonatomic, readonly, strong) BTBinData *binData;

/**
 The 3D Secure info for the card number associated with this nonce.
 */
@property (nonatomic, readonly, strong) BTThreeDSecureInfo *threeDSecureInfo;

/**
 Details about the regulatory environment and applicable customer authentication regulation
 for a potential transaction. This can be used to make an informed decision whether to perform
 3D Secure authentication.
 */
@property (nonatomic, nullable, readonly, strong) BTAuthenticationInsight *authenticationInsight;

@end

NS_ASSUME_NONNULL_END
