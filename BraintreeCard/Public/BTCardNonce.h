#import <Foundation/Foundation.h>
#if __has_include("BraintreeCore.h")
#import "BraintreeCore.h"
#else
#import <BraintreeCore/BraintreeCore.h>
#endif

/// Card type
typedef NS_ENUM(NSInteger, BTCardNetwork) {
    BTCardNetworkUnknown = 0,
    BTCardNetworkAMEX,
    BTCardNetworkDinersClub,
    BTCardNetworkDiscover,
    BTCardNetworkMasterCard,
    BTCardNetworkVisa,
    BTCardNetworkJCB,
    BTCardNetworkLaser,
    BTCardNetworkMaestro,
    BTCardNetworkUnionPay,
    BTCardNetworkSolo,
    BTCardNetworkSwitch,
    BTCardNetworkUKMaestro,
};

NS_ASSUME_NONNULL_BEGIN

@interface BTCardNonce : BTPaymentMethodNonce

/// The card network.
@property (nonatomic, readonly, assign) BTCardNetwork cardNetwork;

/// The last two digits of the card, if available.
@property (nonatomic, nullable, readonly, copy) NSString *lastTwo;

#pragma mark - Internal

/// Create a `BTCardNonce` object from JSON.
+ (instancetype)cardNonceWithJSON:(BTJSON *)cardJSON;

@end

NS_ASSUME_NONNULL_END
