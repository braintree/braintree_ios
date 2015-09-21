#import "BraintreeDemoApplePayPassKitViewController.h"
#import "BraintreeDemoSettings.h"

@import PassKit;

@interface BraintreeDemoApplePayPassKitViewController () <PKPaymentAuthorizationViewControllerDelegate>
@property(nonatomic, copy) NSString *paymentMethodNonce;
@end

@implementation BraintreeDemoApplePayPassKitViewController

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

    if (![PKPaymentAuthorizationViewController canMakePaymentsUsingNetworks:@[PKPaymentNetworkAmex, PKPaymentNetworkMasterCard, PKPaymentNetworkVisa]]) {
        self.progressBlock(@"canMakePaymentsUsingNetworks: returns NO, hiding Apple Pay button");
        return nil;
    }

    UIButton *button;
    if ([PKPaymentButton class]) {
        button = [PKPaymentButton buttonWithType:PKPaymentButtonTypePlain style:PKPaymentButtonStyleBlack];
    } else {
        button = [UIButton buttonWithType:UIButtonTypeSystem];
        [button setTintColor:[UIColor blackColor]];
        [button.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-UltraLight" size:36]];
        [button setTitle:@"PAY WITH APPLE PAY" forState:UIControlStateNormal];
    }

    [button addTarget:self action:@selector(tappedApplePayButton) forControlEvents:UIControlEventTouchUpInside];

    return button;
}

- (void)tappedApplePayButton {
    self.progressBlock(@"Constructing PKPaymentRequest");

    PKPaymentRequest *paymentRequest = [[PKPaymentRequest alloc] init];
    paymentRequest.requiredBillingAddressFields = PKAddressFieldName|PKAddressFieldPostalAddress;

    PKShippingMethod *shippingMethod1 = [PKShippingMethod summaryItemWithLabel:@"✈️ Fast Shipping" amount:[NSDecimalNumber decimalNumberWithString:@"4.99"]];
    shippingMethod1.detail = @"Fast but expensive";
    shippingMethod1.identifier = @"fast";
    PKShippingMethod *shippingMethod2 = [PKShippingMethod summaryItemWithLabel:@"🐢 Slow Shipping" amount:[NSDecimalNumber decimalNumberWithString:@"0.00"]];
    shippingMethod2.detail = @"Slow but free";
    shippingMethod2.identifier = @"slow";
    PKShippingMethod *shippingMethod3 = [PKShippingMethod summaryItemWithLabel:@"💣 Unavailable Shipping" amount:[NSDecimalNumber decimalNumberWithString:@"0xdeadbeef"]];
    shippingMethod3.detail = @"It will make Apple Pay fail";
    shippingMethod3.identifier = @"fail";
    paymentRequest.shippingMethods = @[shippingMethod1, shippingMethod2, shippingMethod3];
    paymentRequest.requiredShippingAddressFields = PKAddressFieldAll;
    paymentRequest.paymentSummaryItems = @[
                                           [PKPaymentSummaryItem summaryItemWithLabel:@"SOME ITEM" amount:[NSDecimalNumber decimalNumberWithString:@"10"]],
                                           [PKPaymentSummaryItem summaryItemWithLabel:@"SHIPPING" amount:shippingMethod1.amount],
                                           [PKPaymentSummaryItem summaryItemWithLabel:@"BRAINTREE" amount:[NSDecimalNumber decimalNumberWithString:@"14.99"]]
                                           ];
    
#ifdef __IPHONE_9_0
    paymentRequest.supportedNetworks = @[PKPaymentNetworkVisa, PKPaymentNetworkMasterCard, PKPaymentNetworkAmex, PKPaymentNetworkDiscover];
#else
    paymentRequest.supportedNetworks = @[PKPaymentNetworkVisa, PKPaymentNetworkMasterCard, PKPaymentNetworkAmex];
#endif
    paymentRequest.merchantCapabilities = PKMerchantCapability3DS;
    paymentRequest.currencyCode = @"USD";
    paymentRequest.countryCode = @"US";
    if ([paymentRequest respondsToSelector:@selector(setShippingType:)]) {
        paymentRequest.shippingType = PKShippingTypeDelivery;
    }

    switch ([BraintreeDemoSettings currentEnvironment]) {
        case BraintreeDemoTransactionServiceEnvironmentSandboxBraintreeSampleMerchant:
            paymentRequest.merchantIdentifier = @"merchant.com.braintreepayments.sandbox.Braintree-Demo";
            break;
        case BraintreeDemoTransactionServiceEnvironmentProductionExecutiveSampleMerchant:
            paymentRequest.merchantIdentifier = @"merchant.com.braintreepayments.Braintree-Demo";
            break;
        case BraintreeDemoTransactionServiceEnvironmentCustomMerchant:
            self.progressBlock(@"Direct Apple Pay integration does not support custom environments in this Demo App");
            break;
    }

    PKPaymentAuthorizationViewController *viewController = [[PKPaymentAuthorizationViewController alloc] initWithPaymentRequest:paymentRequest];
    viewController.delegate = self;

    self.progressBlock(@"Presenting Apple Pay Sheet");
    [self presentViewController:viewController animated:YES completion:nil];
}


#pragma mark PKPaymentAuthorizationViewControllerDelegate

- (void)paymentAuthorizationViewController:(__unused PKPaymentAuthorizationViewController *)controller
                   didSelectShippingMethod:(PKShippingMethod *)shippingMethod
                                completion:(void (^)(PKPaymentAuthorizationStatus, NSArray<PKPaymentSummaryItem *> * _Nonnull))completion
{
    PKPaymentSummaryItem *testItem = [PKPaymentSummaryItem summaryItemWithLabel:@"SOME ITEM" amount:[NSDecimalNumber decimalNumberWithString:@"10"]];
    if ([shippingMethod.identifier isEqualToString:@"fast"]) {
        completion(PKPaymentAuthorizationStatusSuccess,
                   @[
                     testItem,
                     [PKPaymentSummaryItem summaryItemWithLabel:@"SHIPPING" amount:shippingMethod.amount],
                     [PKPaymentSummaryItem summaryItemWithLabel:@"BRAINTREE" amount:[testItem.amount decimalNumberByAdding:shippingMethod.amount]],
                     ]);
    } else if ([shippingMethod.identifier isEqualToString:@"fail"]) {
        completion(PKPaymentAuthorizationStatusFailure, @[testItem]);
    } else {
        completion(PKPaymentAuthorizationStatusSuccess, @[testItem]);
    }
}

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
