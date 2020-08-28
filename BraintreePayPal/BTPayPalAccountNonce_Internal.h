#import <BraintreePayPal/BTPayPalAccountNonce.h>
#import <BraintreePayPal/BTPayPalCreditFinancing.h>

@interface BTPayPalAccountNonce ()

- (instancetype)initWithNonce:(NSString *)nonce
                  description:(NSString *)description
                        email:(NSString *)email
                    firstName:(NSString *)firstName
                     lastName:(NSString *)lastName
                        phone:(NSString *)phone
               billingAddress:(BTPostalAddress *)billingAddress
              shippingAddress:(BTPostalAddress *)shippingAddress
             clientMetadataId:(NSString *)clientMetadataId
                      payerId:(NSString *)payerId
                    isDefault:(BOOL)isDefault
              creditFinancing:(BTPayPalCreditFinancing *)creditFinancing;

@end

@interface BTPayPalCreditFinancing ()

- (instancetype)initWithCardAmountImmutable:(BOOL)cardAmountImmutable
                             monthlyPayment:(BTPayPalCreditFinancingAmount *)monthlyPayment
                            payerAcceptance:(BOOL)payerAcceptance
                                       term:(NSInteger)term
                                  totalCost:(BTPayPalCreditFinancingAmount *)totalCost
                              totalInterest:(BTPayPalCreditFinancingAmount *)totalInterest;

@end

@interface BTPayPalCreditFinancingAmount ()

- (instancetype)initWithCurrency:(NSString *)currency value:(NSString *)value;

@end
