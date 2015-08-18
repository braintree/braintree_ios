#import <BraintreeCard/BTTokenizedCard.h>
#import "BTUIPaymentOptionType.h"

@interface BTDropInUtil : NSObject

+ (BTUIPaymentOptionType)uiForCardNetwork:(BTCardNetwork)cardNetwork;

@end
