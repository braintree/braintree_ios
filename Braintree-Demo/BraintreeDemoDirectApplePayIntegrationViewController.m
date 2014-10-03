@import PassKit;
#import <UIAlertView+Blocks.h>

#import "BraintreeDemoDirectApplePayIntegrationViewController.h"

@interface BraintreeDemoDirectApplePayIntegrationViewController () <PKPaymentAuthorizationViewControllerDelegate>

@property (nonatomic, strong) Braintree *braintree;
@property (nonatomic, copy) void (^completionBlock)(NSString *nonce);

@property (nonatomic, weak) IBOutlet UIButton *applePayButton;

@end

@implementation BraintreeDemoDirectApplePayIntegrationViewController

- (instancetype)initWithBraintree:(Braintree *)braintree completion:(void (^)(NSString *nonce))completion {
    self = [super init];
    if (self) {
        self.braintree = braintree;
        self.completionBlock = completion;
    }
    return self;
}

- (NSArray *)supportedNetworks {
    return @[ PKPaymentNetworkAmex ];
}

- (IBAction)tappedButton:(__unused id)sender {
    if (![PKPaymentAuthorizationViewController canMakePaymentsUsingNetworks:self.supportedNetworks]) {
        [UIAlertView showWithTitle:@"Apple Pay Error"
                           message:@"canMakePayments returns NO"
                             style:UIAlertViewStyleDefault
                 cancelButtonTitle:@"OK"
                 otherButtonTitles:nil
                          tapBlock:nil];

        return;
    }

    PKPaymentRequest *request = [[PKPaymentRequest alloc] init];
    request.merchantIdentifier = @"com.merchant.braintreepayments.dev-2";
    request.paymentSummaryItems = @[ [PKPaymentSummaryItem summaryItemWithLabel:@"An Item"
                                                                         amount:[NSDecimalNumber decimalNumberWithString:@"0.5"]],
                                     [PKPaymentSummaryItem summaryItemWithLabel:@"An add-on"
                                                                         amount:[NSDecimalNumber decimalNumberWithString:@"1.0"]] ];
    request.countryCode = @"US";
    request.currencyCode = @"USD";
    request.applicationData = [@"Some random application data" dataUsingEncoding:NSUTF8StringEncoding];
    request.merchantCapabilities = PKMerchantCapability3DS;
    request.supportedNetworks = self.supportedNetworks;

    PKPaymentAuthorizationViewController *vc = [[PKPaymentAuthorizationViewController alloc] initWithPaymentRequest:request];
    vc.delegate = self;

    if (vc) {
        [self presentViewController:vc animated:YES completion:nil];
    } else {
        [UIAlertView showWithTitle:@"Apple Pay Error"
                           message:@"Failed to initialize an Apple Pay authorization view controller"
                             style:UIAlertViewStyleDefault
                 cancelButtonTitle:@"OK"
                 otherButtonTitles:nil
                          tapBlock:nil];
    }
}


#pragma mark PKPaymentAuthorizationViewControllerDelegate

- (void)paymentAuthorizationViewController:(__unused PKPaymentAuthorizationViewController *)controller didAuthorizePayment:(PKPayment *)payment completion:(void (^)(PKPaymentAuthorizationStatus))completion {
    BTClientApplePayRequest *request = [[BTClientApplePayRequest alloc] initWithApplePayPayment:payment];
    [self.braintree.client saveApplePayPayment:request
                                       success:^(BTApplePayPaymentMethod *applePayPaymentMethod) {
                                           NSLog(@"Apple Pay Success! Got a nocne: %@", applePayPaymentMethod.nonce);
                                           self.completionBlock(applePayPaymentMethod.nonce);
                                           completion(PKPaymentAuthorizationStatusSuccess);
                                       } failure:^(NSError *error) {
                                           NSLog(@"Error: %@", error);
                                           completion(PKPaymentAuthorizationStatusFailure);
                                       }];
}

- (void)paymentAuthorizationViewControllerDidFinish:(PKPaymentAuthorizationViewController *)controller {
    [controller dismissViewControllerAnimated:YES completion:nil];
}

@end
