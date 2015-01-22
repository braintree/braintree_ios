#import "BraintreeDemoSettings.h"

NSString *BraintreeDemoSettingsEnvironmentDefaultsKey = @"BraintreeDemoSettingsEnvironmentDefaultsKey";
NSString *BraintreeDemoSettingsThreeDSecureEnabledDefaultsKey = @"BraintreeDemoSettingsThreeDSecureEnabledDefaultsKey";
NSString *BraintreeDemoSettingsThreeDSecureRequiredDefaultsKey = @"BraintreeDemoSettingsThreeDSecureRequiredDefaultsKey";

@implementation BraintreeDemoSettings

+ (BraintreeDemoTransactionServiceEnvironment)currentEnvironment {
    return [[NSUserDefaults standardUserDefaults] integerForKey:BraintreeDemoSettingsEnvironmentDefaultsKey];
}

+ (BOOL)threeDSecureEnabled {
    return [[NSUserDefaults standardUserDefaults] boolForKey:BraintreeDemoSettingsThreeDSecureEnabledDefaultsKey];
}

+ (BraintreeDemoTransactionServiceThreeDSecureRequiredStatus)threeDSecureRequiredStatus {
    return [[NSUserDefaults standardUserDefaults] integerForKey:BraintreeDemoSettingsThreeDSecureRequiredDefaultsKey];
}

@end
