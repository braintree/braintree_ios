#import <UIKit/UIKit.h>

#import "BTUICardType.h"
#import "BTUIPaymentMethodType.h"

/// Utilities used by other views
@interface BTUIViewUtil : NSObject

+ (BTUIPaymentMethodType)paymentMethodTypeForCardType:(BTUICardType *)cardType;
+ (NSString *)nameForPaymentMethodType:(BTUIPaymentMethodType)paymentMethodType;

+ (void)vibrate;

@end
