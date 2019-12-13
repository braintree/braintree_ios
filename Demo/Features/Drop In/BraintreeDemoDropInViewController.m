#import "BraintreeDemoDropInViewController.h"

#import <PureLayout/PureLayout.h>
#import <BraintreeCore/BraintreeCore.h>
#import <BraintreeDropIn/BraintreeDropIn.h>
#import <BraintreeVenmo/BraintreeVenmo.h>
#import "BraintreeUIKit.h"
#import "BTPaymentSelectionViewController.h"
#import <BraintreeApplePay/BraintreeApplePay.h>

#import "Demo-Swift.h"

@interface BraintreeDemoDropInViewController () <PKPaymentAuthorizationViewControllerDelegate>

@property (nonatomic, strong) BTUIKPaymentOptionCardView *paymentMethodTypeIcon;
@property (nonatomic, strong) UILabel *paymentMethodTypeLabel;
@property (nonatomic, strong) UILabel *cartLabel;
@property (nonatomic, strong) UILabel *itemLabel;
@property (nonatomic, strong) UILabel *priceLabel;
@property (nonatomic, strong) UILabel *paymentMethodHeaderLabel;
@property (nonatomic, strong) UILabel *colorSchemeLabel;
@property (nonatomic, strong) UIButton *dropInButton;
@property (nonatomic, strong) UIButton *purchaseButton;
@property (nonatomic, strong) UISegmentedControl *colorSchemeSegmentedControl;
@property (nonatomic, strong) NSString *authorizationString;
@property (nonatomic) BOOL useApplePay;
@property (nonatomic, strong) BTPaymentMethodNonce *selectedNonce;
@property (nonatomic, strong) NSArray *checkoutConstraints;
@end

@implementation BraintreeDemoDropInViewController

- (instancetype)initWithAuthorization:(NSString *)authorization {
    if (self = [super initWithAuthorization:authorization]) {

        self.authorizationString = authorization;
    }
    return self;
}

- (void) updatePaymentMethod:(BTPaymentMethodNonce*)paymentMethodNonce {
    self.paymentMethodTypeLabel.hidden = paymentMethodNonce == nil;
    self.paymentMethodTypeIcon.hidden = paymentMethodNonce == nil;
    if (paymentMethodNonce != nil) {
        BTUIKPaymentOptionType paymentMethodType = [BTUIKViewUtil paymentOptionTypeForPaymentInfoType:paymentMethodNonce.type];
        self.paymentMethodTypeIcon.paymentOptionType = paymentMethodType;
        [self.paymentMethodTypeLabel setText:paymentMethodNonce.localizedDescription];
    }
    [self updatePaymentMethodConstraints];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"Drop-in", nil);
    self.cartLabel = [[UILabel alloc] init];
    self.cartLabel.text = NSLocalizedString(@"CART", nil);
    self.cartLabel.font = [UIFont systemFontOfSize:[UIFont smallSystemFontSize]];
    self.cartLabel.textColor = UIColor.grayColor;
    self.cartLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.cartLabel];

    self.itemLabel = [[UILabel alloc] init];
    self.itemLabel.text = NSLocalizedString(@"1 Sock", nil);
    self.itemLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.itemLabel];

    self.priceLabel = [[UILabel alloc] init];
    self.priceLabel.text = NSLocalizedString(@"$100", nil);
    self.priceLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.priceLabel];

    self.paymentMethodHeaderLabel = [[UILabel alloc] init];
    self.paymentMethodHeaderLabel.text = NSLocalizedString(@"PAYMENT METHODS", nil);
    self.paymentMethodHeaderLabel.textColor = UIColor.grayColor;
    self.paymentMethodHeaderLabel.font = [UIFont systemFontOfSize:[UIFont smallSystemFontSize]];
    self.paymentMethodHeaderLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.paymentMethodHeaderLabel];

    self.colorSchemeLabel = [[UILabel alloc] init];
    self.colorSchemeLabel.text = NSLocalizedString(@"COLOR SCHEME", nil);
    self.colorSchemeLabel.textColor = UIColor.grayColor;
    self.colorSchemeLabel.font = [UIFont systemFontOfSize:[UIFont smallSystemFontSize]];
    self.colorSchemeLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.colorSchemeLabel];

    self.dropInButton = [[UIButton alloc] init];
    [self.dropInButton setTitle:NSLocalizedString(@"Select Payment Method", nil) forState:UIControlStateNormal];
    [self.dropInButton setTitleColor:self.view.tintColor forState:UIControlStateNormal];
    self.dropInButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.dropInButton addTarget:self action:@selector(tappedToShowDropIn) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.dropInButton];

    self.purchaseButton = [[UIButton alloc] init];
    [self.purchaseButton setTitle:NSLocalizedString(@"Complete Purchase", nil) forState:UIControlStateNormal];
    [self.purchaseButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.purchaseButton setTitleColor:[[UIColor whiteColor] colorWithAlphaComponent:0.8] forState:UIControlStateHighlighted];
    self.purchaseButton.backgroundColor = self.view.tintColor;
    self.purchaseButton.translatesAutoresizingMaskIntoConstraints = NO;

    [self.purchaseButton addTarget:self action:@selector(purchaseButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    self.purchaseButton.layer.cornerRadius = 4.0;
    [self.view addSubview:self.purchaseButton];

    self.paymentMethodTypeIcon = [BTUIKPaymentOptionCardView new];
    self.paymentMethodTypeIcon.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.paymentMethodTypeIcon];
    self.paymentMethodTypeIcon.hidden = YES;

    self.paymentMethodTypeLabel = [[UILabel alloc] init];
    self.paymentMethodTypeLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.paymentMethodTypeLabel];
    self.paymentMethodTypeLabel.hidden = YES;

    if (@available(iOS 13, *)) {
        self.colorSchemeSegmentedControl = [[UISegmentedControl alloc] initWithItems:@[@"Light", @"Dark", @"Dynamic"]];
    } else {
        self.colorSchemeSegmentedControl = [[UISegmentedControl alloc] initWithItems:@[@"Light", @"Dark"]];
    }
    self.colorSchemeSegmentedControl.translatesAutoresizingMaskIntoConstraints = NO;
    self.colorSchemeSegmentedControl.selectedSegmentIndex = 0;
    [self.view addSubview:self.colorSchemeSegmentedControl];
    
    [self updatePaymentMethodConstraints];

    self.progressBlock(@"Fetching customer's payment methods...");
    self.useApplePay = NO;
    
    [BTDropInResult fetchDropInResultForAuthorization:self.authorizationString handler:^(BTDropInResult * _Nullable result, NSError * _Nullable error) {
        if (error) {
            self.progressBlock([NSString stringWithFormat:@"Error: %@", error.localizedDescription]);
            NSLog(@"Error: %@", error);
        } else {
            if (result.paymentOptionType == BTUIKPaymentOptionTypeApplePay) {
                self.progressBlock(@"Ready for checkout...");
                [self setupApplePay];
            } else {
                self.useApplePay = NO;
                self.selectedNonce = result.paymentMethod;
                self.progressBlock(@"Ready for checkout...");
                [self updatePaymentMethod:self.selectedNonce];
            }
        }
    }];
}

- (void) setupApplePay {
    self.paymentMethodTypeLabel.hidden = NO;
    self.paymentMethodTypeIcon.hidden = NO;
    self.paymentMethodTypeIcon.paymentOptionType = BTUIKPaymentOptionTypeApplePay;
    [self.paymentMethodTypeLabel setText:NSLocalizedString(@"Apple Pay", nil)];
    self.useApplePay = YES;
    [self updatePaymentMethodConstraints];
}

#pragma mark Constraints

- (void)updatePaymentMethodConstraints {
    if (self.checkoutConstraints) {
        [NSLayoutConstraint deactivateConstraints:self.checkoutConstraints];
    }
    NSDictionary *viewBindings = @{
                                   @"view": self,
                                   @"cartLabel": self.cartLabel,
                                   @"itemLabel": self.itemLabel,
                                   @"priceLabel": self.priceLabel,
                                   @"paymentMethodHeaderLabel": self.paymentMethodHeaderLabel,
                                   @"colorSchemeLabel": self.colorSchemeLabel,
                                   @"dropInButton": self.dropInButton,
                                   @"paymentMethodTypeIcon": self.paymentMethodTypeIcon,
                                   @"paymentMethodTypeLabel": self.paymentMethodTypeLabel,
                                   @"purchaseButton":self.purchaseButton,
                                   @"colorSchemeSegmentedControl":self.colorSchemeSegmentedControl
                                   };
    
    NSMutableArray *newConstraints = [NSMutableArray new];
    [newConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[cartLabel]-|" options:0 metrics:nil views:viewBindings]];
    [newConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[purchaseButton]-|" options:0 metrics:nil views:viewBindings]];
    [newConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(20)-[cartLabel]-[itemLabel]-[paymentMethodHeaderLabel]" options:0 metrics:nil views:viewBindings]];

    [newConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[itemLabel]-[priceLabel]-|" options:NSLayoutFormatAlignAllTop metrics:nil views:viewBindings]];

    [newConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[paymentMethodHeaderLabel]-|" options:0 metrics:nil views:viewBindings]];

    [newConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[colorSchemeLabel]-|" options:0 metrics:nil views:viewBindings]];

    if (!self.paymentMethodTypeIcon.hidden && !self.paymentMethodTypeLabel.hidden) {
        [newConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[paymentMethodHeaderLabel]-[paymentMethodTypeIcon(29)]-[dropInButton]" options:0 metrics:nil views:viewBindings]];

        [newConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[paymentMethodTypeIcon(45)]-[paymentMethodTypeLabel]" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewBindings]];
        [newConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[dropInButton]-|" options:0 metrics:nil views:viewBindings]];
        [self.dropInButton setTitle:NSLocalizedString(@"Change Payment Method", nil) forState:UIControlStateNormal];
        self.purchaseButton.backgroundColor = self.view.tintColor;
        self.purchaseButton.enabled = YES;
    } else {
        [newConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[paymentMethodHeaderLabel]-[dropInButton]" options:0 metrics:nil views:viewBindings]];

        [newConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[dropInButton]-|" options:0 metrics:nil views:viewBindings]];
        [self.dropInButton setTitle:NSLocalizedString(@"Add Payment Method", nil) forState:UIControlStateNormal];
        self.purchaseButton.backgroundColor = [UIColor lightGrayColor];
        self.purchaseButton.enabled = NO;
    }

    [newConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[dropInButton]-(20)-[purchaseButton]-(20)-[colorSchemeLabel]-[colorSchemeSegmentedControl]" options:0 metrics:nil views:viewBindings]];

    [newConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[colorSchemeSegmentedControl]-|" options:0 metrics:nil views:viewBindings]];
    
    self.checkoutConstraints = newConstraints;
    [self.view addConstraints:self.checkoutConstraints];
}

#pragma mark Button Handlers

- (void)purchaseButtonPressed {
    if (self.useApplePay) {

        PKPaymentRequest *paymentRequest = [[PKPaymentRequest alloc] init];
        paymentRequest.paymentSummaryItems = @[
                                               [PKPaymentSummaryItem summaryItemWithLabel:@"Socks" amount:[NSDecimalNumber decimalNumberWithString:@"100"]]
                                               ];
        paymentRequest.supportedNetworks = @[PKPaymentNetworkVisa, PKPaymentNetworkMasterCard, PKPaymentNetworkAmex, PKPaymentNetworkDiscover];
        paymentRequest.merchantCapabilities = PKMerchantCapability3DS;
        paymentRequest.currencyCode = @"USD";
        paymentRequest.countryCode = @"US";
        
        switch ([BraintreeDemoSettings currentEnvironment]) {
            case BraintreeDemoEnvironmentSandbox:
                paymentRequest.merchantIdentifier = @"merchant.com.braintreepayments.sandbox.Braintree-Demo";
                break;
            case BraintreeDemoEnvironmentProduction:
                paymentRequest.merchantIdentifier = @"merchant.com.braintreepayments.Braintree-Demo";
                break;
            case BraintreeDemoEnvironmentCustom:
                self.progressBlock(@"Direct Apple Pay integration does not support custom environments in this Demo App");
                break;
        }
        
        PKPaymentAuthorizationViewController *viewController = [[PKPaymentAuthorizationViewController alloc] initWithPaymentRequest:paymentRequest];
        viewController.delegate = self;
        
        self.progressBlock(@"Presenting Apple Pay Sheet");
        [self presentViewController:viewController animated:YES completion:nil];
    } else {
        self.completionBlock(self.selectedNonce);
        self.transactionBlock();
    }
}

- (void)tappedToShowDropIn {
    BTDropInRequest *dropInRequest = [[BTDropInRequest alloc] init];
    // To test 3DS
    //dropInRequest.amount = @"10.00";
    //dropInRequest.threeDSecureVerification = YES;

    switch(self.colorSchemeSegmentedControl.selectedSegmentIndex) {
        case 2:
            if (@available(iOS 13, *)) {
                BTUIKAppearance.sharedInstance.colorScheme = BTUIKColorSchemeDynamic;
                break;
            }
        case 1:
            BTUIKAppearance.sharedInstance.colorScheme = BTUIKColorSchemeDark;
            break;
        default:
            BTUIKAppearance.sharedInstance.colorScheme = BTUIKColorSchemeLight;
    }

    BTDropInController *dropIn = [[BTDropInController alloc] initWithAuthorization:self.authorizationString request:dropInRequest handler:^(BTDropInController * _Nonnull dropInController, BTDropInResult * _Nullable result, NSError * _Nullable error) {
        if (error) {
            self.progressBlock([NSString stringWithFormat:@"Error: %@", error.localizedDescription]);
            NSLog(@"Error: %@", error);
        } else if (result.isCancelled) {
            self.progressBlock(@"Cancelled🎲");
        } else {
            if (result.paymentOptionType == BTUIKPaymentOptionTypeApplePay) {
                self.progressBlock(@"Ready for checkout...");
                [self setupApplePay];
            } else {
                self.useApplePay = NO;
                self.selectedNonce = result.paymentMethod;
                self.progressBlock(@"Ready for checkout...");
                [self updatePaymentMethod:self.selectedNonce];
            }
        }
        [dropInController dismissViewControllerAnimated:YES completion:nil];
    }];
    
    [self presentViewController:dropIn animated:YES completion:nil];
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

- (void)paymentAuthorizationViewControllerDidFinish:(__unused PKPaymentAuthorizationViewController *)controller {
    [controller dismissViewControllerAnimated:YES completion:nil];
}

- (void)paymentAuthorizationViewController:(__unused PKPaymentAuthorizationViewController *)controller didAuthorizePayment:(PKPayment *)payment handler:(void (^)(PKPaymentAuthorizationResult * _Nonnull))completion API_AVAILABLE(ios(11.0), watchos(4.0)) {
    self.progressBlock(@"Apple Pay Did Authorize Payment");
    BTAPIClient *client = [[BTAPIClient alloc] initWithAuthorization:self.authorizationString];
    BTApplePayClient *applePayClient = [[BTApplePayClient alloc] initWithAPIClient:client];
    [applePayClient tokenizeApplePayPayment:payment completion:^(BTApplePayCardNonce * _Nullable tokenizedApplePayPayment, NSError * _Nullable error) {
        if (error) {
            self.progressBlock(error.localizedDescription);
            completion([[PKPaymentAuthorizationResult alloc] initWithStatus:PKPaymentAuthorizationStatusFailure errors:nil]);
        } else {
            self.completionBlock(tokenizedApplePayPayment);
            completion([[PKPaymentAuthorizationResult alloc] initWithStatus:PKPaymentAuthorizationStatusSuccess errors:nil]);
        }
    }];
}

- (void)paymentAuthorizationViewController:(__unused PKPaymentAuthorizationViewController *)controller
                       didAuthorizePayment:(PKPayment *)payment
                                completion:(void (^)(PKPaymentAuthorizationStatus status))completion {
    self.progressBlock(@"Apple Pay Did Authorize Payment");
    BTAPIClient *client = [[BTAPIClient alloc] initWithAuthorization:self.authorizationString];
    BTApplePayClient *applePayClient = [[BTApplePayClient alloc] initWithAPIClient:client];
    [applePayClient tokenizeApplePayPayment:payment completion:^(BTApplePayCardNonce * _Nullable tokenizedApplePayPayment, NSError * _Nullable error) {
        if (error) {
            self.progressBlock(error.localizedDescription);
            completion(PKPaymentAuthorizationStatusFailure);
        } else {
            self.completionBlock(tokenizedApplePayPayment);
            completion(PKPaymentAuthorizationStatusSuccess);
        }
    }];
}

- (void)paymentAuthorizationViewControllerWillAuthorizePayment:(__unused PKPaymentAuthorizationViewController *)controller {
    self.progressBlock(@"Apple Pay will Authorize Payment");
}

@end
