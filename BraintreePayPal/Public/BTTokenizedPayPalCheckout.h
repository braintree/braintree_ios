#import <Foundation/Foundation.h>
#if __has_include("BraintreeCore.h")
#import "BraintreeCore.h"
#else
#import <BraintreeCore/BraintreeCore.h>
#endif

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
