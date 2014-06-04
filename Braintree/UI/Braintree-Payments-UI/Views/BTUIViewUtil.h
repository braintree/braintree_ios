#import <UIKit/UIKit.h>

#import "BTUICardType.h"
#import "BTUIPaymentMethodType.h"

/// Utilities used by other views
@interface BTUIViewUtil : NSObject

+ (BTUIPaymentMethodType)paymentMethodTypeForCardType:(BTUICardType *)cardType;

+ (void)vibrate;

@end
