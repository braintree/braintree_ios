#if __has_include(<Braintree/BraintreePayPal.h>)
#import <Braintree/BTPayPalRequest.h>
#import <Braintree/BraintreeCore.h>
#else
#import <BraintreePayPal/BTPayPalRequest.h>
#import <BraintreeCore/BraintreeCore.h>
#endif

NS_ASSUME_NONNULL_BEGIN

extern NSString *const BTPayPalCallbackURLHostAndPath;
extern NSString *const BTPayPalCallbackURLScheme;

@interface BTPayPalRequest ()

@property (nonatomic, nullable, copy, readonly) NSString *landingPageTypeAsString;

- (NSDictionary<NSString *, NSObject *> *)parametersWithConfiguration:(BTConfiguration *)configuration  isBillingAgreement:(BOOL)isBillingAgreement;

@end

NS_ASSUME_NONNULL_END
