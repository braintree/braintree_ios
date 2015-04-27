#import "BraintreeDemoApplePayPassKitViewController.h"

@import PassKit;

@interface BraintreeDemoApplePayPassKitViewController () <PKPaymentAuthorizationViewControllerDelegate>
@property(nonatomic, copy) NSString *paymentMethodNonce;
@end

@implementation BraintreeDemoApplePayPassKitViewController

- (instancetype)initWithClientToken:(NSString *)clientToken {
    self = [super initWithClientToken:clientToken];
    if (self) {
        self.braintree = [Braintree braintreeWithClientToken:clientToken];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Apple Pay via PassKit";
}

- (UIControl *)paymentButton {
    if (![PKPaymentAuthorizationViewController class]) {
        self.progressBlock(@"Apple Pay is not available on this version of iOS");
        return nil;
    }
    if (![PKPaymentAuthorizationViewController canMakePayments]) {
        self.progressBlock(@"canMakePayments returns NO, hiding Apple Pay button");
        return nil;
    }

    if (![PKPaymentAuthorizationViewController canMakePaymentsUsingNetworks:@[]]) {
        self.progressBlock(@"canMakePaymentsUsingNetworks: returns NO, hiding Apple Pay button");
        return nil;
    }

    UIButton *button;
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80300
    button = [PKPaymentButton buttonWithType:PKPaymentButtonTypePlain style:PKPaymentButtonStyleBlack];
#else
    button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setTitle:@"Apple Pay" forState:UIControlStateNormal];
#endif

    [button addTarget:self action:@selector(tappedApplePayButton) forControlEvents:UIControlEventTouchUpInside];

    return button;
}

- (void)tappedApplePayButton {
    self.progressBlock(@"Constructin PKPaymentRequest");

    PKPaymentRequest *paymentRequest = [[PKPaymentRequest alloc] init];
    [paymentRequest setRequiredBillingAddressFields:PKAddressFieldName|PKAddressFieldPostalAddress];
    [paymentRequest setShippingMethods:@[[PKShippingMethod summaryItemWithLabel:@"Fast Shipping" amount:[NSDecimalNumber decimalNumberWithString:@"1.25"]]]];
    [paymentRequest setRequiredShippingAddressFields:PKAddressFieldAll];

    PKPaymentSummaryItem *testTotal = [PKPaymentSummaryItem summaryItemWithLabel:@"TEST" amount:[NSDecimalNumber decimalNumberWithString:@"10"]];
    [paymentRequest setPaymentSummaryItems:@[testTotal]];

    PKPaymentAuthorizationViewController *viewController = [[PKPaymentAuthorizationViewController alloc] initWithPaymentRequest:paymentRequest];
    viewController.delegate = self;

    self.progressBlock(@"Presenting Apple Pay Sheet");
    [self presentViewController:viewController animated:YES completion:nil];
}


#pragma mark PKPaymentAuthorizationViewControllerDelegate

- (void)paymentAuthorizationViewController:(__unused PKPaymentAuthorizationViewController *)controller
                       didAuthorizePayment:(PKPayment *)payment
                                completion:(void (^)(PKPaymentAuthorizationStatus status))completion {
    self.progressBlock(@"Apple Pay Did Authorize Payment");
    [self.braintree tokenizeApplePayPayment:payment
                                 completion:^(NSString *nonce, NSError *error) {
                                     if (error) {
                                         self.progressBlock(error.localizedDescription);
                                         completion(PKPaymentAuthorizationStatusFailure);
                                     } else {
                                         self.paymentMethodNonce = nonce;
                                         completion(PKPaymentAuthorizationStatusSuccess);
                                     }
                                 }];
}

- (void)paymentAuthorizationViewControllerDidFinish:(PKPaymentAuthorizationViewController *)controller {
    self.progressBlock(@"Apple Pay Finished");
    [controller dismissViewControllerAnimated:YES completion:^{
        if (self.paymentMethodNonce) {
            self.completionBlock(self.paymentMethodNonce);
        }
    }];
}

- (void)paymentAuthorizationViewControllerWillAuthorizePayment:(__unused PKPaymentAuthorizationViewController *)controller {
    self.progressBlock(@"Apple Pay will Authorize Payment");
}

@end
