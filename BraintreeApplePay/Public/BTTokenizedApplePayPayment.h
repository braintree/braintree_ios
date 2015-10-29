#import <Foundation/Foundation.h>
#if __has_include("BraintreeCore.h")
#import "BTPaymentMethodNonce.h"
#else
#import <BraintreeCore/BTPaymentMethodNonce.h>
#endif

NS_ASSUME_NONNULL_BEGIN

@interface BTTokenizedApplePayPayment : BTPaymentMethodNonce

- (instancetype)initWithPaymentMethodNonce:(NSString *)paymentMethodNonce
                               description:(NSString *)localizedDescription;

@end

NS_ASSUME_NONNULL_END
