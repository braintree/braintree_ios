#import <Foundation/Foundation.h>

#if __has_include(<Braintree/BraintreePaymentFlow.h>)
#import <Braintree/BraintreeCore-Swift.h>
#else
#import <BraintreeCore/BraintreeCore-Swift.h>
#endif

/**
 Category on BTConfiguration for LocalPayment
 */
@interface BTConfiguration (LocalPayment)

/**
 Indicates whether Local Payments are enabled for the merchant account.
 */
@property (nonatomic, readonly, assign) BOOL isLocalPaymentEnabled;

@end
