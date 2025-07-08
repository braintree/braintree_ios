/**
 Copyright © 2018 Visa. All rights reserved.
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "VisaPurchaseInfo.h"
#import "VisaProfile.h"
#import "VisaCheckoutResult.h"
#import "HandlerTypes.h"

/// :nodoc:
typedef NS_ENUM(NSInteger, VisaCheckoutButtonStyle);

/**
 This is the main point of interaction for your customers. The user
 will tap this button in order to initiate the Visa Checkout SDK's
 user interface. A VisaCheckoutButton can have a `VisaCheckoutButtonStyle`
 for different visual rendering options.
 
 You can use the `onCheckout(profile:purchaseInfo:presenting:onReady:onButtonTapped:completion:)` method to provide information that
 is used when the button is tapped by the user.
 */
@interface VisaCheckoutButton : UIView

/// :nodoc:
@property (nonatomic, assign) VisaCheckoutButtonStyle style;

- (void)onCheckoutWithPurchaseInfo:(VisaPurchaseInfo * _Nonnull)purchaseInfo
                      completion:(VisaCheckoutResultHandler _Nonnull)completion
DEPRECATED_MSG_ATTRIBUTE("Please use `onCheckout(profile:purchaseInfo:presenting:onReady:onButtonTapped:completion:)` instead")
NS_SWIFT_NAME(onCheckout(purchaseInfo:completion:));

/**
 A method to set the purchase information, presenting view controller and various other handlers for Visa Checkout.
 For the presenting view controller, provide an instance of UIViewController that will be used to present Visa Checkout modally. When the Visa Checkout button is clicked by a user, VisaCheckout
 will use this view controller to call present(\_:animated:completion:).
 This property is required to launch Visa Checkout. The UIViewController instance
 must be in your view hierarchy and must not already have a presentingViewController
 set because any additional calls to present(\_:animated:completion:) will be
 ignored by UIKit.
 Typically, you will set this value to the view controller that contains your
 VisaCheckoutButton.
 
 @param profile The object containing the necessary environment information for a merchant.
 @param purchaseInfo The purchase information with various settings used to customize the Checkout experience.
 @param presentingViewController Instance of UIViewController that will be used to present Visa Checkout
 modally.
 @param merchantOnReady Handler that is called twice, first time it sets the initial loading view, second time when Checkout is ready to launch.
 @param onButtonTapped Handler to notify merchant when checkout button has been tapped.
 @param completion A completion handler that is called when `VisaCheckout` is finished and
 has returned context back to your app.
 */
- (void)onCheckoutWithProfile:(VisaProfile *_Nonnull)profile
                 purchaseInfo:(VisaPurchaseInfo *_Nonnull)purchaseInfo
     presentingViewController:(UIViewController *_Nonnull)presentingViewController
                      onReady:(ManualCheckoutReadyHandler _Nonnull)merchantOnReady
               onButtonTapped:(ButtonTappedReadyHandler _Nonnull)onButtonTapped
                   completion:(VisaCheckoutResultHandler _Nonnull)completion
NS_SWIFT_NAME(onCheckout(profile:purchaseInfo:presenting:onReady:onButtonTapped:completion:));

- (void)onCheckoutWithTotal:(VisaCurrencyAmount * _Nonnull)total
                   currency:(VisaCurrency)currency
                 completion:(void (^ _Nonnull)(VisaCheckoutResult * _Nonnull))completion
DEPRECATED_MSG_ATTRIBUTE("Please use `onCheckout(profile:purchaseInfo:presenting:onReady:onButtonTapped:completion:)` instead")
NS_SWIFT_NAME(onCheckout(total:currency:completion:));

/** Call this method to update payment information after original information passed to Visa has changed.
 @param purchaseInfo A `VisaPurchaseInfo` object containing the updated values. The only values currently supported are
  `VisaPurchaseInfo.total`, `VisaPurchaseInfo.subtotal`, and `VisaPurchaseInfo.currency`.
 @param completion A completion handler for providing the results and possible error from the update payment info call. When `success` is false, it could just mean an unknown issue or that the submitted `purchaseInfo` is no different than what was submitted previously.
*/
- (void)updatePaymentInfo:(VisaPurchaseInfo * _Nonnull)purchaseInfo
           withCompletion:(void (^_Nullable)(BOOL success, NSError * _Nullable error))completion
NS_SWIFT_NAME(updatePaymentInfo(purchaseInfo:completion:));

/**
 This returns card art for recognized returning users. Otherwise, this returns the mini button image.
 
 ![miniButtonImage](../img/mini.png)
 */
+ (UIImage * _Nonnull)miniButtonImage;

/** A value indicating whether the Visa Checkout SDK is configured and ready to launch,
 The VisaCheckoutButton will be enabled when this property is true (and disabled when this property is false).
 */
@property (nonatomic, readonly) BOOL isReady DEPRECATED_MSG_ATTRIBUTE("Please use `onReady` callback to know when Visa Checkout is ready to launch");

/// :nodoc:
@property (nonatomic) IBInspectable BOOL standardStyle;

/** The enableAnimation is used to turn on or off the animation on the button.
 */
@property (nonatomic) BOOL enableAnimation DEPRECATED_MSG_ATTRIBUTE("Property is no longer supported");

@end

/// :nodoc:
typedef NS_ENUM(NSInteger, VisaCheckoutButtonStyle) {
    VisaCheckoutButtonStyleNeutral,
    VisaCheckoutButtonStyleStandard
} NS_SWIFT_NAME(CheckoutButtonStyle);
