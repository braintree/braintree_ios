/*
 * Venmo SDK
 *
 *********************************
 * BTPaymentViewController.h
 *********************************
 *
 * Drop in screen to handle input of card information by users of your app. This
 * view controller reduces the number of delegate methods you need to implement and UIView
 * components you need to display.
 *
 * BTPaymentViewController contains the BTPaymentFormView and can be used with or without
 * Venmo Touch. If Venmo Touch is enabled, the BTPaymentViewController will also contain a
 * VTCardView and VTCheckboxView.
 *
 * If Venmo Touch is enabled, the VTCardView and VTCheckboxView will be created for you.
 *
 * When using BTPaymentViewController, you must implement the two delegate methods
 * of BTPaymentViewControllerDelegate with Venmo Touch enabled. Without Venmo Touch,
 * you must implement only the first delegate method:
 *    - (void)paymentViewController:(BTPaymentViewController *)paymentViewController didSubmitCardWithInfo:(NSDictionary *)cardInfo andCardInfoEncrypted:(NSDictionary *)cardInfoEncrypted // Required
 *    - (void)paymentViewController:(BTPaymentViewController *)paymentViewController didAuthorizeCardWithPaymentMethodCode:(NSString *)paymentMethodCode  // Venmo Touch Only
 *
 * (See below for details on these two delegate methods).
 *
 * After a user successfully adds a card, it is the developer's
 * job to dismiss this BTPaymentViewConroller (e.g. by dismissing it modally).
 * Before doing so, please call `prepareForDismissal`.
 *
 * Right before a delegate method is triggered, the BTPaymentViewController will display
 * a "loading overlay" that blocks the UI (a BTPaymentActivityOverlayView). While the loading
 * overlay is being displayed, we recommend that you send the delegate method's payload (either
 * a "paymentMethodCode" or a "cardInfo" dictionary) to your server. Once your server returns
 * to the client with a response, you may dismiss the loading overlay.
 *
 * If a user manually enters a card, we recommend you vault the card before dismissing
 * the BTPaymentViewController, because vaulting the card will perform additional
 * validations, like ensuring the security code is correct, AVS/Zipcode validation passes
 * (if you have enabled this feature), and the card has not been blacklisted. In the
 * event that the security code or AVS validation fails, you'll want to display an
 * error message to the user asking them to change these fields, which is why we recommend
 * leaving the BTPaymentViewController visible until you have submitted the card successfully
 * to the gateway.
 *
 * If there is a server side error, eg, from the Braintree Gateway create credit card
 * endpoint, we recommend you forward that error message back to your iOS app and display
 * the error message to the end user with "showErrorWithTitle:message:". That will display the
 * error to the user (as well as dismiss the loading overlay) so that the user can modify
 * her input and verify her card again.
 */

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <VenmoTouch/VenmoTouch.h>
#import "BTPaymentFormView.h"

@protocol BTPaymentViewControllerDelegate;

@interface BTPaymentViewController : UITableViewController <BTPaymentFormViewDelegate, VTClientDelegate>

@property (strong, nonatomic) id<BTPaymentViewControllerDelegate>delegate;
@property (strong, nonatomic) BTPaymentFormView *paymentFormView;
@property (strong, nonatomic) VTCardView *cardView;
@property (strong, nonatomic) VTCheckboxView *checkboxCardView;

// Reads/Sets the corner radius of the payment form view, submit button, and (optionally) VTCardView.
@property (nonatomic) CGFloat cornerRadius; //default is 4

@property (strong, nonatomic) UIColor *viewBackgroundColor; // default is [UIColor colorWithWhite:85/255.0f alpha:1]

@property (nonatomic, assign) BOOL requestsZipInManualCardEntry; // default is YES

// UI customization of the Venmo Touch VTCardView
@property (strong, nonatomic) UIColor *vtCardViewBackgroundColor;
@property (strong, nonatomic) UIFont  *vtCardViewTitleFont;      // default is [UIFont boldSystemFontOfSize:16]
@property (strong, nonatomic) UIFont  *vtCardViewInfoButtonFont; // default is [UIFont boldSystemFontOfSize:11]

// Initializes a new BTPaymentViewController
+ (id)paymentViewControllerWithVenmoTouchEnabled:(BOOL)hasVenmoTouchEnabled;

// presents an error and dismisses the loading indicator
- (void)showErrorWithTitle:(NSString *)title message:(NSString *)message;

// dismisses the loading indicator
- (void)prepareForDismissal;

@end

@protocol BTPaymentViewControllerDelegate <NSObject>

@required

// Triggered when the user manually enters a credit card. A loading overlay (BTActivityOverlayView)
// will be presented above the BTPaymentViewController.view and block the UI.
//
// *** If using Venmo Touch, the cardInfo dictionary will be encrypted by your Braintree CSE key.
//
// Recommended use: Send the cardInfo dictionary to your payment processor for further
// verification (e.g. send it to your servers to verify the card information against the
// Braintree gateway). If there's an error in the server-side verification, display it via
// "showErrorWithTitle:message:". If there is no error from the server-side verification,
// call "prepareForDismissal" and then dismiss the BTPaymentViewController.
- (void)paymentViewController:(BTPaymentViewController *)paymentViewController
        didSubmitCardWithInfo:(NSDictionary *)cardInfo
         andCardInfoEncrypted:(NSDictionary *)cardInfoEncrypted;

@optional

// Triggered when the user taps "Use Card" and authorizes a Venmo Touch card. A loading
// overlay (BTActivityOverlayView) will be presented above the BTPaymentViewController.view
// and block the UI.
//
// *** Only implement this function if you have enabled Venmo Touch.
//
// Recommended use: Send the paymentMethodCode to your server so that it can be stored or used
// to make a payment. If there are any errors sending it to the server, display them via
// "showErrorWithTitle". If sending the paymentMethodCode was successful, call
// "prepareForDismissal" and then dismiss the BTPaymentViewController.
- (void)paymentViewController:(BTPaymentViewController *)paymentViewController
didAuthorizeCardWithPaymentMethodCode:(NSString *)paymentMethodCode;

@end
