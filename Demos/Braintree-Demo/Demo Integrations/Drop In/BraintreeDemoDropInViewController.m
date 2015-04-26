#import "BraintreeDemoDropInViewController.h"

#import <PureLayout/PureLayout.h>
#import <Braintree/Braintree.h>

#import "BraintreeDemoSettings.h"

@interface BraintreeDemoDropInViewController () <BTDropInViewControllerDelegate>

@property (nonatomic, strong) Braintree *braintree;

@end

@implementation BraintreeDemoDropInViewController

- (instancetype)initWithClientToken:(NSString *)clientToken {
    self = [super initWithClientToken:clientToken];
    if (self) {
        self.braintree = [Braintree braintreeWithClientToken:clientToken];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    UIButton *dropInButton = [UIButton buttonWithType:UIButtonTypeSystem];
    dropInButton.translatesAutoresizingMaskIntoConstraints = NO;
    [dropInButton addTarget:self action:@selector(tappedToShowDropIn) forControlEvents:UIControlEventTouchUpInside];
    [dropInButton setTitle:@"Present Drop In" forState:UIControlStateNormal];

    [self.view addSubview:dropInButton];
    [dropInButton autoCenterInSuperview];

    self.progressBlock(@"Ready to present Drop In");
}

- (void)tappedToShowDropIn {
    BTDropInViewController *dropIn = [self.braintree dropInViewControllerWithDelegate:self];

    if ([BraintreeDemoSettings useModalPresentation]) {
        self.progressBlock(@"Presenting Drop In Modally");
        dropIn.title = @"Drop In";
        dropIn.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(tappedCancel)];
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:dropIn];
        [self presentViewController:nav animated:YES completion:nil];
    } else {
        self.progressBlock(@"Pushing Drop In on nav stack");
        [self.navigationController pushViewController:dropIn animated:YES];
    }
}


- (void)tappedCancel {
    self.progressBlock(@"Dismissing Drop In");
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - BTDropInViewControllerDelegate

- (void)dropInViewController:(BTDropInViewController *)viewController didSucceedWithPaymentMethod:(BTPaymentMethod *)paymentMethod {
    if ([BraintreeDemoSettings useModalPresentation]) {
        [viewController dismissViewControllerAnimated:YES completion:^{
            self.completionBlock(paymentMethod);
        }];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)dropInViewControllerWillComplete:(__unused BTDropInViewController *)viewController {
    self.progressBlock(@"Drop In Will Complete");
}

- (void)dropInViewControllerDidCancel:(BTDropInViewController *)viewController {
    self.progressBlock(@"User Canceled Drop In");
    [viewController dismissViewControllerAnimated:YES completion:nil];
}

@end
