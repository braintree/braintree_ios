#import <Foundation/Foundation.h>
#import "BTPaymentMethod.h"

/// Card type
typedef NS_ENUM(NSInteger, BTCardType) {
    BTCardTypeUnknown = 0,
    BTCardTypeAMEX,
    BTCardTypeDinersClub,
    BTCardTypeDiscover,
    BTCardTypeMasterCard,
    BTCardTypeVisa,
    BTCardTypeJCB,
    BTCardTypeLaser,
    BTCardTypeMaestro,
    BTCardTypeUnionPay,
    BTCardTypeSolo,
    BTCardTypeSwitch,
    BTCardTypeUKMaestro,
};

/// A payment method returned by the Client API that represents a Card associated with
/// a particular Braintree customer.
///
/// See also: BTPaymentMethod and BTMutableCardPaymentMethod.
@interface BTCardPaymentMethod : BTPaymentMethod

/// Type of card
@property (nonatomic, readonly, assign) BTCardType type;

/// String representation of type
@property (nonatomic, readonly, copy) NSString *typeString;

/// Last two digits of the card
@property (nonatomic, readonly, copy) NSString *lastTwo;

@end
