#import "BraintreeDemoApplePayPassKitViewController.h"
@import BraintreeApplePay;

@interface BraintreeDemoApplePayPassKitViewController () <PKPaymentAuthorizationViewControllerDelegate>

@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) BTApplePayClient *applePayClient;

@end

@implementation BraintreeDemoApplePayPassKitViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.applePayClient = [[BTApplePayClient alloc] initWithAPIClient:self.apiClient];

    self.label = [[UILabel alloc] init];
    self.label.translatesAutoresizingMaskIntoConstraints = NO;
    self.label.numberOfLines = 1;
    self.label.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.label];

    if (self.paymentButton) {
        [NSLayoutConstraint activateConstraints:@[
            [self.paymentButton.leadingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.leadingAnchor constant:20.0],
            [self.paymentButton.trailingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.trailingAnchor constant:-20.0],
            [self.label.topAnchor constraintEqualToSystemSpacingBelowAnchor:self.paymentButton.bottomAnchor multiplier:1.0],
            [self.label.leadingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.leadingAnchor],
            [self.label.trailingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.trailingAnchor]
        ]];
    }

    self.title = NSLocalizedString(@"Apple Pay via PassKit", nil);
}

- (UIControl *)createPaymentButton {
    if (![PKPaymentAuthorizationViewController canMakePayments]) {
        self.progressBlock(@"canMakePayments returns NO, hiding Apple Pay button");
        return nil;
    }

    UIButton *button = [PKPaymentButton buttonWithType:PKPaymentButtonTypePlain style:PKPaymentButtonStyleBlack];
    [button addTarget:self action:@selector(tappedApplePayButton) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (void)tappedApplePayButton {
    self.progressBlock(@"Constructing PKPaymentRequest");

    [self.applePayClient paymentRequest:^(PKPaymentRequest * _Nullable paymentRequest, NSError * _Nullable error) {
        if (error) {
            self.progressBlock(error.localizedDescription);
            return;
        }

        // Requiring PKAddressFieldPostalAddress crashes Simulator
        //paymentRequest.requiredBillingAddressFields = PKAddressFieldName|PKAddressFieldPostalAddress;
        paymentRequest.requiredBillingContactFields = [NSSet setWithObjects:PKContactFieldName, nil];

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
        paymentRequest.requiredShippingContactFields = [NSSet setWithObjects:PKContactFieldName, PKContactFieldPhoneNumber, PKContactFieldEmailAddress, nil];
        paymentRequest.paymentSummaryItems = @[
                                               [PKPaymentSummaryItem summaryItemWithLabel:@"SOME ITEM" amount:[NSDecimalNumber decimalNumberWithString:@"10"]],
                                               [PKPaymentSummaryItem summaryItemWithLabel:@"SHIPPING" amount:shippingMethod1.amount],
                                               [PKPaymentSummaryItem summaryItemWithLabel:@"BRAINTREE" amount:[NSDecimalNumber decimalNumberWithString:@"14.99"]]
                                               ];

        paymentRequest.merchantCapabilities = PKMerchantCapability3DS;
        if ([paymentRequest respondsToSelector:@selector(setShippingType:)]) {
            paymentRequest.shippingType = PKShippingTypeDelivery;
        }

        PKPaymentAuthorizationViewController *viewController = [[PKPaymentAuthorizationViewController alloc] initWithPaymentRequest:paymentRequest];
        viewController.delegate = self;
        
        self.progressBlock(@"Presenting Apple Pay Sheet");
        [self presentViewController:viewController animated:YES completion:nil];
    }];
}


#pragma mark PKPaymentAuthorizationViewControllerDelegate

- (void)paymentAuthorizationViewControllerDidFinish:(__unused PKPaymentAuthorizationViewController *)controller {
    [controller dismissViewControllerAnimated:YES completion:nil];
}

- (void)paymentAuthorizationViewController:(__unused PKPaymentAuthorizationViewController *)controller
                       didAuthorizePayment:(PKPayment *)payment
                                   handler:(void (^)(PKPaymentAuthorizationResult * _Nonnull))completion {
    self.progressBlock(@"Apple Pay Did Authorize Payment");
    [self.applePayClient tokenizeApplePayPayment:payment completion:^(BTApplePayCardNonce * _Nullable tokenizedApplePayPayment, NSError * _Nullable error) {
        if (error) {
            self.progressBlock(error.localizedDescription);
            completion([[PKPaymentAuthorizationResult alloc] initWithStatus:PKPaymentAuthorizationStatusFailure errors:nil]);
        } else {
            self.label.text = tokenizedApplePayPayment.nonce;
            self.completionBlock(tokenizedApplePayPayment);
            completion([[PKPaymentAuthorizationResult alloc] initWithStatus:PKPaymentAuthorizationStatusSuccess errors:nil]);
        }
    }];
}

- (void)paymentAuthorizationViewController:(PKPaymentAuthorizationViewController *)controller
                   didSelectShippingMethod:(PKShippingMethod *)shippingMethod
                                   handler:(void (^)(PKPaymentRequestShippingMethodUpdate * _Nonnull))completion {
    PKPaymentSummaryItem *testItem = [PKPaymentSummaryItem summaryItemWithLabel:@"SOME ITEM"
                                                                         amount:[NSDecimalNumber decimalNumberWithString:@"10"]];
    PKPaymentRequestShippingMethodUpdate *update = [[PKPaymentRequestShippingMethodUpdate alloc] initWithPaymentSummaryItems:@[testItem]];

    if ([shippingMethod.identifier isEqualToString:@"fast"]) {
        completion(update);
    } else if ([shippingMethod.identifier isEqualToString:@"fail"]) {
        update.status = PKPaymentAuthorizationStatusFailure;
        completion(update);
    } else {
        completion(update);
    }
}

- (void)paymentAuthorizationViewControllerWillAuthorizePayment:(__unused PKPaymentAuthorizationViewController *)controller {
    self.progressBlock(@"Apple Pay will Authorize Payment");
}

@end
