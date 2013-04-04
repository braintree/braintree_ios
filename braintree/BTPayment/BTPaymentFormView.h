/*
 * Venmo SDK
 *
 ******************************
 * BTPaymentFormView.h
 ******************************
 *
 * UIView containing a form users can use to manually enter credit card information, including:
 *    - card number
 *    - expiration date
 *    - security code
 *    - zipcode (optionally)
 *
 * The UIView presents all the card input fields in a single line, so the entire view only
 * requires 40 px of vertical space.
 *
 * Hint images show the correct card logo after the user enters the first ~2 characters of
 * her card number. Then, the hint images animate to show where the user can find the
 * security code when she focuses on the security code field (3 digits on back
 * of card in most cases, 4 digits on front of card for Amex).
 *
 * Also based on the card type, spacing of the card numbers adjusts to match the spacing
 * on the card, making it easier for a user to keep her place as they look back and forth
 * from her physical card to the input form.
 * (eg. Amex: 1234 123456 12345, Others: 1234 5678 9012 3456).
 *
 * Validation on all fields happens as the user enters her information, catching errors
 * before the user submits the form to the server, saving slow/expensive round trips in the
 * event where a user mis-types information. Validations include:
 *    - Luhn algorithm to validate card number (15 digits for Amex, 16 digits for others, and
 *      valid checksum in all cases)
 *    - Expiration date cannot be in past
 *    - Security code must be 4 digits for Amex, 3 digits for others
 *
 * BTPaymentFormView is a subclass of UIView, so you may use any methods on UIView to achieve
 * specific styling (like backgroundColor, borderWidth, etc).
 */

#import <UIKit/UIKit.h>
#import "BTPaymentFormTextField.h"

@protocol BTPaymentFormViewDelegate;

@interface BTPaymentFormView : UIView <UITextFieldDelegate>

@property (nonatomic, assign) BOOL requestsZip; // default is YES

@property (strong, nonatomic) BTPaymentFormTextField *cardNumberTextField;
@property (strong, nonatomic) BTPaymentFormTextField *monthYearTextField;
@property (strong, nonatomic) BTPaymentFormTextField *cvvTextField;
@property (strong, nonatomic) BTPaymentFormTextField *zipTextField;
@property (strong, nonatomic) id<BTPaymentFormViewDelegate>delegate;

// Initializes a new BTPaymentFormView with default size 300px X 40px
+ (BTPaymentFormView *)paymentFormView;

// Checks if the payment from contains valid information of a card based on the client-side
// validations above (luhn, exp date, security code)
- (BOOL)hasValidCardEntry;

// Returns a dictionary of the user-entered card information, omitting keys/values that are blank:
//    - "card_number"
//    - "expiration_month"
//    - "expiration_year"
//    - "cvv"
//    - "zipcode" (optional)
- (NSDictionary *)cardEntry;

// Returns what the user has entered in that text field, or nil if the text field is blank/nonexistent.
- (NSString *)cardNumberEntry;
- (NSString *)monthExpirationEntry;
- (NSString *)yearExpirationEntry;
- (NSString *)cvvEntry;
- (NSString *)zipEntry;

- (void)setOrigin:(CGPoint)origin; // Convenience UI method

@end

@protocol BTPaymentFormViewDelegate <NSObject>

@optional
// Triggered whenever the user edits a field in the payment form view, alerting the delegate
// if the card information passes client-side checks. From here, you may get all the card info
// via "cardEntry" or each piece of card info from the payment form individually.
- (void)paymentFormView:(BTPaymentFormView *)paymentFormView didModifyCardInformationWithValidity:(BOOL)isValid;

@end
