#import <Foundation/Foundation.h>
#import "BTPostalAddress.h"
#import "BTTokenized.h"

BT_ASSUME_NONNULL_BEGIN

@interface BTTokenizedPayPalCheckout : NSObject <BTTokenized>

// Payer's email address
@property (nonatomic, readonly, copy) NSString *email;

/// Payer's first name.
@property (nonatomic, readonly, copy) NSString *firstName;

/// Payer's last name.
@property (nonatomic, readonly, copy) NSString *lastName;

/// Payer's phone number.
@property (nonatomic, readonly, copy) NSString *phone;

/// The billing address.
@property (nonatomic, readonly, strong) BTPostalAddress *billingAddress;

/// The shipping address.
@property (nonatomic, readonly, strong) BTPostalAddress *shippingAddress;

/// Client Metadata Id associated with this transaction.
@property (nonatomic, readonly, copy) NSString *clientMetadataId;

/// Optional. Payer Id associated with this transaction.
/// Will be provided for Billing Agreement and Checkout.
@property (nonatomic, readonly, copy) NSString *payerId;

@end

BT_ASSUME_NONNULL_END
