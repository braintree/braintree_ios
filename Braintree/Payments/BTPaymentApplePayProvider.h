#import <Foundation/Foundation.h>

@class BTClient;
#import "BTPaymentMethodCreationDelegate.h"

/// A service class that provides a v.zero-specific wrapper around Apple Pay
///
/// Like BTPaymentProvider, this class facilities payment via
/// the BTPaymentMethodCreationDelegate protocol. Rather than requesting or creating a
/// view controller, you should call `authorizeApplePay`. When requested to do so, you
/// should present a view controller.
///
/// The view controller you receive may be a real PKPaymentAuthorizationViewController or
/// a mock view controller for sandbox testing.
@interface BTPaymentApplePayProvider : NSObject

/// Initializes an Apple Pay Provider
///
/// @param client a BTClient that is used to upload the encrypted payment data to Braintree
///
/// @return An initialized Apple Pay provider
- (instancetype)initWithClient:(BTClient *)client NS_DESIGNATED_INITIALIZER;

/// A required delegate that should receive notifications about the payment method
/// creation lifecycle.
///
/// @note You must set this delegate before calling `authorizeApplePay`.
@property (nonatomic, weak) id<BTPaymentMethodCreationDelegate> delegate;

#if BT_ENABLE_APPLE_PAY
@property (nonatomic, strong) NSArray *paymentSummaryItems;
@property (nonatomic, assign) PKAddressField requiredBillingAddressFields;
@property (nonatomic, assign) PKAddressField requiredShippingAddressFields;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
@property (nonatomic, assign) ABRecordRef billingAddress;
@property (nonatomic, assign) ABRecordRef shippingAddress;
#pragma clang diagnostic pop
@property (nonatomic, strong) PKContact *billingContact;
@property (nonatomic, strong) PKContact *shippingContact;

@property (nonatomic, strong) NSArray *shippingMethods;
@property (nonatomic, strong) NSArray *supportedNetworks;
#endif

/// Checks whether Apple Pay is possible, considering the current environment, simulator status,
/// device, OS, etc.
///
/// This method is useful for determining whether to present UI related to Apple Pay to your user.
/// You should avoid displaying Apple Pay as a payment option when it is unavailable.
///
/// @return `NO` if `authorizeApplePay` will definitely result in an error, `YES` otherwise
- (BOOL)canAuthorizeApplePayPayment;

/// Initialize Apple Pay.
///
/// @note You must set a delegate before calling this method.
- (void)authorizeApplePay;

@end
