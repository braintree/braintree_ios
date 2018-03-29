#import <Foundation/Foundation.h>
#if __has_include("BraintreeCore.h")
#import "BraintreeCore.h"
#else
#import <BraintreeCore/BraintreeCore.h>
#endif
#import "BTThreeDSecureInfo.h"

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
 The last two digits of the card, if available.
*/
@property (nonatomic, nullable, readonly, copy) NSString *lastTwo;

/**
 The BIN data for the card number associated with this nonce.
 */
@property (nonatomic, readonly, strong) BTBinData *binData;

/**
 The 3D Secure info for the card number associated with this nonce.
 */
@property (nonatomic, readonly, strong) BTThreeDSecureInfo *threeDSecureInfo;

@end

NS_ASSUME_NONNULL_END
