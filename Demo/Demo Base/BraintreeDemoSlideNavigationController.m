#import "BraintreeDemoSlideNavigationController.h"

@implementation BraintreeDemoSlideNavigationController

- (void)navigationController:(__unused UINavigationController *)navigationController
      willShowViewController:(__unused UIViewController *)viewController
                    animated:(__unused BOOL)animated
{}

- (void)setEnableShadow:(__unused BOOL)enable
{}

- (void)setEnableSwipeGesture:(__unused BOOL)markEnableSwipeGesture
{}

- (void)setDefaults {
    [super setEnableShadow:YES];
    [super setEnableSwipeGesture:YES];
}
@end
