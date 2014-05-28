#import "BTCardPaymentMethod.h"
#import "BTUIPaymentMethodType.h"

@interface BTDropInUtil : NSObject

+ (BTUIPaymentMethodType)uiForCardType:(BTCardType)cardType;

@end
