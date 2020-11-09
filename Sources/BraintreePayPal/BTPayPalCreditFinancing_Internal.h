#if __has_include(<Braintree/BraintreePayPal.h>)
#import <Braintree/BTPayPalCreditFinancing.h>
#else
#import <BraintreePayPal/BTPayPalCreditFinancing.h>
#endif

@interface BTPayPalCreditFinancing ()

- (instancetype)initWithCardAmountImmutable:(BOOL)cardAmountImmutable
                             monthlyPayment:(BTPayPalCreditFinancingAmount *)monthlyPayment
                            payerAcceptance:(BOOL)payerAcceptance
                                       term:(NSInteger)term
                                  totalCost:(BTPayPalCreditFinancingAmount *)totalCost
                              totalInterest:(BTPayPalCreditFinancingAmount *)totalInterest;

@end

