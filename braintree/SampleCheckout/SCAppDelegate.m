#import "SCAppDelegate.h"

#import "SCViewController.h"
#import <VenmoTouch/VenmoTouch.h> // Don't forget to import VenmoTouch

@implementation SCAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        self.viewController = [[SCViewController alloc] initWithNibName:@"SCViewController_iPhone" bundle:nil];
    } else {
        self.viewController = [[SCViewController alloc] initWithNibName:@"SCViewController_iPad" bundle:nil];
    }
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    [self initVTClient];
    return YES;
}

#pragma mark - VenmoTouch
// Initialize a VTClient with your correct merchant settings.
// Don't forget to add some logic to toggle whether you are using Sandbox or Production merchant settings.

// Use the following implementation in your production and sandbox testing environments.
// Edit VenmoTouchSettings.h to set your own merchant credentials, like BT_SANDBOX_MERCHANT_ID.
/*
- (void) initVTClient {
    if ([BT_ENVIRONMENT isEqualToString:@"sandbox"]) {
        NSLog(@"sandbox environment, merchant_id %@", BT_SANDBOX_MERCHANT_ID);
        [VTClient
         startWithMerchantID:BT_SANDBOX_MERCHANT_ID
         customerEmail:nil
         braintreeClientSideEncryptionKey:BT_SANDBOX_CLIENT_SIDE_ENCRYPTION_KEY
         environment:VTEnvironmentSandbox];
    } else {
        NSLog(@"production environment, merchant_id %@", BT_PRODUCTION_MERCHANT_ID);
        [VTClient
         startWithMerchantID:BT_PRODUCTION_MERCHANT_ID
         customerEmail:nil
         braintreeClientSideEncryptionKey:BT_PRODUCTION_CLIENT_SIDE_ENCRYPTION_KEY
         environment:VTEnvironmentSandbox];
    }
}
 */

// This implementation is used strictly for demo purposes with SampleCheckout. Use the above
// implementation in your code.
- (void) initVTClient {

    NSString *braintreeMerchantID = @"t34jgpz7ktn4rsfm";
    NSString *braintreeClientSideEncryptionKey = @"MIIBCgKCAQEA7zuPxt75mzMTfMqHb/1p/FOtdanLmN/GuGMDPGhz/t3ZaGZuI4BLpVPFTFwe086vMTMPh2NGpF6CZ6aPV3n3m5HoEm++yGTFE9/6n863gl4aszrJNWRWB68lYxB27fqDyk9QGBS95Kb03cieQbtqYS25zbc7P2XEOHv+XfypC5YjVMdTZjq1zzQ6wg6NZ7mpGCChhznjFXqm2uh3qM7MX0CsowWRFBHjTiJoRgTuNHwKp6mC3i8UDd1zJws94Oo87vpNVnFKVP2uqRyYrF4rlEw7CCDG8/llPDpK2ADBFBWyPK49F/8U5NZPLS7DqtuBN7Oq18SpcXczrcP1ZhBJSwIDAQAB";

    NSLog(@"SampleCheckout is running the *SANDBOX* environment");
    [VTClient
     startWithMerchantID:braintreeMerchantID
     customerEmail:nil
     braintreeClientSideEncryptionKey:braintreeClientSideEncryptionKey
     environment:VTEnvironmentSandbox];
}

@end
