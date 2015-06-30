#import <Foundation/Foundation.h>
#import "BTNullability.h"
#import "BTTokenized.h"
#import "BTThreeDSecureInfo.h"

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

BT_ASSUME_NONNULL_BEGIN

@interface BTTokenizedCard : NSObject <BTTokenized>

@property (nonatomic, readonly, assign) BTCardNetwork cardNetwork;
@property (nonatomic, nullable, readonly, copy) NSString *lastTwo;

@property (nonatomic, nullable, readonly, strong) BTThreeDSecureInfo *threeDSecureInfo;

@end

BT_ASSUME_NONNULL_END
