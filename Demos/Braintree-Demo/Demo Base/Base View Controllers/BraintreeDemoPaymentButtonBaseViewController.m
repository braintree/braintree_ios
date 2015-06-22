#import "Braintree.h"
#import "BraintreeDemoBTPaymentButtonViewController.h"
#import <PureLayout/ALView+PureLayout.h>
#import "BraintreeDemoPaymentButtonBaseViewController.h"


@implementation BraintreeDemoPaymentButtonBaseViewController

- (instancetype)initWithClientToken:(NSString *)clientToken {
    self = [super initWithClientToken:clientToken];
    if (self) {
        self.braintree = [Braintree braintreeWithClientToken:clientToken];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"Payment Button";

    [self.view setBackgroundColor:[UIColor colorWithRed:250.0f/255.0f green:253.0f/255.0f blue:255.0f/255.0f alpha:1.0f]];

    UIView *paymentButton = [self paymentButton];
    [self.view addSubview:paymentButton];

    [paymentButton autoCenterInSuperviewMargins];
    [paymentButton autoPinEdgeToSuperviewEdge:ALEdgeLeading];
    [paymentButton autoPinEdgeToSuperviewEdge:ALEdgeTrailing];
    [paymentButton autoSetDimension:ALDimensionHeight toSize:44 relation:NSLayoutRelationGreaterThanOrEqual];
}

- (UIView *)paymentButton {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:@"Subclasses of BraintreeDemoPaymentButtonViewController must override paymentButton. BraintreeDemoPaymentButtonViewController should not be initialized directly."
                                 userInfo:nil];
}


#pragma mark BTPaymentMethodCreationDelegate

- (void)paymentMethodCreator:(__unused id)sender requestsPresentationOfViewController:(UIViewController *)viewController {
    self.progressBlock([NSString stringWithFormat:@"Presenting View Controller: %@", viewController]);
    [self presentViewController:viewController animated:YES completion:nil];
}

- (void)paymentMethodCreator:(__unused id)sender requestsDismissalOfViewController:(UIViewController *)viewController {
    self.progressBlock([NSString stringWithFormat:@"Dismissing View Controller: %@", viewController]);
    [viewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)paymentMethodCreatorWillPerformAppSwitch:(__unused id)sender {
    self.progressBlock(@"Will Perform App Switch");
}

- (void)paymentMethodCreatorWillProcess:(__unused id)sender {
    self.progressBlock(@"Will Process");
}

- (void)paymentMethodCreatorDidCancel:(__unused id)sender {
    self.progressBlock(@"Canceled 🔰");
}

- (void)paymentMethodCreator:(__unused id)sender didCreatePaymentMethod:(BTPaymentMethod *)paymentMethod {
    self.progressBlock(@"Got a nonce 💎!");
    NSLog(@"%@", [paymentMethod debugDescription]);
    self.completionBlock(paymentMethod);
}

- (void)paymentMethodCreator:(__unused id)sender didFailWithError:(NSError *)error {
    self.progressBlock(error.localizedDescription);
}

@end

