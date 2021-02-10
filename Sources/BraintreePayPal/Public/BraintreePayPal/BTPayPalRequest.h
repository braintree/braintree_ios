#import <UIKit/UIKit.h>
@class BTPostalAddress; 
@class BTPayPalLineItem;

NS_ASSUME_NONNULL_BEGIN

/**
 Use this option to specify the PayPal page to display when a user lands on the PayPal site to complete the payment.
*/
typedef NS_ENUM(NSInteger, BTPayPalRequestLandingPageType) {
    /// Default
    BTPayPalRequestLandingPageTypeDefault = 1, // Obj-C enums cannot be nil; this default option is used to make `landingPageType` optional for merchants

    /// Login
    BTPayPalRequestLandingPageTypeLogin,

    /// Billing
    BTPayPalRequestLandingPageTypeBilling,
};

/**
 Base options for PayPal Checkout and PayPal Vault flows.

 @note Do not instantiate this class directly. Instead, use BTPayPalCheckoutRequest or BTPayPalVaultRequest.
*/
@interface BTPayPalRequest : NSObject

/**
 Defaults to false. When set to true, the shipping address selector will be displayed.
*/
@property (nonatomic, getter=isShippingAddressRequired) BOOL shippingAddressRequired;

/**
 Defaults to false. Set to true to enable user editing of the shipping address.

 @note Only applies when `shippingAddressOverride` is set.
 */
@property (nonatomic, getter=isShippingAddressEditable) BOOL shippingAddressEditable;

/**
 Optional: A locale code to use for the transaction.

 @note Supported locales are:

 `da_DK`,
 `de_DE`,
 `en_AU`,
 `en_GB`,
 `en_US`,
 `es_ES`,
 `es_XC`,
 `fr_CA`,
 `fr_FR`,
 `fr_XC`,
 `id_ID`,
 `it_IT`,
 `ja_JP`,
 `ko_KR`,
 `nl_NL`,
 `no_NO`,
 `pl_PL`,
 `pt_BR`,
 `pt_PT`,
 `ru_RU`,
 `sv_SE`,
 `th_TH`,
 `tr_TR`,
 `zh_CN`,
 `zh_HK`,
 `zh_TW`,
 `zh_XC`.
*/
@property (nonatomic, nullable, copy) NSString *localeCode;

/**
 Optional: A valid shipping address to be displayed in the transaction flow. An error will occur if this address is not valid.
*/
@property (nonatomic, nullable, strong) BTPostalAddress *shippingAddressOverride;

/**
 Optional: Landing page type. Defaults to `BTPayPalRequestLandingPageTypeDefault`.

 @note Setting the BTPayPalRequest's landingPageType changes the PayPal page to display when a user lands on the PayPal site to complete the payment. BTPayPalRequestLandingPageTypeLogin specifies a PayPal account login page is used. BTPayPalRequestLandingPageTypeBilling specifies a non-PayPal account landing page is used.
 */
@property (nonatomic) BTPayPalRequestLandingPageType landingPageType;

/**
 Optional: The merchant name displayed inside of the PayPal flow; defaults to the company name on your Braintree account
*/
@property (nonatomic, nullable, copy) NSString *displayName;

/**

 Optional: A non-default merchant account to use for tokenization.
*/
@property (nonatomic, nullable, copy) NSString *merchantAccountID;

/**
 Optional: The line items for this transaction. It can include up to 249 line items.
*/
@property (nonatomic, nullable, copy) NSArray<BTPayPalLineItem *> *lineItems;

/**
 Optional: Display a custom description to the user for a billing agreement. For Checkout with Vault flows, you must also set requestBillingAgreement to true on your BTPayPalCheckoutRequest.
*/
@property (nonatomic, nullable, copy) NSString *billingAgreementDescription;

/**
 Optional: The window used to present the ASWebAuthenticationSession.

 @note If your app supports multitasking, you must set this property to ensure that the ASWebAuthenticationSession is presented on the correct window.
 */
@property (nonatomic, nullable, strong) UIWindow *activeWindow;

@end

NS_ASSUME_NONNULL_END
