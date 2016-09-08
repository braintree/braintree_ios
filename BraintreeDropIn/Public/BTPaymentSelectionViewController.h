#import <UIKit/UIKit.h>
#import "BTDropInBaseViewController.h"
#if __has_include("BraintreeUIKit.h")
#import "BraintreeUIKit.h"
#else
#import <BraintreeUIKit/BraintreeUIKit.h>
#endif

#if __has_include("BraintreeApplePay.h")
#define __BT_APPLE_PAY 
#import "BraintreeApplePay.h"
#elif __has_include(<BraintreeApplePay/BraintreeApplePay.h>)
#define __BT_APPLE_PAY
#import <BraintreeApplePay/BraintreeApplePay.h>
#endif

@class BTPaymentMethodNonce;

@protocol BTPaymentSelectionViewControllerDelegate;

/// @class A UIViewController that displays vaulted payment methods for a customer and available payment options
@interface BTPaymentSelectionViewController : BTDropInBaseViewController <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UITableViewDataSource, UITableViewDelegate>

/// The array of `BTPaymentMethodNonce` payment method nonces on file. The payment method nonces may be in the Vault.
/// Most payment methods are automatically Vaulted if the client token was generated with a customer ID.
@property (nonatomic, strong) NSArray *paymentMethodNonces;

/// The delegate
@property (nonatomic, weak) id<BTPaymentSelectionViewControllerDelegate> delegate;

@end

@protocol BTPaymentSelectionViewControllerDelegate <NSObject>

/// Called on the delegate when a payment method is selected
///
/// @param type The BTUIKPaymentOptionType of the selected payment method
/// @param nonce The BTPaymentMethodNonce of the selected payment method. @note This can be `nil` in the case of Apple Pay.
/// @param error The error that occured during tokenization of a new payment method.
- (void) selectionCompletedWithPaymentMethodType:(BTUIKPaymentOptionType) type nonce:(BTPaymentMethodNonce *)nonce error:(NSError *)error;

@end

