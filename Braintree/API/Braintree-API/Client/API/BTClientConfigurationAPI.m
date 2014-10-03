#import "BTClientConfigurationAPI.h"
#import "BTClientConfiguration.h"
#import "BTClientApplePayConfigurationAPI.h"

@implementation BTClientConfigurationAPI

+ (Class)resourceModelClass {
    return [BTClientConfiguration class];
}

+ (NSDictionary *)APIFormat {
    return @{
             @"applePay": BTAPIResourceValueTypeOptional(BTAPIResourceValueTypeAPIResource(@selector(setApplePayConfiguration:), [BTClientApplePayConfigurationAPI class]))
             };
}

@end

