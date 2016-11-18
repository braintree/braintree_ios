#import "BTCoreUtils.h"

@implementation BTCoreUtils

+ (UIViewController *)topViewController {
    UIApplication *sharedApplication = [UIApplication performSelector:@selector(sharedApplication)];
    UIViewController *topViewController = sharedApplication.keyWindow.rootViewController;

    while (topViewController.presentedViewController) {
        topViewController = topViewController.presentedViewController;
    }
    return topViewController;
}

@end
