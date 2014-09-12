#import "BTMockApplePayPaymentAuthorizationViewController.h"

#import "BTMockApplePayPaymentAuthorizationView.h"

@interface BTMockApplePayPaymentAuthorizationViewController () <BTMockApplePayPaymentAuthorizationViewDelegate>

@end

@implementation BTMockApplePayPaymentAuthorizationViewController

- (instancetype)initWithPaymentRequest:(PKPaymentRequest *)request {
    self = [super init];
    if (self) {
        NSLog(@"Request: %@; items: %@", request.merchantIdentifier, request.paymentSummaryItems);
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    BTMockApplePayPaymentAuthorizationView *authorizationView = [[BTMockApplePayPaymentAuthorizationView alloc] initWithDelegate:self];
    authorizationView.translatesAutoresizingMaskIntoConstraints = NO;

    [self.view addSubview:authorizationView];

    NSDictionary *views = @{ @"authorizationView": authorizationView };
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[authorizationView]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[authorizationView]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:views]];
}

- (void)cancel:(__unused id)sender {
    [self.delegate mockApplePayPaymentAuthorizationViewControllerDidFinish:self];
}

#pragma mark Mock Payment Authorization View Delegate

- (void)mockApplePayPaymentAuthorizationViewDidCancel:(__unused BTMockApplePayPaymentAuthorizationView *)view {
    [self.delegate mockApplePayPaymentAuthorizationViewControllerDidFinish:self];
}

- (void)mockApplePayPaymentAuthorizationViewDidSucceed:(__unused BTMockApplePayPaymentAuthorizationView *)view {
    [self.delegate mockApplePayPaymentAuthorizationViewController:self
                                             didAuthorizePayment:nil
                                                      completion:^(__unused PKPaymentAuthorizationStatus status) {
                                                          [self.delegate mockApplePayPaymentAuthorizationViewControllerDidFinish:self];
                                                      }];
}

@end
