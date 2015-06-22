#pragma message "⚠️ Braintree's 3D Secure API for iOS is currently in beta: BTThreeDSecure.h may change. (Note: Gateway support is stable.)"

#import <Foundation/Foundation.h>

#import "BTClient.h"
#import "BTPaymentMethodCreationDelegate.h"
#import "BTThreeDSecureErrors.h"
#import "BTCardPaymentMethod+BTThreeDSecureInfo.h"

///  3D Secure Verification manager
///
///  3D Secure is a protocol that enables cardholders and issuers to add a layer of security
///  to e-commerce transactions via password entry at checkout.
///
///  One of the primary reasons to use 3D Secure is to benefit from a shift in liability from the
///  merchant to the issuer, which may result in interchange savings. Please read our online
///  documentation (https://developers.braintreepayments.com/ios/guides/3d-secure) for a full explanation of 3D Secure.
///
///  After initializing this class with a Braintree client and delegate, you may verify Braintree
///  payment methods via any of the three `verify…` methods. You should choose the most appropriate
///  method signature based on your v.zero integration approach. During verification, the delegate
///  may receive a request to present a view controller, as well as a success and failure messages.
///
///  Verification is associated with a transaction amount and your merchant account. To specify a
///  different merchant account, you will need to specify the merchant account id
///  when generating a client token (See https://developers.braintreepayments.com/ios/sdk/overview/generate-client-token ).
///
///  Your delegate must implement:
///    * paymentMethodCreator:didCreatePaymentMethod:
///    * paymentMethodCreator:didFailWithError:
///    * paymentMethodCreator:requestsPresentationOfViewController:
///    * paymentMethodCreator:requestsDismissalOfViewController:
///
///  When verification succeeds, the original payment method nonce is consumed, and you will receive
///  a new payment method nonce, which points to the original payment method, as well as the 3D
///  Secure Verification. Transactions created with this nonce are eligible for 3D Secure
///  liability shift.
///
///  When verification fails, the original payment method nonce is not consumed. While you may choose
///  to proceed with transaction creation, using the original payment method nonce, this transaction
///  will not be associated with a 3D Secure Verification.
///
///  @note The user authentication view controller is not always necessary to achieve the liabilty
///  shift. In these cases, your delegate will immediately receive paymentMethodCreator:didCreatePaymentMethod:.
@interface BTThreeDSecure : NSObject

///  Initializes a 3D Secure verification manager
///
///  @param client   A Braintree client. You should reuse your BTClient instance as much as possible. If you are using `Braintree`, you can obtain a client via the `-[Braintree client]` instance method.
///  @param delegate A delegate that receives messages about the lifecycle of verifying a payment method for 3D Secure
///
///  @return An initialized instance of BTThreeDSecure
- (instancetype)initWithClient:(BTClient *)client delegate:(id<BTPaymentMethodCreationDelegate>)delegate NS_DESIGNATED_INITIALIZER;

/// The delegate that is notified as the 3D Secure authentication flow progresses and completes
@property (nonatomic, weak) id<BTPaymentMethodCreationDelegate> delegate;

#pragma mark 3D Secure Verification

///  Verify a card for a 3D Secure transaction, referring to the card by raw payment method nonce
///
///  This method is useful for implementations where 3D Secure verification occurs after generating
///  a payment method nonce from a vaulted credit card on your backend
///
///  @note This method performs an asynchronous operation and may request presentation of a view
///        controller via the delegate. It is the caller's responsibility to present an activity
///        indication to the user in the meantime.
///
///  @param nonce  A payment method nonce
///  @param amount The amount of the transaction in the current merchant account's currency
- (void)verifyCardWithNonce:(NSString *)nonce amount:(NSDecimalNumber *)amount;

///  Verify a card for a 3D Secure transaction, referring to the card by BTCardPaymentMethod object
///
///  This method is useful for implementations where 3D Secure verification occurs after client-side
///  tokenization or client-side vault listing.
///
///  @note This method performs an asynchronous operation and may request presentation of a view
///        controller via the delegate. It is the caller's responsibility to present an activity
///        indication to the user in the meantime.
///
///  @param card   An object that represents a tokenized card (see BTPaymentMethodCreationDelegate)
///  @param amount The amount of the transaction in the current merchant account's currency
- (void)verifyCard:(BTCardPaymentMethod *)card amount:(NSDecimalNumber *)amount;

///  Verify a card for a 3D Secure transaction, tokenizing the card from user-provided details
///
///  This method is useful for implementations where 3D Secure verification occurs immediately after
///  raw card details are obtained from the user.
///
///  @note This method performs an asynchronous operation and may request presentation of a view
///        controller via the delegate. It is the caller's responsibility to present an activity
///        indication to the user in the meantime.
///
///  @param details An object containing the raw credit card details obtained from the user
///  @param amount  The amount of the transaction in the current merchant account's currency
- (void)verifyCardWithDetails:(BTClientCardRequest *)details amount:(NSDecimalNumber *)amount;

@end
