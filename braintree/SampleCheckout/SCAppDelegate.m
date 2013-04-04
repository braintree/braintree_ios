//
//  SCAppDelegate.m
//  SampleCheckout
//
//  Created by kortina on 3/28/13.
//  Copyright (c) 2013 Braintree. All rights reserved.
//

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

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - VenmoTouch
// Initialize a VTClient with your correct merchant settings.
// Don't forget to add some logic to toggle whether you are using Sandbox or Production merchant settings.
- (void) initVTClient {
    if ([BT_ENVIRONMENT isEqualToString:@"sandbox"]) {
        NSLog(@"sandbox environment, merchant_id %@", BT_SANDBOX_MERCHANT_ID);
        [VTClient
         startWithMerchantID:BT_SANDBOX_MERCHANT_ID
         braintreeClientSideEncryptionKey:BT_SANDBOX_CLIENT_SIDE_ENCRYPTION_KEY
         environment:VTEnvironmentSandbox];
    } else {
        NSLog(@"production environment, merchant_id %@", BT_PRODUCTION_MERCHANT_ID);
        [VTClient
         startWithMerchantID:BT_PRODUCTION_MERCHANT_ID
         braintreeClientSideEncryptionKey:BT_PRODUCTION_CLIENT_SIDE_ENCRYPTION_KEY
         environment:VTEnvironmentSandbox];
    }
}

@end
