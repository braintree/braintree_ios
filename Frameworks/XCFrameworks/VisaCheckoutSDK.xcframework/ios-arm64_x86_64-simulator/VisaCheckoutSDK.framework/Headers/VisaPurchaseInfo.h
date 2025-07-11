/**
 Copyright © 2018 Visa. All rights reserved.
 */

#import <Foundation/Foundation.h>
#import "VisaCurrencyAmount.h"
#import "VInitInfo.h"

extern NSString * _Nonnull const kCurrency;
extern NSString * _Nonnull const kCustomData;
extern NSString * _Nonnull const kCustomDescription;
extern NSString * _Nonnull const kDiscount;
extern NSString * _Nonnull const kGiftWrapCharges;
extern NSString * _Nonnull const kMiscellaneousCharges;
extern NSString * _Nonnull const kOrderId;
extern NSString * _Nonnull const kPromoCode;
extern NSString * _Nonnull const kReferenceCallId;
extern NSString * _Nonnull const kRequestId;
extern NSString * _Nonnull const kReviewAction;
extern NSString * _Nonnull const kReviewMessage;
extern NSString * _Nonnull const kShippingAndHandlingCharges;
extern NSString * _Nonnull const kShippingRequired;
extern NSString * _Nonnull const kSourceId;
extern NSString * _Nonnull const kSubtotal;
extern NSString * _Nonnull const kTax;
extern NSString * _Nonnull const kThreeDSActive;
extern NSString * _Nonnull const kThreeDSSuppressChallenge;
extern NSString * _Nonnull const kTotal;
extern NSString * _Nonnull const kCurrencyFormat;
extern NSString * _Nonnull const kEnableUserDataPrefill;

/**
 This type represents a currency that Visa Checkout supports.
 */
typedef NS_ENUM(NSInteger, VisaCurrency) {
    /// United Arab Emirates Dirham
    VisaCurrencyAed,
    /// Argentina Peso
    VisaCurrencyArs,
    /// Australia Dollar
    VisaCurrencyAud,
    /// Brazil Real
    VisaCurrencyBrl,
    /// Canada Dollar
    VisaCurrencyCad,
    /// Chili Peso
    VisaCurrencyClp,
    /// China Yuan/Renminbi
    VisaCurrencyCny,
    /// Colombia Peso
    VisaCurrencyCop,
    /// Euro
    VisaCurrencyEur,
    /// Great Britain Pound
    VisaCurrencyGbp,
    /// Hong Kong Dollar
    VisaCurrencyHkd,
    /// India Rupee
    VisaCurrencyInr,
    /// Kuwait Dinar
    VisaCurrencyKwd,
    /// Mexico Peso
    VisaCurrencyMxn,
    /// Malaysia Ringgit
    VisaCurrencyMyr,
    /// New Zealand Dollar
    VisaCurrencyNzd,
    /// Peru Nuevo Sol
    VisaCurrencyPen,
    /// Poland Zloty
    VisaCurrencyPln,
    /// Qatar Riyal
    VisaCurrencyQar,
    /// Saudi Arabia Riyal
    VisaCurrencySar,
    /// Singapore Dollar
    VisaCurrencySgd,
    /// Ukraine hryvnia
    VisaCurrencyUah,
    /// USA Dollar
    VisaCurrencyUsd,
    /// South Africa Rand
    VisaCurrencyZar
} NS_SWIFT_NAME(Currency);

/**
 Indicates to the user if there will be another 'finalize purchase'
 screen once returning to the parent application.
 */
typedef NS_ENUM(NSInteger, VisaReviewAction) {
    /// Communicate to the user that their card information will be transferred to your app
    /// and stored somewhere other than their Visa Checkout account.
    VisaReviewActionCardOnFile,
    /// Purchase will require another 'finalize purchase' screen after Visa Checkout closes
    VisaReviewActionContinue,
    /// Purchase will be completed by tapping the 'pay' button inside Visa Checkout
    VisaReviewActionPay
} NS_SWIFT_NAME(ReviewAction);

/**
 The `VisaPurchaseInfo` class is used for you to send the Visa Checkout SDK the
 detailed information regarding your customers' purchase.
 */
NS_SWIFT_NAME(PurchaseInfo)
@interface VisaPurchaseInfo : VInitInfo

/**
 The currency being used to make the purchase. This will be displayed
 to the user and the `total` amount is expected to be converted to
 the rate of this currency.
 */
@property (nonatomic, assign) VisaCurrency currency;

/**
 Add any custom key/value pairs if needed. Keys can be a
 maximum of 100 characters and values can be maximum of
 500 characters.
 */
@property (nonatomic, strong) NSDictionary *_Nullable customData;

/**
 A custom description you may use to describe this purchase. Informational only.
 */
@property (nonatomic, strong) NSString *_Nullable customDescription;

/**
 The amount of a discount on this purchase. Informational only.
 */
@property (nonatomic, strong) VisaCurrencyAmount *_Nullable discount;

/**
 The gift wrapping charges associated with this purchase.
 Informational only.
 */
@property (nonatomic, strong) VisaCurrencyAmount *_Nullable giftWrapCharges;

/**
 Any amount associated with miscellaneous charges for this purchase.
 Informational only.
 */
@property (nonatomic, strong) VisaCurrencyAmount *_Nullable miscellaneousCharges;

/**
 Set the block that fetches the user's prefill information. Create the prefill
 dictionary and pass it into the `VisaConfigResponse` block parameter.
 */

@property (nonatomic, strong) VisaConfigRequest _Nullable onPrefillRequest;

/**
 A custom value you may use to identify the purchase. Informational only.
 */
@property (nonatomic, strong) NSString *_Nullable orderId;

/**
 A promotional code entered by the user to make this purchase.
 Informational only.
 */
@property (nonatomic, strong) NSString *_Nullable promoCode;

/**
 This value should be set if a successful `VisaCheckoutResult` was received
 AND you need to modify the purchase by invoking the Visa Checkout SDK
 again for the same purchase.
 
 For instance, if the user successfully completes the Visa Checkout process,
 `VisaCheckoutResult.callId` will be populated with a string that represents
 this purchase. If, then, you need to make adjustments to the exact same
 purchase, you must be sure to set this value to the one obtained from
 `VisaCheckoutResult.callId` before the user attempts to checkout again.
 
 * * * * * *
 
 *An example of setting the `referenceCallId` with the value from a
 `VisaCheckoutResult` instance*
 
 ```ruby
 VisaCheckoutResult* result;
 result = resultFromCallback;
 PurchaseInfo* purchaseInfo = [[PurchaseInfo alloc] init...]
 
 purchaseInfo.referenceCallId = result.callId
 ```
 */
@property (nonatomic, strong) NSString *_Nullable referenceCallId;

/**
 A custom value you may use to identify this Visa Checkout attempt.
 Informational only.
 */
@property (nonatomic, strong) NSString *_Nullable requestId;

/**
 Indicates to the user if there will be another 'finalize
 purchase' screen once returning to your application.
 Default is `continue`
 */
@property (nonatomic, assign) VisaReviewAction reviewAction;

/**
 Allows setting a custom review and continue message
 shown as a label below the Continue/Pay button
 */
@property (nonatomic, strong) NSString *_Nullable reviewMessage;

/**
 The shipping and handling charges associated with this purchase.
 Informational only.
 */
@property (nonatomic, strong) VisaCurrencyAmount *_Nullable shippingAndHandlingCharges;

/**
 Determines whether you require a shipping address from your
 customers. If `true`, the user will be required to provide
 a valid shipping address in addition to a valid billing
 address. This should be set to `true` if you intend to send
 physical items to the user. Default value is `false`.
 */
@property (nonatomic, assign) BOOL shippingRequired;

/**
 A custom value you may use to identify this user. Informational only.
 */
@property (nonatomic, strong) NSString *_Nullable sourceId;

/**
 The subtotal of the purchase. Informational only.
 */
@property (nonatomic, strong) VisaCurrencyAmount *_Nullable subtotal;

/**
 The taxes assessed on this purchase. Informational only.
 */
@property (nonatomic, strong) VisaCurrencyAmount *_Nullable tax;

/**
 Set this to true if 3DS should be active.
 */
@property (nonatomic, assign) BOOL threeDSActive;

/**
 Set this to true if 3DS should not challenge the user.
 */
@property (nonatomic, assign) BOOL threeDSSuppressChallenge;

/**
 The total amount of the purchase being deducted from the user's
 credit card account, including any taxes, shipping fees, etc.
 This is required.
 */
@property (nonatomic, strong) VisaCurrencyAmount *_Nonnull total;

/**
 A string that specifies the display format for a currency amount associated with the Pay button.
 If not set here, the default format displays the amount as xxx 999,999,999.99,
 where xxx is the ISO 4217 standard alpha-3 currency code for the currency being used,
 suppressing leading zeros ( 0 ) and truncating additional precision in the display;
 for example, USD 1,000.00. The actual value being displayed remains unchanged.
 */
@property (nonatomic, strong) NSString *_Nullable currencyFormat;

/**
 Whether the user data prefill event handler is active for this transaction.
 You must be enabled by Visa Checkout to use the prefill feature;
 contact Visa Checkout for more information.
 */
@property (nonatomic, assign) BOOL enableUserDataPrefill;

/**
 Initialize with an amount and currency.
 
 @param amount Required to notify the user of the total amount of this purchase.
 @param currency Required to identify which currency the total amount is being charged.
 */
- (instancetype _Nonnull)initWithTotal:(VisaCurrencyAmount *_Nonnull)amount currency:(VisaCurrency)currency;

@end
