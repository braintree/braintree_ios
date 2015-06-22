#import <Foundation/Foundation.h>

#import "BTAPIResponseParser.h"
#import "BTPaymentMethod.h"
#import "BTCardPaymentMethod.h"
#import "BTPayPalPaymentMethod.h"
#import "BTApplePayPaymentMethod.h"

@interface BTClientPaymentMethodValueTransformer : NSObject <BTValueTransforming>

+ (instancetype)sharedInstance;

@end
