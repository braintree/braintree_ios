#import <Foundation/Foundation.h>
#if __has_include("BraintreeCore.h")
#import "BTTokenized.h"
#else
#import <BraintreeCore/BTTokenized.h>
#endif

NS_ASSUME_NONNULL_BEGIN

@interface BTTokenizedApplePayPayment : NSObject <BTTokenized>

- (instancetype)initWithPaymentMethodNonce:(NSString *)paymentMethodNonce
                               description:(NSString *)localizedDescription;

@end

NS_ASSUME_NONNULL_END
