#if __has_include(<Braintree/BraintreeCore.h>)
#import <Braintree/BTPreferredPaymentMethods.h>
#else
#import <BraintreeCore/BTPreferredPaymentMethods.h>
#endif

NS_ASSUME_NONNULL_BEGIN

@interface BTPreferredPaymentMethods ()

@property(nonatomic, strong) id application;

@end

NS_ASSUME_NONNULL_END
