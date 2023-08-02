#import <Foundation/Foundation.h>

@class BTVenmoLineItem;

NS_ASSUME_NONNULL_BEGIN

/**
 Usage type for the tokenized Venmo account
 */
typedef NS_ENUM(NSInteger, BTVenmoPaymentMethodUsage) {
    /// Unspecified
    BTVenmoPaymentMethodUsageUnspecified = 0,
    /// Multi-use
    BTVenmoPaymentMethodUsageMultiUse = 1,
    /// Single use
    BTVenmoPaymentMethodUsageSingleUse = 2
};

/**
 A BTVenmoRequest specifies options that contribute to the Venmo flow
*/
@interface BTVenmoRequest : NSObject

/**
 The Venmo profile ID to be used during payment authorization. Customers will see the business name and logo associated with this Venmo profile, and it may show up in the Venmo app as a "Connected Merchant". Venmo profile IDs can be found in the Braintree Control Panel. Leaving this `nil` will use the default Venmo profile.
 */
@property (nonatomic, nullable, copy) NSString *profileID;

/**
 * Whether to automatically vault the Venmo account on the client. For client-side vaulting, you must initialize BTAPIClient with a client token that was created with a customer ID. Also, `paymentMethodUsage` on the BTVenmoRequest must be set to `.multiUse`.
 *
 * If this property is set to false, you can still vault the Venmo account on your server, provided that `paymentMethodUsage` is not set to `.singleUse`.
 *
 * Defaults to false.
 */
@property (nonatomic) BOOL vault;

/**
 * If set to `.multiUse`, the Venmo payment will be authorized for future payments and can be vaulted.
 * If set to `.singleUse`, the Venmo payment will be authorized for a one-time payment and cannot be vaulted.
 * If set to `.unspecified`, the legacy Venmo UI flow will launch. It is recommended to use `.multiUse` or `.singleUse` for the best customer experience.
 *
 * Defaults to `.unspecified`.
 */
@property (nonatomic) BTVenmoPaymentMethodUsage paymentMethodUsage;

/**
 * Optional. The business name that will be displayed in the Venmo app payment approval screen. Only used by merchants onboarded as PayFast channel partners.
 */
@property (nonatomic, nullable, copy) NSString *displayName;

/**
*
* Whether the customer's billing address should be collected and displayed on the Venmo paysheet.
*
* Defaults to false.
*/
@property (nonatomic) BOOL collectCustomerBillingAddress;

/**
*
* Whether the customer's shipping address should be collected and displayed on the Venmo paysheet.
*
* Defaults to false.
*/
@property (nonatomic) BOOL collectCustomerShippingAddress;

/**
 * Optional. The subtotal amount of the transaction to be displayed on the paysheet. Excludes taxes, discounts, and shipping amounts.
 */
@property (nonatomic, nullable, copy) NSString *subTotalAmount;

/**
 * Optional. The grand total amount on the transaction that should be displayed on the paysheet.
 */
@property (nonatomic, nullable, copy) NSString *totalAmount;

/**
 * Optional. The total discount amount applied on the transaction to be displayed on the paysheet.
 */
@property (nonatomic, nullable, copy) NSString *discountAmount;

/**
 * Optional. The shipping amount for the transaction to be displayed on the paysheet.
 */
@property (nonatomic, nullable, copy) NSString *shippingAmount;

/**
 * Optional. The total tax amount for the transaction to be displayed on the paysheet.
 */
@property (nonatomic, nullable, copy) NSString *taxAmount;

/**
 * Optional. The line items for this transaction. It can include up to 249 line items.
 */
@property (nonatomic, nullable) NSArray<BTVenmoLineItem *> *lineItems;

@end

NS_ASSUME_NONNULL_END
