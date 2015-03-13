#import "BraintreeDemoPaymentButtonDemoViewController.h"

#import <Braintree/Braintree.h>

#import <UIActionSheet+Blocks/UIActionSheet+Blocks.h>
#import <PureLayout/PureLayout.h>

#import "BraintreeDemoCustomMultiPaymentButtonManager.h"
#import "BraintreeDemoCustomPayPalButtonManager.h"
#import "BraintreeDemoCustomVenmoButtonManager.h"
#import "BraintreeDemoCustomApplePayButtonManager.h"
#import "BraintreeDemoCustomCoinbaseButtonManager.h"

typedef NS_ENUM(NSInteger, BraintreeDemoOneTouchIntegrationTechnique) {
    BraintreeDemoOneTouchIntegrationTechniqueBTPaymentButton,
    BraintreeDemoOneTouchIntegrationTechniqueBTPayPalButton,
    BraintreeDemoOneTouchIntegrationTechniqueBTVenmoButton,
    BraintreeDemoOneTouchIntegrationTechniqueBTCoinbaseButton,
    BraintreeDemoOneTouchIntegrationTechniqueCustomPayPal,
    BraintreeDemoOneTouchIntegrationTechniqueCustomVenmo,
    BraintreeDemoOneTouchIntegrationTechniqueCustomCoinbase,
    BraintreeDemoOneTouchIntegrationTechniqueCustomApplePay,
    BraintreeDemoOneTouchIntegrationTechniqueCustomMultiPaymentButton,
};

NSArray *BraintreeDemoOneTouchAllIntegrationTechniques() {
    return @[ @(BraintreeDemoOneTouchIntegrationTechniqueBTPaymentButton),
              @(BraintreeDemoOneTouchIntegrationTechniqueBTPayPalButton),
              @(BraintreeDemoOneTouchIntegrationTechniqueBTVenmoButton),
              @(BraintreeDemoOneTouchIntegrationTechniqueBTCoinbaseButton),
              @(BraintreeDemoOneTouchIntegrationTechniqueCustomPayPal),
              @(BraintreeDemoOneTouchIntegrationTechniqueCustomVenmo),
              @(BraintreeDemoOneTouchIntegrationTechniqueCustomCoinbase),
              @(BraintreeDemoOneTouchIntegrationTechniqueCustomApplePay),
              @(BraintreeDemoOneTouchIntegrationTechniqueCustomMultiPaymentButton) ];
}

NSString *BraintreeDemoOneTouchDefaultIntegrationTechniqueUserDefaultsKey = @"BraintreeDemoOneTouchDefaultIntegrationTechniqueUserDefaultsKey";


@interface BraintreeDemoPaymentButtonDemoViewController () <BTPaymentMethodCreationDelegate>

@property (nonatomic, strong) Braintree *braintree;
@property (nonatomic, strong) BTPaymentProvider *paymentProvider;
@property (nonatomic, copy) void (^completionBlock)(NSString *nonce);

#pragma mark Integration Methods

@property (nonatomic, strong) BTPaymentButton *btPaymentButton;
@property (nonatomic, strong) BraintreeDemoCustomMultiPaymentButtonManager *customPaymentButtonManager;

@property (nonatomic, strong) BTUIPayPalButton *btPayPalButton;
@property (nonatomic, strong) BraintreeDemoCustomPayPalButtonManager *customPayPalButtonManager;

@property (nonatomic, strong) BTUIVenmoButton *btVenmoButton;
@property (nonatomic, strong) BraintreeDemoCustomVenmoButtonManager *customVenmoButtonManager;

@property (nonatomic, strong) BTUICoinbaseButton *btCoinbaseButton;
@property (nonatomic, strong) BraintreeDemoCustomCoinbaseButtonManager *customCoinbaseButtonManager;

@property (nonatomic, strong) BraintreeDemoCustomApplePayButtonManager *customApplePayButtonManager;

#pragma mark UI Configuration


@property (nonatomic, weak) IBOutlet UILabel *venmoPaymentMethodSwitchLabel;
@property (nonatomic, weak) IBOutlet UILabel *payPalPaymentMethodSwitchLabel;
@property (weak, nonatomic) IBOutlet UILabel *coinbasePaymentMethodSwitchLabel;
@property (nonatomic, weak) IBOutlet UISwitch *venmoPaymentMethodSwitch;
@property (nonatomic, weak) IBOutlet UISwitch *payPalPaymentMethodSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *coinbasePaymentMethodSwitch;

#pragma mark UI Results

@property (nonatomic, weak) IBOutlet UILabel *emailLabel;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *activityIndicator;

@end

@implementation BraintreeDemoPaymentButtonDemoViewController

- (instancetype)initWithBraintree:(Braintree *)braintree completion:(void (^)(NSString *))completionBlock {
    self = [self init];
    if (self) {
        self.braintree = braintree;
        self.paymentProvider = [self.braintree paymentProviderWithDelegate:self];
        self.completionBlock = completionBlock;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    UIBarButtonItem *integrationChooserButton = [[UIBarButtonItem alloc] initWithTitle:@"Integration"
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                     action:@selector(showIntegrationChooser:)];
    integrationChooserButton.accessibilityLabel = @"Choose Integration Technique";
    self.navigationItem.rightBarButtonItem = integrationChooserButton;

    // Setup btPaymentButton
    self.btPaymentButton = [self.braintree paymentButtonWithDelegate:self];
    if (self.btPaymentButton) {
        [self.view addSubview:self.btPaymentButton];
        [self.btPaymentButton autoCenterInSuperview];
        [self.btPaymentButton autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:0];
        [self.btPaymentButton autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:0];
        [ALView autoSetPriority:UILayoutPriorityDefaultLow forConstraints:^{
            [self.btPaymentButton autoSetDimension:ALDimensionHeight toSize:44];
        }];
        [self.btPaymentButton setContentHuggingPriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisVertical];
    }

    // Setup btPayPalButton
    self.btPayPalButton = [[BTUIPayPalButton alloc] init];
    if (self.btPayPalButton && [self.paymentProvider canCreatePaymentMethodWithProviderType:BTPaymentProviderTypePayPal]) {
        [self.btPayPalButton addTarget:self action:@selector(tappedPayPalButton:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:self.btPayPalButton];
        [self.btPayPalButton autoCenterInSuperview];
        [self.btPayPalButton autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:0];
        [self.btPayPalButton autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:0];
        [self.btPayPalButton autoSetDimension:ALDimensionHeight toSize:60];
    }

    // Setup customPayPalButton
    self.customPayPalButtonManager = [[BraintreeDemoCustomPayPalButtonManager alloc] initWithClient:self.braintree.client delegate:self];
    if (self.customPayPalButtonManager) {
        [self.view addSubview:self.customPayPalButtonManager.button];
        [self.customPayPalButtonManager.button autoCenterInSuperview];
    }

    // Setup custom multi-provider button
    self.customPaymentButtonManager = [[BraintreeDemoCustomMultiPaymentButtonManager alloc] initWithBraintree:self.braintree delegate:self];
    if (self.customPaymentButtonManager) {
        UIView *customPaymentButton = self.customPaymentButtonManager.view;
        [self.view addSubview:customPaymentButton];
        [customPaymentButton autoCenterInSuperview];
        [customPaymentButton autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:0];
        [customPaymentButton autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:0];
        [customPaymentButton autoSetDimension:ALDimensionHeight toSize:52];
    }

    // Setup btVenmoButton
    self.btVenmoButton = [[BTUIVenmoButton alloc] initWithFrame:CGRectZero];
    if (self.btVenmoButton && [self.paymentProvider canCreatePaymentMethodWithProviderType:BTPaymentProviderTypeVenmo]) {
        [self.btVenmoButton addTarget:self action:@selector(tappedVenmoButton:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:self.btVenmoButton];
        [self.btVenmoButton autoCenterInSuperview];
        [self.btVenmoButton autoSetDimension:ALDimensionHeight toSize:44];
        [self.btVenmoButton autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:0];
        [self.btVenmoButton autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:0];
    }

    // Setup btCoinbaseButton
    self.btCoinbaseButton = [[BTUICoinbaseButton alloc] initWithFrame:CGRectZero];
    if (self.btCoinbaseButton && [self.paymentProvider canCreatePaymentMethodWithProviderType:BTPaymentProviderTypeCoinbase]) {
        [self.btCoinbaseButton addTarget:self action:@selector(tappedCoinbaseButton:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:self.btCoinbaseButton];
        [self.btCoinbaseButton autoCenterInSuperview];
        [self.btCoinbaseButton autoSetDimension:ALDimensionHeight toSize:44];
        [self.btCoinbaseButton autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:0];
        [self.btCoinbaseButton autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:0];
    }

    // Setup customVenmoButton
    self.customVenmoButtonManager = [[BraintreeDemoCustomVenmoButtonManager alloc] initWithClient:self.braintree.client delegate:self];
    if (self.customVenmoButtonManager) {
        [self.view addSubview:self.customVenmoButtonManager.button];
        [self.customVenmoButtonManager.button autoCenterInSuperview];
    }

    // Setup customApplePayButton
    self.customApplePayButtonManager = [[BraintreeDemoCustomApplePayButtonManager alloc] initWithClient:self.braintree.client delegate:self];
    if (self.customApplePayButtonManager) {
        [self.view addSubview:self.customApplePayButtonManager.button];
        [self.customApplePayButtonManager.button autoCenterInSuperview];
    }

    self.customCoinbaseButtonManager = [[BraintreeDemoCustomCoinbaseButtonManager alloc] initWithClient:self.braintree.client delegate:self];
    if (self.customCoinbaseButtonManager) {
        [self.view addSubview:self.customCoinbaseButtonManager.button];
        [self.customCoinbaseButtonManager.button autoCenterInSuperview];
    }

    [self switchToIntegration:self.defaultIntegration animated:NO];
}

#pragma mark Default Integration Technique Persistence

- (BraintreeDemoOneTouchIntegrationTechnique)defaultIntegration {
    return [[NSUserDefaults standardUserDefaults] integerForKey:BraintreeDemoOneTouchDefaultIntegrationTechniqueUserDefaultsKey];
}

- (void)setDefaultIntegration:(BraintreeDemoOneTouchIntegrationTechnique)integrationTechnique {
    [[NSUserDefaults standardUserDefaults] setInteger:integrationTechnique forKey:BraintreeDemoOneTouchDefaultIntegrationTechniqueUserDefaultsKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark Integration Chooser Data

- (NSString *)integrationNameForTechnique:(BraintreeDemoOneTouchIntegrationTechnique)integrationTechnique {
    switch (integrationTechnique) {
        case BraintreeDemoOneTouchIntegrationTechniqueBTPaymentButton:
            return @"BTPaymentButton";
        case BraintreeDemoOneTouchIntegrationTechniqueCustomVenmo:
            return @"Custom Venmo button";
        case BraintreeDemoOneTouchIntegrationTechniqueCustomPayPal:
            return @"Custom PayPal button";
        case BraintreeDemoOneTouchIntegrationTechniqueCustomApplePay:
            return @"Custom Apple Pay button";
        case BraintreeDemoOneTouchIntegrationTechniqueBTVenmoButton:
            return @"BTUIVenmoButton";
        case BraintreeDemoOneTouchIntegrationTechniqueBTPayPalButton:
            return @"BTUIPayPalButton";
        case BraintreeDemoOneTouchIntegrationTechniqueBTCoinbaseButton:
            return @"BTUICoinbaseButton";
        case BraintreeDemoOneTouchIntegrationTechniqueCustomCoinbase:
            return @"Custom Coinbase button";
        case BraintreeDemoOneTouchIntegrationTechniqueCustomMultiPaymentButton:
            return @"Custom Multi-Pay";
    }
}

- (UIView *)integrationButtonForTechnique:(BraintreeDemoOneTouchIntegrationTechnique)integrationTechnique {
    UIView *paymentButton;
    switch (integrationTechnique) {
        case BraintreeDemoOneTouchIntegrationTechniqueBTPaymentButton:
            paymentButton = self.btPaymentButton;
            break;
        case BraintreeDemoOneTouchIntegrationTechniqueCustomVenmo:
            paymentButton = self.customVenmoButtonManager.button;
            break;
        case BraintreeDemoOneTouchIntegrationTechniqueCustomApplePay:
            paymentButton = self.customApplePayButtonManager.button;
            break;
        case BraintreeDemoOneTouchIntegrationTechniqueCustomPayPal:
            paymentButton = self.customPayPalButtonManager.button;
            break;
        case BraintreeDemoOneTouchIntegrationTechniqueBTVenmoButton:
            paymentButton = self.btVenmoButton;
            break;
        case BraintreeDemoOneTouchIntegrationTechniqueBTPayPalButton:
            paymentButton = self.btPayPalButton;
            break;
        case BraintreeDemoOneTouchIntegrationTechniqueBTCoinbaseButton:
            paymentButton = self.btCoinbaseButton;
            break;
        case BraintreeDemoOneTouchIntegrationTechniqueCustomCoinbase:
            paymentButton = self.customCoinbaseButtonManager.button;
            break;
        case BraintreeDemoOneTouchIntegrationTechniqueCustomMultiPaymentButton:
            paymentButton = self.customPaymentButtonManager.view;
            break;
    }
    return paymentButton;
}

- (BOOL)shouldShowPaymentProviderSwitchForTechnique:(BraintreeDemoOneTouchIntegrationTechnique)integrationTechnique {
    return integrationTechnique == BraintreeDemoOneTouchIntegrationTechniqueBTPaymentButton;
}

#pragma mark Integration Chooser

- (void)showIntegrationChooser:(id)sender {
    NSMutableArray *allIntegrationTechniqueNames = [NSMutableArray arrayWithCapacity:[BraintreeDemoOneTouchAllIntegrationTechniques() count]];
    for (NSNumber *integrationTechnique in BraintreeDemoOneTouchAllIntegrationTechniques()) {
        [allIntegrationTechniqueNames addObject:[self integrationNameForTechnique:[integrationTechnique integerValue]]];
    }

    [UIActionSheet showFromBarButtonItem:sender
                                animated:YES
                               withTitle:@"Choose an Integration"
                       cancelButtonTitle:@"Cancel"
                  destructiveButtonTitle:nil
                       otherButtonTitles:allIntegrationTechniqueNames
                                tapBlock:^(__unused UIActionSheet *actionSheet, NSInteger buttonIndex) {
                                    if (buttonIndex >= (NSInteger)allIntegrationTechniqueNames.count) {
                                        return;
                                    }
                                    [self switchToIntegration:buttonIndex animated:YES];
                                }];
}

- (void)switchToIntegration:(BraintreeDemoOneTouchIntegrationTechnique)selectedIntegrationTechnique animated:(BOOL)animated {
    [UIView animateWithDuration:(animated ? 0.2f : 0.0f)
                     animations:^{
                         for (NSNumber *integrationTechnique in BraintreeDemoOneTouchAllIntegrationTechniques()) {
                             [[self integrationButtonForTechnique:[integrationTechnique integerValue]] setAlpha:0.0f];
                         }

                         [[self integrationButtonForTechnique:selectedIntegrationTechnique] setAlpha:1.0f];
                         self.navigationItem.rightBarButtonItem.title = [self integrationNameForTechnique:selectedIntegrationTechnique];

                         CGFloat switchesAlpha = [self shouldShowPaymentProviderSwitchForTechnique:selectedIntegrationTechnique] ? 1.0f : 0.0f;
                         self.venmoPaymentMethodSwitch.alpha = switchesAlpha;
                         self.payPalPaymentMethodSwitch.alpha = switchesAlpha;
                         self.coinbasePaymentMethodSwitch.alpha = switchesAlpha;
                         self.venmoPaymentMethodSwitchLabel.alpha = switchesAlpha;
                         self.payPalPaymentMethodSwitchLabel.alpha = switchesAlpha;
                         self.coinbasePaymentMethodSwitchLabel.alpha = switchesAlpha;
                     }];
    self.emailLabel.text = [self integrationNameForTechnique:selectedIntegrationTechnique];
    [self setDefaultIntegration:selectedIntegrationTechnique];
}

- (void)tappedVenmoButton:(__unused id)sender {
    [self.paymentProvider createPaymentMethod:BTPaymentProviderTypeVenmo];
}

- (void)tappedPayPalButton:(__unused id)sender {
    [self.paymentProvider createPaymentMethod:BTPaymentProviderTypePayPal];
}

- (void)tappedCoinbaseButton:(__unused id)sender {
    [self.paymentProvider createPaymentMethod:BTPaymentProviderTypeCoinbase];
}


#pragma mark -

- (void)process {
    [self.activityIndicator startAnimating];
    self.emailLabel.text = nil;
}

- (void)fail:(NSError *)error {
    NSLog(@"%@", error);
    [self.activityIndicator stopAnimating];
    self.emailLabel.text = @"An error occurred";
    NSString *message;
    if (error.userInfo[BTCustomerInputBraintreeValidationErrorsKey][@"error"][@"message"]) {
        message = error.userInfo[BTCustomerInputBraintreeValidationErrorsKey][@"error"][@"message"];
    } else {
        message = [error localizedDescription];
    }
    [[[UIAlertView alloc] initWithTitle:@"Error"
                                message:message
                               delegate:nil
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil] show];
}


- (void)receivePaymentMethod:(BTPaymentMethod *)paymentMethod {
    [self.activityIndicator stopAnimating];
    if ([paymentMethod isKindOfClass:[BTPayPalPaymentMethod class]]) {
        self.emailLabel.text = [NSString stringWithFormat:@"Got a nonce 💎! %@", [(BTPayPalPaymentMethod *)paymentMethod email]];
    } else if ([paymentMethod isKindOfClass:[BTCoinbasePaymentMethod class]]) {
        self.emailLabel.text = [NSString stringWithFormat:@"Got a ฿ nonce! %@", [(BTCoinbasePaymentMethod *)paymentMethod userIdentifier]];
    } else if ([paymentMethod isKindOfClass:[BTApplePayPaymentMethod class]]) {
        self.emailLabel.text = [NSString stringWithFormat:@"Got a nonce via !"];
    } else {
        self.emailLabel.text = @"Got a nonce 💎!";
    }
    
    NSLog(@"Got a nonce! %@", paymentMethod.nonce);
    if (self.completionBlock) {
        self.completionBlock(paymentMethod.nonce);
    }
}

- (void)cancel {
    [self.activityIndicator stopAnimating];
    self.emailLabel.text = @"Canceled 🔰";
}

#pragma mark PaymentMethodCreationDelegate

- (void)paymentMethodCreator:(id)sender requestsPresentationOfViewController:(UIViewController *)viewController {
    NSLog(@"[Braintree-Demo] paymentMethodCreator:%@ requestsPresentationOfViewController:%@", sender, viewController);
    [self presentViewController:viewController animated:YES completion:nil];
}

- (void)paymentMethodCreator:(id)sender requestsDismissalOfViewController:(UIViewController *)viewController {
    NSLog(@"[Braintree-Demo] paymentMethodCreator:%@ requestsDismissalOfViewController:%@", sender, viewController);
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)paymentMethodCreatorWillPerformAppSwitch:(id)sender {
    NSLog(@"[Braintree-Demo] paymentMethodCreatorWillPerformAppSwitch:%@", sender);
}

- (void)paymentMethodCreatorWillProcess:(id)sender {
    NSLog(@"[Braintree-Demo] paymentMethodCreatorWillProcess:%@", sender);
    [self process];
}

- (void)paymentMethodCreatorDidCancel:(id)sender {
    NSLog(@"[Braintree-Demo] paymentMethodCreatorDidCancel:%@", sender);
    [self cancel];
}

- (void)paymentMethodCreator:(id)sender didCreatePaymentMethod:(BTPaymentMethod *)paymentMethod {
    NSLog(@"[Braintree-Demo] paymentMethodCreator:%@ didCreatePaymentMethod: %@", sender, paymentMethod);
    [self receivePaymentMethod:paymentMethod];
}

- (void)paymentMethodCreator:(id)sender didFailWithError:(NSError *)error {
    NSLog(@"[Braintree-Demo] paymentMethodCreator:%@ error: %@", sender, error);
    [self fail:error];
}


#pragma mark UI Configurations for Development Testing

- (IBAction)togglePaymentMethods {
    NSMutableOrderedSet *enabledPaymentProviderTypes = [NSMutableOrderedSet orderedSet];
    if (self.payPalPaymentMethodSwitch.on) {
        [enabledPaymentProviderTypes addObject:@(BTPaymentProviderTypePayPal)];
    }
    if (self.venmoPaymentMethodSwitch.on) {
        [enabledPaymentProviderTypes addObject:@(BTPaymentProviderTypeVenmo)];
    }

    if (self.coinbasePaymentMethodSwitch.on) {
        [enabledPaymentProviderTypes addObject:@(BTPaymentProviderTypeCoinbase)];
    }

    self.btPaymentButton.enabledPaymentProviderTypes = enabledPaymentProviderTypes;

    NSOrderedSet *actualEnabledPaymentProviderTypes = self.btPaymentButton.enabledPaymentProviderTypes;
    [self.payPalPaymentMethodSwitch setOn:[actualEnabledPaymentProviderTypes containsObject:@(BTPaymentProviderTypePayPal)]
                                 animated:YES];
    [self.venmoPaymentMethodSwitch setOn:[actualEnabledPaymentProviderTypes containsObject:@(BTPaymentProviderTypeVenmo)]
                                 animated:YES];
    [self.coinbasePaymentMethodSwitch setOn:[actualEnabledPaymentProviderTypes containsObject:@(BTPaymentProviderTypeCoinbase)]
                                 animated:YES];
}

@end
