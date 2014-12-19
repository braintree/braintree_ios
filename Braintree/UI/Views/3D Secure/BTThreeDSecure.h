@import Foundation;

#import "BTClient.h"
#import "BTPaymentMethodCreationDelegate.h"

///  3D Secure verification manager
///
///  3D Secure is a protocol that enables cardholders and issuers to add a layer of security
///  to e-commerce transactions via password entry at checkout. Upon successful authentication,
///  a liability shift may take effect.
///
///  There are technically two stages to 3D Secure, which this class abstracts:
///  1. Lookup - detrmine whether the card is enrolled in 3D Secure and how to proceed with authentication
///  2. Authenticate - a web-based user login
///
///  After initializing this class with a Braintree client and delegate, you may verify Braintree
///  payment methods via any of the three `verify…` methods. You should choose the most appropriate
///  method signature based on your v.zero integration approach. During verification, the delegate
///  may receive a request to present a view controller, as well as a success and failure messages.
///
///  Your delegate must implement, at minimum:
///    * paymentMethodCreatior:didCreatePaymentMethod;
///    * paymentMethodCreatior:didFailWithError;
///    * paymentMethodCreatior:requestsPresentationOfViewController;
///    * paymentMethodCreatior:requestsDismissalOfViewController;
///
///  When verification succeeds, the original payment method nonce is consumed, and you will receive
///  a new payment method nonce, which points to the original payment method, as well as the 3D
///  Secure verification. Transactions created with this nonce will be 3D Secure, and benefit from the
///  appropraite liability shift.
///
///  When verification fails, the original payment method nonce is not consumed. While you may choose
///  to proceed with transaction creation, using the original payment method nonce, this transaction
///  will not receive any of the benefits of 3DS.
///
///  @note The user authentication view controller is not always necessary to achieve the liabilty
///  shift. In these cases, your delegate will immediately receive paymentMethodCreator:didCreatePaymentMethod:.
@interface BTThreeDSecure : NSObject

///  Initializes a 3D Secure verification manager
///
///  @param client   A Braintree client. You should reuse your BTClient instance as much as possible. If you are using `Braintree`, you can obtain a client via `-[Braintree client]`.
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
///  a payment method nonce from a Vaulted credit card on your backend
///
///  @param nonce  A payment method nonce
///  @param amount The decimal amount in dollars for the transaction
- (void)verifyCardWithNonce:(NSString *)nonce amount:(NSDecimalNumber *)amount;

///  Verify a card for a 3D Secure transaction, referring to the card by BTCardPaymentMethod object
///
///  This method is useful for implementations where 3D Secure verification occurs after client-side
///  tokenization or client-side Vault listing.
///
///  @param card A object that represents a tokenized card (see BTPaymentMethodCreationDelegate)
///  @param amount The decimal amount in dollars for the transaction
- (void)verifyCard:(BTCardPaymentMethod *)card amount:(NSDecimalNumber *)amount;

///  Verify a card for a 3D Secure transaction, tokenizing the card from user-provided details
///
///  This method is useful for implementations where 3D Secure verification occurs immediately after
///  raw card details are obtained from the user.
///
///  @param details A object containing the raw credit card details obtained from the user
///  @param amount The decimal amount in dollars for the transaction
- (void)verifyCardWithDetails:(BTClientCardRequest *)details amount:(NSDecimalNumber *)amount;

@end
