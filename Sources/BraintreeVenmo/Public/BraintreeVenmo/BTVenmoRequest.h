#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Usage for the tokenized Venmo account: either multi-use or single use
 */
typedef NS_ENUM(NSInteger, BTVenmoPaymentMethodUsage) {
    /// Multi-use
    BTVenmoPaymentMethodUsageMultiUse = 0,
    /// Single use
    BTVenmoPaymentMethodUsageSingleUse = 1
};

/**
 A BTVenmoRequest specifies options that contribute to the Venmo flow
*/
@interface BTVenmoRequest : NSObject

/**
 The Venmo profile ID to be used during payment authorization. Customers will see the business name and logo associated with this Venmo profile, and it will show up in the Venmo app as a "Connected Merchant". Venmo profile IDs can be found in the Braintree Control Panel. Leaving this `nil` will use the default Venmo profile.
 */
@property (nonatomic, nullable, copy) NSString *profileID;

/**
 Whether to automatically vault the Venmo Account. Vaulting will only occur if a client token with a customer_id is being used. Defaults to false.
 */
@property (nonatomic) BOOL vault;

/**
 Whether the resulting payment method may be used to make a one time payment (`.singleUse`) or to create a multi-use payment token (`.multiUse`). Defaults to `.multiUse`.
 */
@property (nonatomic) BTVenmoPaymentMethodUsage paymentMethodUsage;

@end

NS_ASSUME_NONNULL_END
