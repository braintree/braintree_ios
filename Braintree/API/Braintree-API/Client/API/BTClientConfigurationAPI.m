#import "BTClientConfigurationAPI.h"
#import "BTClientConfiguration.h"

@interface BTClientApplePayConfigurationAPI : BTAPIResource

@end

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

