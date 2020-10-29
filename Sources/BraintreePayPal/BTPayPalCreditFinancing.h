#import <Foundation/Foundation.h>

@interface BTPayPalCreditFinancing ()

- (instancetype)initWithCardAmountImmutable:(BOOL)cardAmountImmutable
                             monthlyPayment:(BTPayPalCreditFinancingAmount *)monthlyPayment
                            payerAcceptance:(BOOL)payerAcceptance
                                       term:(NSInteger)term
                                  totalCost:(BTPayPalCreditFinancingAmount *)totalCost
                              totalInterest:(BTPayPalCreditFinancingAmount *)totalInterest;

@end

