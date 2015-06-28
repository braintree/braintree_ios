#import <PassKit/PassKit.h>

#import "BTNullability.h"
#import "BTConfiguration.h"
#import "BTTokenizedApplePayPaymentMethod.h"

BT_ASSUME_NONNULL_BEGIN

@interface BTApplePayTokenizationClient : NSObject

- (instancetype)initWithConfiguration:(BTConfiguration *)configuration;

- (void)tokenizeApplePayPayment:(PKPayment *)payment completion:(void (^)(BTTokenizedApplePayPaymentMethod __BT_NULLABLE *tokenizedApplePayPayment, NSError __BT_NULLABLE *error))completionBlock;

@end

BT_ASSUME_NONNULL_END
