#import "BraintreeDemoAppDelegate.h"
#import <HockeySDK/HockeySDK.h>
#import "Braintree.h"

#if DEBUG
#import <FLEX/FLEXManager.h>
#endif

NSString *BraintreeDemoAppDelegatePaymentsURLScheme = @"com.braintreepayments.Braintree-Demo.payments";

@implementation BraintreeDemoAppDelegate

- (BOOL)application:(__unused UIApplication *)application didFinishLaunchingWithOptions:(__unused NSDictionary *)launchOptions {
    [[BITHockeyManager sharedHockeyManager] configureWithIdentifier:@"7134982f3df6419a0eb52b16e7d6d175"];
    [[BITHockeyManager sharedHockeyManager] startManager];
    [[BITHockeyManager sharedHockeyManager].authenticator authenticateInstallation];
    if ([[[NSProcessInfo processInfo] arguments] containsObject:@"-disableUpdateCheck"]) {
      [[BITHockeyManager sharedHockeyManager] updateManager].checkForUpdateOnLaunch = NO;
    }
    [[BITHockeyManager sharedHockeyManager] updateManager].updateSetting = BITUpdateCheckDaily;
    
    [self setupAppearance];
    [self registerDefaultsFromSettings];

    [Braintree setReturnURLScheme:BraintreeDemoAppDelegatePaymentsURLScheme];

    return YES;
}

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 90000
- (BOOL)application:(__unused UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString *,id> *)options {
    if ([[url.scheme lowercaseString] isEqualToString:[BraintreeDemoAppDelegatePaymentsURLScheme lowercaseString]]) {
        return [Braintree handleOpenURL:url sourceApplication:options[UIApplicationOpenURLOptionsSourceApplicationKey]];
    }
    return YES;
}
#endif

// Deprecated in iOS 9, but necessary to support < versions
- (BOOL)application:(__unused UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(__unused id)annotation {
    if ([[url.scheme lowercaseString] isEqualToString:[BraintreeDemoAppDelegatePaymentsURLScheme lowercaseString]]) {
        return [Braintree handleOpenURL:url sourceApplication:sourceApplication];
    }
    return YES;
}

- (void)setupAppearance {
    UIColor *pleasantGray = [UIColor colorWithWhite:42/255.0f alpha:1.0f];

    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setBarTintColor:pleasantGray];
    [[UINavigationBar appearance] setBarStyle:UIBarStyleBlackTranslucent];

    [[UIToolbar appearance] setTintColor:[UIColor whiteColor]];
    [[UIToolbar appearance] setBarTintColor:pleasantGray];
    [[UIToolbar appearance] setBarStyle:UIBarStyleBlackTranslucent];
}

- (void)registerDefaultsFromSettings {
    NSString *settingsBundle = [[NSBundle mainBundle] pathForResource:@"Settings" ofType:@"bundle"];
    if(!settingsBundle) {
        NSLog(@"Could not find Settings.bundle");
        return;
    }
    
    NSDictionary *settings = [NSDictionary dictionaryWithContentsOfFile:[settingsBundle stringByAppendingPathComponent:@"Root.plist"]];
    NSArray *preferences = [settings objectForKey:@"PreferenceSpecifiers"];
    
    NSMutableDictionary *defaultsToRegister = [[NSMutableDictionary alloc] initWithCapacity:[preferences count]];
    for (NSDictionary *prefSpecification in preferences) {
        NSString *key = [prefSpecification objectForKey:@"Key"];
        if(key && [[prefSpecification allKeys] containsObject:@"DefaultValue"]) {
            [defaultsToRegister setObject:[prefSpecification objectForKey:@"DefaultValue"] forKey:key];
        }
    }
    
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaultsToRegister];
}


#if DEBUG
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    CGPoint location = [[[event allTouches] anyObject] locationInView:[self window]];
    if(location.y > 0 && location.y < [[UIApplication sharedApplication] statusBarFrame].size.height) {
        [[FLEXManager sharedManager] showExplorer];
    }
}
#endif

@end
