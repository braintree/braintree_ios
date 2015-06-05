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

    self.title = @"Drop In";

    UIButton *dropInButton = [UIButton buttonWithType:UIButtonTypeSystem];
    dropInButton.translatesAutoresizingMaskIntoConstraints = NO;
    [dropInButton addTarget:self action:@selector(tappedToShowDropIn) forControlEvents:UIControlEventTouchUpInside];
    [dropInButton setBackgroundColor:[UIColor purpleColor]];
    [dropInButton setTitleColor:[UIColor whiteColor]forState:UIControlStateNormal];
    dropInButton.layer.cornerRadius = 5.0f;
    dropInButton.contentEdgeInsets = UIEdgeInsetsMake(8, 8, 8, 8);
    [dropInButton setTitle:@"Buy Now" forState:UIControlStateNormal];
    [dropInButton sizeToFit];

    [self.view addSubview:dropInButton];
    [dropInButton autoCenterInSuperview];

    self.progressBlock(@"Ready to present Drop In");
}

- (void)tappedToShowDropIn {
    BTDropInViewController *dropIn = [self.braintree dropInViewControllerWithDelegate:self];
    dropIn.title = @"Check Out";
    dropIn.summaryTitle = @"Our Fancy Magazine";
    dropIn.summaryDescription = @"53 Week Subscription";
    dropIn.displayAmount = @"$19.00";
    dropIn.callToActionText = @"$19 - Subscribe Now";
    dropIn.shouldHideCallToAction = NO;

    if ([BraintreeDemoSettings useModalPresentation]) {
        self.progressBlock(@"Presenting Drop In Modally");
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
