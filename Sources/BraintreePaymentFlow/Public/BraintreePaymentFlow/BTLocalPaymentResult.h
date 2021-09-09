#if __has_include(<Braintree/BraintreePaymentFlow.h>)
#import <Braintree/BTPaymentFlowResult.h>
#else
#import <BraintreePaymentFlow/BTPaymentFlowResult.h>
#endif

@class BTPostalAddress;

NS_ASSUME_NONNULL_BEGIN

/**
 The result of an local payment flow
 */
@interface BTLocalPaymentResult : BTPaymentFlowResult

/**
 The billing address.
 */
@property (nonatomic, nullable, readonly, strong) BTPostalAddress *billingAddress;

/**
 Client Metadata ID associated with this transaction.
 */
@property (nonatomic, nullable, readonly, copy) NSString *clientMetadataID;

/**
 Payer's email address.
 */
@property (nonatomic, nullable, readonly, copy) NSString *email;

/**
 Payer's first name.
 */
@property (nonatomic, nullable, readonly, copy) NSString *firstName;

/**
 Payer's last name.
 */
@property (nonatomic, nullable, readonly, copy) NSString *lastName;

/**
 The one-time use payment method nonce.
 */
@property (nonatomic, readonly, copy) NSString *nonce;

/**
 Optional. Payer ID associated with this transaction.
 */
@property (nonatomic, nullable, readonly, copy) NSString *payerID;

/**
 Payer's phone number.
 */
@property (nonatomic, nullable, readonly, copy) NSString *phone;

/**
 The shipping address.
 */
@property (nonatomic, nullable, readonly, strong) BTPostalAddress *shippingAddress;

/**
 The type of the tokenized payment.
 */
@property (nonatomic, readonly, copy) NSString *type;

/**
 Creates a BTLocalPaymentResult.

 @param nonce The one-time use payment method nonce.
 @param type The type of the tokenized payment.
 @param email Payer's email address.
 @param firstName Payer's first name.
 @param lastName Payer's last name.
 @param phone Payer's phone number.
 @param billingAddress The billing address.
 @param shippingAddress The shipping address.
 @param clientMetadataID Client Metadata ID associated with this transaction.
 @param payerID Payer ID associated with this transaction.
 */
- (instancetype)initWithNonce:(NSString *)nonce
                         type:(NSString *)type
                        email:(NSString *)email
                    firstName:(NSString *)firstName
                     lastName:(NSString *)lastName
                        phone:(NSString *)phone
               billingAddress:(BTPostalAddress *)billingAddress
              shippingAddress:(BTPostalAddress *)shippingAddress
             clientMetadataID:(NSString *)clientMetadataID
                      payerID:(NSString *)payerID;

@end

NS_ASSUME_NONNULL_END
