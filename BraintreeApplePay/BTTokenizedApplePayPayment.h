#import <Foundation/Foundation.h>
#import "BTNullability.h"
#import "BTTokenized.h"

BT_ASSUME_NONNULL_BEGIN

@interface BTTokenizedApplePayPayment : NSObject <BTTokenized>

- (instancetype)initWithPaymentMethodNonce:(NSString *)paymentMethodNonce
                               description:(NSString *)localizedDescription;

@end

BT_ASSUME_NONNULL_END
