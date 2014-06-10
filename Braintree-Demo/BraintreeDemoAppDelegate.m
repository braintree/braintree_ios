#import "BraintreeDemoAppDelegate.h"
#import <HockeySDK/HockeySDK.h>

@implementation BraintreeDemoAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [[BITHockeyManager sharedHockeyManager] configureWithIdentifier:@"7134982f3df6419a0eb52b16e7d6d175"];
    [[BITHockeyManager sharedHockeyManager] startManager];
    [[BITHockeyManager sharedHockeyManager].authenticator authenticateInstallation];

    self.window.tintColor = [UIColor redColor];

    return YES;
}

@end
