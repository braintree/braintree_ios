#import "BraintreeDemoSceneDelegate.h"
#import "BraintreeDemoContainmentViewController.h"

#import "Demo-Swift.h"

@implementation BraintreeDemoSceneDelegate

- (void)scene:(UIScene *)scene willConnectToSession:(UISceneSession *)session options:(UISceneConnectionOptions *)connectionOptions  API_AVAILABLE(ios(13.0)) {
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

- (void)scene:(UIScene *)scene openURLContexts:(NSSet<UIOpenURLContext *> *)URLContexts  API_AVAILABLE(ios(13.0)) {
    for (UIOpenURLContext *urlContext in URLContexts) {
        NSURL *url = [urlContext URL];
        if ([url.scheme localizedCaseInsensitiveCompare:@"com.braintreepayments.Demo.payments"] == NSOrderedSame) {
            [BTAppContextSwitcher handleOpenURLContext:urlContext];
        }
    }
}

@end
