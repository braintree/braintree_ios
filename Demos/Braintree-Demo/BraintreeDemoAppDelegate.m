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

    [self setupAppearance];

    NSString *paymentsURLScheme = @"com.braintreepayments.Braintree-Demo.payments";
    [Braintree setReturnURLScheme:paymentsURLScheme];

    return YES;
}


- (BOOL)application:(UIApplication *)__unused application openURL:(NSURL *)url  sourceApplication:(NSString *)sourceApplication annotation:(id)__unused annotation{
    if ([url.scheme isEqualToString:BraintreeDemoAppDelegatePaymentsURLScheme]) {
        return [Braintree handleOpenURL:url sourceApplication:sourceApplication];
    }
    return YES;
}

- (void)setupAppearance {
    UIColor *pleasantGray = [UIColor colorWithWhite:42/255.0f alpha:1.0f];

    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setBarTintColor:pleasantGray];
    [[UINavigationBar appearance] setBarStyle:UIBarStyleBlack];
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
