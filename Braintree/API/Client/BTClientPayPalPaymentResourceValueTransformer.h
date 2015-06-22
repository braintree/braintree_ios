@import Foundation;

#import "BTAPIResponseParser.h"
#import "BTClientPayPalPaymentResource.h"

@interface BTClientPayPalPaymentResourceValueTransformer : NSObject <BTValueTransforming>

+ (instancetype)sharedInstance;

@end
