#import "BraintreeDemoAppDelegate.h"
#import "BraintreeDemoContainmentViewController.h"

#import "Demo-Swift.h"

NSString *BraintreeDemoAppDelegatePaymentsURLScheme = @"com.braintreepayments.Demo.payments";

@implementation BraintreeDemoAppDelegate

- (BOOL)application:(__unused UIApplication *)application didFinishLaunchingWithOptions:(__unused NSDictionary *)launchOptions {
    [self setupAppearance];
    [self registerDefaultsFromSettings];

    [BTAppContextSwitcher setReturnURLScheme:BraintreeDemoAppDelegatePaymentsURLScheme];

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:YES forKey:@"magnes.debug.mode"];

    if (@available(iOS 13, *)) {
        // handled by scene delegate
    } else {
        BraintreeDemoContainmentViewController *rootViewController = [[BraintreeDemoContainmentViewController alloc] init];
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:rootViewController];
        self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        self.window.rootViewController = navigationController;
        [self.window makeKeyAndVisible];
    }

    return YES;
}

- (BOOL)application:(__unused UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString *,id> *)options {
    if (@available(iOS 13, *)) {
        // handled by scene delegate
    } else {
        if ([[url.scheme lowercaseString] isEqualToString:[BraintreeDemoAppDelegatePaymentsURLScheme lowercaseString]]) {
            return [BTAppContextSwitcher handleOpenURL:url];
        }
    }
    return YES;
}

- (void)setupAppearance {
    UIColor *pleasantGray = [UIColor colorWithWhite:42/255.0f alpha:1.0f];

    [[UIToolbar appearance] setBarTintColor:pleasantGray];
    [[UIToolbar appearance] setBarStyle:UIBarStyleBlack];
    [[UIToolbar appearance] setTranslucent:YES];
}

- (void)registerDefaultsFromSettings {
    // Check for testing arguments
    if ([[[NSProcessInfo processInfo] arguments] containsObject:@"-EnvironmentSandbox"]) {
        [[NSUserDefaults standardUserDefaults] setInteger:BraintreeDemoEnvironmentSandbox forKey:BraintreeDemoSettings.EnvironmentDefaultsKey];
    }else if ([[[NSProcessInfo processInfo] arguments] containsObject:@"-EnvironmentProduction"]) {
        [[NSUserDefaults standardUserDefaults] setInteger:BraintreeDemoEnvironmentProduction forKey:BraintreeDemoSettings.EnvironmentDefaultsKey];
    }

    if ([[[NSProcessInfo processInfo] arguments] containsObject:@"-ClientToken"]) {
        [[NSUserDefaults standardUserDefaults] setInteger:BraintreeDemoAuthTypeClientToken forKey:BraintreeDemoSettings.AuthorizationTypeDefaultsKey];
    }else if ([[[NSProcessInfo processInfo] arguments] containsObject:@"-TokenizationKey"]) {
        [[NSUserDefaults standardUserDefaults] setInteger:BraintreeDemoAuthTypeTokenizationKey forKey:BraintreeDemoSettings.AuthorizationTypeDefaultsKey];
    }
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"BraintreeDemoSettingsAuthorizationOverride"];
    for (NSString* arg in [[NSProcessInfo processInfo] arguments]) {
        if ([arg rangeOfString:@"-Integration:"].location != NSNotFound) {
            NSString* testIntegration = [arg stringByReplacingOccurrencesOfString:@"-Integration:" withString:@""];
            [[NSUserDefaults standardUserDefaults] setObject:testIntegration forKey:@"BraintreeDemoSettingsIntegration"];
        } else if ([arg rangeOfString:@"-Authorization:"].location != NSNotFound) {
            NSString* testIntegration = [arg stringByReplacingOccurrencesOfString:@"-Authorization:" withString:@""];
            [[NSUserDefaults standardUserDefaults] setObject:testIntegration forKey:@"BraintreeDemoSettingsAuthorizationOverride"];
        }
    }
    
    if ([[[NSProcessInfo processInfo] arguments] containsObject:@"-ClientTokenVersion2"]) {
        [[NSUserDefaults standardUserDefaults] setObject:@"2" forKey:@"BraintreeDemoSettingsClientTokenVersionDefaultsKey"];
    }else if ([[[NSProcessInfo processInfo] arguments] containsObject:@"-ClientTokenVersion3"]) {
        [[NSUserDefaults standardUserDefaults] setObject:@"3" forKey:@"BraintreeDemoSettingsClientTokenVersionDefaultsKey"];
    }
    // End checking for testing arguments
    
    
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

#pragma mark - UISceneSession lifecycle


- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options  API_AVAILABLE(ios(13.0)) {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}

@end
