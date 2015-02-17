#if BT_ENABLE_APPLE_PAY
@import Foundation;
@import PassKit;

#import "BTAPIResponseParser.h"

@interface BTClientTokenApplePayPaymentNetworksValueTransformer : NSObject <BTValueTransforming>

+ (instancetype)sharedInstance;

@end
#endif
