#import "BTDropInBaseViewController.h"
#if __has_include("BraintreeUIKit.h")
#import "BraintreeUIKit.h"
#else
#import <BraintreeUIKit/BraintreeUIKit.h>
#endif

@class BTCardRequest, BTCardCapabilities;

NS_ASSUME_NONNULL_BEGIN

/// Contains form elements for entering card information.
@interface BTCardFormViewController : BTDropInBaseViewController <UITextFieldDelegate, BTKFormFieldDelegate, BTKCardNumberFormFieldDelegate>

@property (nonatomic, weak) id delegate;

/// The card number form field.
@property (nonatomic, strong, readonly) BTKCardNumberFormField *cardNumberField;

/// The expiration date form field.
@property (nonatomic, strong, readonly) BTKExpiryFormField *expirationDateField;

/// The security code (ccv) form field.
@property (nonatomic, strong, readonly) BTKSecurityCodeFormField *securityCodeField;

/// The postal code form field.
@property (nonatomic, strong, readonly) BTKPostalCodeFormField *postalCodeField;

/// The mobile country code form field.
@property (nonatomic, strong, readonly) BTKMobileCountryCodeFormField *mobileCountryCodeField;

/// The mobile phone number field.
@property (nonatomic, strong, readonly) BTKMobileNumberFormField *mobilePhoneField;

/// If the form is valid, returns a BTCardRequest using the values of the form fields. Otherwise `nil`.
@property (nonatomic, strong, nullable, readonly) BTCardRequest *cardRequest;

/// The BTCardCapabilities used to update the form after checking the card number. Applicable when UnionPay is enabled.
@property (nonatomic, strong, nullable, readonly) BTCardCapabilities *cardCapabilities;

/// Resets the state of the form fields
- (void)resetForm;

@end

NS_ASSUME_NONNULL_END
