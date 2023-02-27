#import <Foundation/Foundation.h>

// MARK: - Swift File Imports for Package Managers
#if __has_include(<Braintree/Braintree-Swift.h>) // CocoaPods
#import <Braintree/Braintree-Swift.h>

#elif SWIFT_PACKAGE                              // SPM
/* Use @import for SPM support
 * See https://forums.swift.org/t/using-a-swift-package-in-a-mixed-swift-and-objective-c-project/27348
 */
@import BraintreeCore;

#elif __has_include("Braintree-Swift.h")         // CocoaPods for ReactNative
/* Use quoted style when importing Swift headers for ReactNative support
 * See https://github.com/braintree/braintree_ios/issues/671
 */
#import "Braintree-Swift.h"

#else                                            // Carthage
#import <BraintreeCore/BraintreeCore-Swift.h>
#endif

NS_ASSUME_NONNULL_BEGIN

/**
 Usage type for the tokenized Venmo account
 */
typedef NS_ENUM(NSInteger, BTVenmoPaymentMethodUsage) {
    /// The Venmo payment will be authorized for future payments and can be vaulted.
    BTVenmoPaymentMethodUsageMultiUse = 0,
    /// The Venmo payment will be authorized for a one-time payment and cannot be vaulted.
    BTVenmoPaymentMethodUsageSingleUse
};

/**
 A BTVenmoRequest specifies options that contribute to the Venmo flow
*/
@interface BTVenmoRequest : NSObject

/**
 Cannot be instantiated with [BTVenmoRequest new]
 */
+ (instancetype)new __attribute__((unavailable("Please use initWithPaymentMethodUsage:")));

/**
 Base initializer - do not use.
 */
- (instancetype)init __attribute__((unavailable("Please use initWithPaymentMethodUsage:")));


/**
 Initialize a Venmo request with a payment method usage.

 @param paymentMethodUsage `BTVenmoPaymentMethodUsage`
 @return A Venmo request.
*/
- (instancetype)initWithPaymentMethodUsage:(BTVenmoPaymentMethodUsage)paymentMethodUsage;

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
 */
@property (nonatomic, readonly) BTVenmoPaymentMethodUsage paymentMethodUsage;

/**
 * Optional. The business name that will be displayed in the Venmo app payment approval screen. Only used by merchants onboarded as PayFast channel partners.
 */
@property (nonatomic, nullable, copy) NSString *displayName;

/**
*
* If this property is set to false, you can still vault the Venmo account on your server, provided that `paymentMethodUsage` is not set to `.singleUse`.
*
* Defaults to false.
*/
@property (nonatomic) BOOL collectBillingAddress;

/**
*
* If this property is set to false, you can still vault the Venmo account on your server, provided that `paymentMethodUsage` is not set to `.singleUse`.
*
* Defaults to false.
*/
@property (nonatomic) BOOL collectShippingAddress;

/**
 * Optional. The business name that will be displayed in the Venmo app payment approval screen. Only used by merchants onboarded as PayFast channel partners.
 */
@property (nonatomic, nullable, copy) NSString *subTotalAmount;

/**
 * Optional. The business name that will be displayed in the Venmo app payment approval screen. Only used by merchants onboarded as PayFast channel partners.
 */
@property (nonatomic, nullable, copy) NSString *totalAmount;

/**
 * Optional. The business name that will be displayed in the Venmo app payment approval screen. Only used by merchants onboarded as PayFast channel partners.
 */
@property (nonatomic, nullable, copy) NSString *discountAmount;

/**
 * Optional. The business name that will be displayed in the Venmo app payment approval screen. Only used by merchants onboarded as PayFast channel partners.
 */
@property (nonatomic, nullable, copy) NSString *shippingAmount;

/**
 * Optional. The business name that will be displayed in the Venmo app payment approval screen. Only used by merchants onboarded as PayFast channel partners.
 */
@property (nonatomic, nullable, copy) NSString *taxAmount;

/**
 * Optional. The business name that will be displayed in the Venmo app payment approval screen. Only used by merchants onboarded as PayFast channel partners.
 */
@property (nonatomic, nullable) NSArray<BTPayPalLineItem *> *lineItems;

NS_ASSUME_NONNULL_END
