#import "BraintreeDemoSceneDelegate.h"
#import "BraintreeDemoContainmentViewController.h"

#import "Demo-Swift.h"

// Swift Module Imports
#if __has_include(<Braintree/Braintree-Swift.h>) // Cocoapods-generated Swift Header
#import <Braintree/Braintree-Swift.h>

#elif SWIFT_PACKAGE                              // SPM
/* Use @import for SPM support
 * See https://forums.swift.org/t/using-a-swift-package-in-a-mixed-swift-and-objective-c-project/27348
 */
@import BraintreeCoreSwift;

#elif __has_include("Braintree-Swift.h")         // CocoaPods for ReactNative
/* Use quoted style when importing Swift headers for ReactNative support
 * See https://github.com/braintree/braintree_ios/issues/671
 */
#import "Braintree-Swift.h"

#else // Carthage or Local Builds
#import <BraintreeCoreSwift/BraintreeCoreSwift-Swift.h>
#endif

@implementation BraintreeDemoSceneDelegate

- (void)scene:(UIScene *)scene willConnectToSession:(UISceneSession *)session options:(UISceneConnectionOptions *)connectionOptions {
    // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
    // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
    // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
    
    UIWindowScene *windowScene = (UIWindowScene *)scene;
    if (windowScene) {
        self.window = [[UIWindow alloc] initWithWindowScene:windowScene];
        BraintreeDemoContainmentViewController *rootViewController = [[BraintreeDemoContainmentViewController alloc] init];
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:rootViewController];
        self.window.rootViewController = navigationController;
        [self.window makeKeyAndVisible];
    }
}

- (void)scene:(UIScene *)scene openURLContexts:(NSSet<UIOpenURLContext *> *)URLContexts {
    for (UIOpenURLContext *urlContext in URLContexts) {
        NSURL *url = [urlContext URL];
        if ([url.scheme localizedCaseInsensitiveCompare:@"com.braintreepayments.Demo.payments"] == NSOrderedSame) {
            [[BTAppContextSwitcher sharedInstance] handleOpenURLContext:urlContext];
        }
    }
}

@end
