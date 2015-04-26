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

+ (BOOL)useModalPresentation {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"BraintreeDemoChooserViewControllerShouldUseModalPresentationDefaultsKey"];
}


+ (BOOL)customerPresent {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"BraintreeDemoCustomerPresent"];
}

+ (NSString *)customerIdentifier {
    return [[NSUserDefaults standardUserDefaults] stringForKey:@"BraintreeDemoCustomerIdentifier"];
}

@end
