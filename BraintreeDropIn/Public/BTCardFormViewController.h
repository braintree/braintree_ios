#import "BTDropInBaseViewController.h"
#if __has_include("BraintreeUIKit.h")
#import "BraintreeUIKit.h"
#else
#import <BraintreeUIKit/BraintreeUIKit.h>
#endif

@class BTCardRequest, BTCardCapabilities, BTPaymentMethodNonce;

NS_ASSUME_NONNULL_BEGIN
@protocol BTCardFormViewControllerDelegate;

/// Contains form elements for entering card information.
@interface BTCardFormViewController : BTDropInBaseViewController <UITextFieldDelegate, BTUIKFormFieldDelegate, BTUIKCardNumberFormFieldDelegate>

@property (nonatomic, weak) id<BTCardFormViewControllerDelegate> delegate;

/// The card number form field.
@property (nonatomic, strong, readonly) BTUIKCardNumberFormField *cardNumberField;

/// The expiration date form field.
@property (nonatomic, strong, readonly) BTUIKExpiryFormField *expirationDateField;

/// The security code (ccv) form field.
@property (nonatomic, strong, readonly) BTUIKSecurityCodeFormField *securityCodeField;

/// The postal code form field.
@property (nonatomic, strong, readonly) BTUIKPostalCodeFormField *postalCodeField;

/// The mobile country code form field.
@property (nonatomic, strong, readonly) BTUIKMobileCountryCodeFormField *mobileCountryCodeField;

/// The mobile phone number field.
@property (nonatomic, strong, readonly) BTUIKMobileNumberFormField *mobilePhoneField;

/// If the form is valid, returns a BTCardRequest using the values of the form fields. Otherwise `nil`.
@property (nonatomic, strong, nullable, readonly) BTCardRequest *cardRequest;

/// The BTCardCapabilities used to update the form after checking the card number. Applicable when UnionPay is enabled.
@property (nonatomic, strong, nullable, readonly) BTCardCapabilities *cardCapabilities;

/// The card network types supported by this merchant
@property (nonatomic, copy) NSArray *supportedCardTypes;

/// Resets the state of the form fields
- (void)resetForm;

@end

@protocol BTCardFormViewControllerDelegate <NSObject>

- (void)cardTokenizationCompleted:(BTPaymentMethodNonce * _Nullable )tokenizedCard error:(NSError * _Nullable )error sender:(BTCardFormViewController *) sender;

@end


NS_ASSUME_NONNULL_END
