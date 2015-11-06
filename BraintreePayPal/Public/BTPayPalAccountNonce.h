#import <Foundation/Foundation.h>
#if __has_include("BraintreeCore.h")
#import "BraintreeCore.h"
#else
#import <BraintreeCore/BraintreeCore.h>
#endif

@interface BTPayPalAccountNonce : BTPaymentMethodNonce

/// Payer's email address
@property (nonatomic, nullable, readonly, copy) NSString *email;

/// Payer's first name.
@property (nonatomic, nullable, readonly, copy) NSString *firstName;

/// Payer's last name.
@property (nonatomic, nullable, readonly, copy) NSString *lastName;

/// Payer's phone number.
@property (nonatomic, nullable, readonly, copy) NSString *phone;

/// The billing address.
@property (nonatomic, nullable, readonly, strong) BTPostalAddress *billingAddress;

/// The shipping address.
@property (nonatomic, nullable, readonly, strong) BTPostalAddress *shippingAddress;

/// Client Metadata Id associated with this transaction.
@property (nonatomic, nullable, readonly, copy) NSString *clientMetadataId;

/// Optional. Payer Id associated with this transaction.
/// Will be provided for Billing Agreement and Checkout.
@property (nonatomic, nullable, readonly, copy) NSString *payerId;

@end
