@import PassKit;
#import <UIAlertView+Blocks.h>

#import "BraintreeDemoDirectApplePayIntegrationViewController.h"

@interface BraintreeDemoDirectApplePayIntegrationViewController () <PKPaymentAuthorizationViewControllerDelegate>

@property (nonatomic, strong) Braintree *braintree;
@property (nonatomic, copy) NSString *nonce;
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

- (void)viewDidLoad {
    [super viewDidLoad];
    if (![PKPaymentAuthorizationViewController class]) {
        self.applePayButton.hidden = YES;
        [UIAlertView showWithTitle:@"Apple Pay Error"
                           message:@"Apple Pay is not available on this version of iOS"
                             style:UIAlertViewStyleDefault
                 cancelButtonTitle:@"OK"
                 otherButtonTitles:nil
                          tapBlock:nil];
    }
}

- (NSArray *)supportedNetworks {
    
    // If you use BTPaymentProvider, the Braintree iOS SDK automatically uses the supportedNetworks
    // determined by the Braintree Gateway for your account.
    //
    // In this Demo, we set these supportedNetworks in -tappedButton:
    // `request.supportedNetworks = self.supportedNetworks;`
    return @[ PKPaymentNetworkAmex, PKPaymentNetworkMasterCard, PKPaymentNetworkVisa ];
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
    
    self.nonce = nil;

    PKPaymentRequest *request = [[PKPaymentRequest alloc] init];
    
    // If you use BTPaymentProvider, the Braintree iOS SDK may automatically use the Merchant ID
    // of the latest Apple Pay Certificate uploaded via your Braintree Control Panel.
    // However, with a Direct (or "Manual") Integration, you must set your Apple Merchant ID.
    request.merchantIdentifier = @"merchant.com.braintreepayments.dev-dcopeland";
    
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
    
    [self.braintree tokenizeApplePayPayment:payment completion:^(NSString *nonce, NSError *error) {
        if (!error) {
            NSLog(@"Apple Pay Success! Got a nonce: %@", nonce);
            self.nonce = nonce;
            completion(PKPaymentAuthorizationStatusSuccess);
        } else {
            NSLog(@"Error: %@", error);
            completion(PKPaymentAuthorizationStatusFailure);
        }
    }];
}

- (void)paymentAuthorizationViewControllerDidFinish:(PKPaymentAuthorizationViewController *)controller {
    
    // Important: You must dismiss `controller` to prevent your app from hanging
    [controller dismissViewControllerAnimated:YES completion:^{
        // If the buyer cancelled, self.nonce will still be nil
        if (self.nonce) {
            self.completionBlock(self.nonce);
        }
    }];
}

@end
