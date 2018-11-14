#import <Foundation/Foundation.h>
#if __has_include("BraintreeCore.h")
#import "BraintreeCore.h"
#else
#import <BraintreeCore/BraintreeCore.h>
#endif
#import "BTPaymentFlowResult.h"

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
 Client Metadata Id associated with this transaction.
 */
@property (nonatomic, nullable, readonly, copy) NSString *clientMetadataId;

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
 A localized description of the payment info.
 */
@property (nonatomic, readonly, copy) NSString *localizedDescription;

/**
 The one-time use payment method nonce.
 */
@property (nonatomic, readonly, copy) NSString *nonce;

/**
 Optional. Payer Id associated with this transaction.
 */
@property (nonatomic, nullable, readonly, copy) NSString *payerId;

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
 @param description A localized description of the payment info.
 @param type The type of the tokenized payment.
 @param email Payer's email address.
 @param firstName Payer's first name.
 @param lastName Payer's last name.
 @param phone Payer's phone number.
 @param billingAddress The billing address.
 @param shippingAddress The shipping address.
 @param clientMetadataId Client Metadata Id associated with this transaction.
 @param payerId Payer Id associated with this transaction.
 */
- (instancetype)initWithNonce:(NSString *)nonce
                  description:(NSString *)description
                         type:(NSString *)type
                        email:(NSString *)email
                    firstName:(NSString *)firstName
                     lastName:(NSString *)lastName
                        phone:(NSString *)phone
               billingAddress:(BTPostalAddress *)billingAddress
              shippingAddress:(BTPostalAddress *)shippingAddress
             clientMetadataId:(NSString *)clientMetadataId
                      payerId:(NSString *)payerId;

@end

NS_ASSUME_NONNULL_END
