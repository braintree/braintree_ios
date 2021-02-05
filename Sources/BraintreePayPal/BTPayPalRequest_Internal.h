#if __has_include(<Braintree/BraintreePayPal.h>)
#import <Braintree/BTPayPalRequest.h>
#import <Braintree/BraintreeCore.h>
#else
#import <BraintreePayPal/BTPayPalRequest.h>
#import <BraintreeCore/BraintreeCore.h>
#endif

NS_ASSUME_NONNULL_BEGIN

@interface BTPayPalRequest ()

- (NSDictionary<NSString *, NSObject *> *)parametersWithConfiguration:(BTConfiguration *)configuration  isBillingAgreement:(BOOL)isBillingAgreement;

@end

NS_ASSUME_NONNULL_END
