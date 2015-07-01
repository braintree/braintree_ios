#import <Foundation/Foundation.h>
#import <AddressBook/AddressBook.h>
#import <Contacts/Contacts.h>

#import "BTTokenized.h"
#import "BTPostalAddress.h"

BT_ASSUME_NONNULL_BEGIN

@interface BTTokenizedPayPalAccount : NSObject <BTTokenized>

/// Email address associated with the PayPal Account.
@property (nonatomic, copy) NSString *email;

/// Optional. Payer's first name.
/// Will be provided if you use -[PayPalDriver startCheckout:completion:]
@property (nonatomic, copy) NSString *firstName DEPRECATED_MSG_ATTRIBUTE("TODO: Move this to BTTokenizedPayPalCheckout");

/// Optional. Payer's last name.
/// Will be provided if you use -[PayPalDriver startCheckout:completion:]
@property (nonatomic, copy) NSString *lastName DEPRECATED_MSG_ATTRIBUTE("TODO: Move this to BTTokenizedPayPalCheckout");

/// Optional. Payer's phone number.
/// Will be provided if you use -[PayPalDriver startCheckout:completion:]
@property (nonatomic, copy) NSString *phone DEPRECATED_MSG_ATTRIBUTE("TODO: Move this to BTTokenizedPayPalCheckout");

/// Optional. The billing address.
/// Will be provided if you request "address" scope when using -[PayPalDriver startAuthorizationWithAdditionalScopes:completion:]
/// Will be provided if you use -[PayPalDriver startCheckout:completion:]
@property (nonatomic, copy) BTPostalAddress *billingAddress;

/// Optional. The shipping address.
/// Will be provided if you use -[PayPalDriver startCheckout:completion:]
@property (nonatomic, copy) BTPostalAddress *shippingAddress DEPRECATED_MSG_ATTRIBUTE("TODO: Move this to BTTokenizedPayPalCheckout");

@end

BT_ASSUME_NONNULL_END
