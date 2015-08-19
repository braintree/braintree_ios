#if BT_ENABLE_APPLE_PAY
#import <Foundation/Foundation.h>
@import PassKit;

#import "BTAPIResponseParser.h"

@interface BTClientTokenApplePayPaymentNetworksValueTransformer : NSObject <BTValueTransforming>

+ (instancetype)sharedInstance;

@end
#endif
