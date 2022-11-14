#if __has_include(<Braintree/BraintreePayPal.h>)
#import <Braintree/BTPayPalRequest.h>
#else
#import <BraintreePayPal/BTPayPalRequest.h>
#endif

NS_ASSUME_NONNULL_BEGIN

@class BTConfiguration;

extern NSString *const BTPayPalCallbackURLHostAndPath;
extern NSString *const BTPayPalCallbackURLScheme;

@interface BTPayPalRequest ()

@property (nonatomic, nullable, copy, readonly) NSString *landingPageTypeAsString;
@property (nonatomic, nullable, copy, readonly) NSString *hermesPath;
@property (nonatomic, readonly) BTPayPalPaymentType paymentType;

- (NSDictionary<NSString *, NSObject *> *)parametersWithConfiguration:(BTConfiguration *)configuration;

@end

NS_ASSUME_NONNULL_END
