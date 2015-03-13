#import "BraintreeDemoSettings.h"

NSString *BraintreeDemoSettingsEnvironmentDefaultsKey = @"BraintreeDemoSettingsEnvironmentDefaultsKey";
NSString *BraintreeDemoSettingsCustomEnvironmentURLDefaultsKey = @"BraintreeDemoSettingsCustomEnvironmentURLDefaultsKey";
NSString *BraintreeDemoSettingsThreeDSecureEnabledDefaultsKey = @"BraintreeDemoSettingsThreeDSecureEnabledDefaultsKey";
NSString *BraintreeDemoSettingsThreeDSecureRequiredDefaultsKey = @"BraintreeDemoSettingsThreeDSecureRequiredDefaultsKey";

@implementation BraintreeDemoSettings

+ (BraintreeDemoTransactionServiceEnvironment)currentEnvironment {
    return [[NSUserDefaults standardUserDefaults] integerForKey:BraintreeDemoSettingsEnvironmentDefaultsKey];
}

+ (NSString *)currentEnvironmentName {
    BraintreeDemoTransactionServiceEnvironment env = [self currentEnvironment];
    switch (env) {
        case BraintreeDemoTransactionServiceEnvironmentSandboxBraintreeSampleMerchant:
            return @"Sandbox";
        case BraintreeDemoTransactionServiceEnvironmentProductionExecutiveSampleMerchant:
            return @"Production";
        case BraintreeDemoTransactionServiceEnvironmentCustomMerchant: {
            NSString *shortTitle = [[NSUserDefaults standardUserDefaults] stringForKey:BraintreeDemoSettingsCustomEnvironmentURLDefaultsKey];
            shortTitle = [[shortTitle stringByReplacingOccurrencesOfString:@"http://" withString:@""] stringByReplacingOccurrencesOfString:@"https://" withString:@""];
            return shortTitle;
        }
    }
    return @"(invalid)";
}

+ (NSString *)currentEnvironmentURLString {
    switch ([self currentEnvironment]) {
        case BraintreeDemoTransactionServiceEnvironmentSandboxBraintreeSampleMerchant:
            return @"https://braintree-sample-merchant.herokuapp.com";
        case BraintreeDemoTransactionServiceEnvironmentProductionExecutiveSampleMerchant:
            return @"https://executive-sample-merchant.herokuapp.com";
        case BraintreeDemoTransactionServiceEnvironmentCustomMerchant:
            return [[NSUserDefaults standardUserDefaults] stringForKey:BraintreeDemoSettingsCustomEnvironmentURLDefaultsKey];
    }
}

+ (BOOL)threeDSecureEnabled {
    return [[NSUserDefaults standardUserDefaults] boolForKey:BraintreeDemoSettingsThreeDSecureEnabledDefaultsKey];
}

+ (BraintreeDemoTransactionServiceThreeDSecureRequiredStatus)threeDSecureRequiredStatus {
    return [[NSUserDefaults standardUserDefaults] integerForKey:BraintreeDemoSettingsThreeDSecureRequiredDefaultsKey];
}

@end
