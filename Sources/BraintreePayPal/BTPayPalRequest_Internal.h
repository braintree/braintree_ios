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

typedef NS_ENUM(NSUInteger, BTPayPalPaymentType) {
    BTPayPalPaymentTypeCheckout,
    BTPayPalPaymentTypeVault
};

@interface BTPayPalRequest ()

@property (nonatomic, nullable, copy, readonly) NSString *landingPageTypeAsString;
@property (nonatomic, nullable, copy, readonly) NSString *hermesPath;
@property (nonatomic, readonly) BTPayPalPaymentType paymentType;

- (NSDictionary<NSString *, NSObject *> *)parametersWithConfiguration:(BTConfiguration *)configuration;

@end

NS_ASSUME_NONNULL_END
