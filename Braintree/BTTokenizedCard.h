#import <Foundation/Foundation.h>
#import "BTJSON.h"
#import "BTNullability.h"
#import "BTTokenized.h"

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

@end

BT_ASSUME_NONNULL_END
