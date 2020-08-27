#import <BraintreeCore/BTConfiguration.h>

/**
 Category on BTConfiguration for LocalPayment
 */
@interface BTConfiguration (LocalPayment)

/**
 Indicates whether Local Payments are enabled for the merchant account.
 */
@property (nonatomic, readonly, assign) BOOL isLocalPaymentEnabled;

@end
