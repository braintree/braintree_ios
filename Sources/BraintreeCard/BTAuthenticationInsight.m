#import "BraintreeCore/BraintreeCore-Swift.h"
#import "BTAuthenticationInsight_Internal.h"

@implementation BTAuthenticationInsight

- (instancetype)initWithJSON:(BTJSON *)json {
    if (self = [super init]) {
        NSString *regulationEnvironment;
        
        if ([json[@"customerAuthenticationRegulationEnvironment"] asString]) {
            regulationEnvironment = [json[@"customerAuthenticationRegulationEnvironment"] asString];
        } else if ([json[@"regulationEnvironment"] asString]) {
            regulationEnvironment = [json[@"regulationEnvironment"] asString];
        }
        
        // GraphQL returns "PSDTWO" instead of "psd2"
        if ([regulationEnvironment isEqualToString:@"PSDTWO"]) {
            regulationEnvironment = @"psd2";
        }
        
        if (regulationEnvironment) {
            regulationEnvironment = regulationEnvironment.lowercaseString;
        }
        
        _regulationEnvironment = regulationEnvironment;
    }
    return self;
}

@end
