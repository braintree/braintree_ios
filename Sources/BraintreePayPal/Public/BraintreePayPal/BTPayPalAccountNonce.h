@class BTPostalAddress;
@class BTJSON;
@class BTPayPalCreditFinancing;
@class BTPayPalCreditFinancingAmount;

/**
 Contains information about a PayPal payment method
 */
@interface BTPayPalAccountNonce : NSObject

/**
 The payment method nonce.
 */
@property (nonatomic, readonly, strong) NSString * _Nonnull nonce;

/**
 The string identifying the type of the payment method.
 */
@property (nonatomic, readonly, strong) NSString * _Nullable type;

/**
 The boolean indicating whether this is a default payment method.
 */
@property (nonatomic, readwrite, assign) BOOL isDefault;

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
 Payer's phone number.
*/
@property (nonatomic, nullable, readonly, copy) NSString *phone;

/**
 The billing address.
*/
@property (nonatomic, nullable, readonly, strong) BTPostalAddress *billingAddress;

/**
 The shipping address.
*/
@property (nonatomic, nullable, readonly, strong) BTPostalAddress *shippingAddress;

/**
 Client metadata id associated with this transaction.
*/
@property (nonatomic, nullable, readonly, copy) NSString *clientMetadataID;

/**
 Optional. Payer id associated with this transaction.

 Will be provided for Vault and Checkout.
*/
@property (nonatomic, nullable, readonly, copy) NSString *payerID;

/**
 Optional. Credit financing details if the customer pays with PayPal Credit.

 Will be provided for Vault and Checkout.
 */
@property (nonatomic, nullable, readonly, strong) BTPayPalCreditFinancing *creditFinancing;

/**
 Used to initialize a `BTPayPalAccountNonce` with parameters.
 */
- (nullable instancetype)initWithJSON:(BTJSON *_Nonnull)json;

@end
