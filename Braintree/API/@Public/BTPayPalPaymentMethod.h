#import "BTPaymentMethod.h"
#import "BTPostalAddress.h"

/// A payment method returned by the Client API that represents a PayPal account associated with
/// a particular Braintree customer.
///
/// @see BTPaymentMethod
/// @see BTMutablePayPalPaymentMethod
@interface BTPayPalPaymentMethod : BTPaymentMethod

/// Email address associated with the PayPal Account.
@property (nonatomic, copy) NSString *email;

/// Optional. Payer's first name.
/// Will be provided if you use -[PayPalDriver startCheckout:completion:]
@property (nonatomic, copy) NSString *firstName;

/// Optional. Payer's last name.
/// Will be provided if you use -[PayPalDriver startCheckout:completion:]
@property (nonatomic, copy) NSString *lastName;

/// Optional. Payer's phone number.
/// Will be provided if you use -[PayPalDriver startCheckout:completion:]
@property (nonatomic, copy) NSString *phone;

/// Optional. The billing address.
/// Will be provided if you request "address" scope when using -[PayPalDriver startAuthorizationWithAdditionalScopes:completion:]
/// Will be provided if you use -[PayPalDriver startCheckout:completion:]
@property (nonatomic, copy) BTPostalAddress *billingAddress;

/// Optional. The shipping address.
/// Will be provided if you use -[PayPalDriver startCheckout:completion:]
@property (nonatomic, copy) BTPostalAddress *shippingAddress;

/// Client Metadata Id associated with this transaction.
@property (nonatomic, copy) NSString *clientMetadataId;

/// Optional. Payer Id associated with this transaction.
/// Will be provided for Billing Agreement and Checkout.
@property (nonatomic, copy) NSString *payerId;
@end
