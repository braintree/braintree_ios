#import "BraintreeDemoAppDelegate.h"
#import <HockeySDK/HockeySDK.h>
#import "BraintreeAppSwitchAuthResponse.h"
#import "Braintree.h"

#import <Braintree/BTAppSwitchHandler.h>

@implementation BraintreeDemoAppDelegate

- (BOOL)application:(__unused UIApplication *)application didFinishLaunchingWithOptions:(__unused NSDictionary *)launchOptions {
    [[BITHockeyManager sharedHockeyManager] configureWithIdentifier:@"7134982f3df6419a0eb52b16e7d6d175"];
    [[BITHockeyManager sharedHockeyManager] startManager];
    [[BITHockeyManager sharedHockeyManager].authenticator authenticateInstallation];

    //Braintree Orange
    self.window.tintColor = [UIColor colorWithRed:255/255.0f green:136/255.0f blue:51/255.0f alpha:1.0f];

    [[BTAppSwitchHandler sharedHandler] setAppSwitchCallbackURLScheme:@"com.braintreepayments.Braintree-Demo.payments"];

    return YES;
}


- (BOOL)application:(UIApplication *)__unused application openURL:(NSURL *)url  sourceApplication:(NSString *)sourceApplication annotation:(id)__unused annotation{
    return [Braintree handleOpenURL:url sourceApplication:sourceApplication];
}

@end
