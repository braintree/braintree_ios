#import "BraintreeDemoOneTouchDemoViewController.h"

#import <Braintree/Braintree.h>

#import <UIActionSheet+Blocks/UIActionSheet+Blocks.h>
#import <PureLayout/PureLayout.h>

#import "BraintreeDemoCustomMultiPaymentButtonManager.h"
#import "BraintreeDemoCustomPayPalButtonManager.h"
#import "BraintreeDemoCustomVenmoButtonManager.h"
#import "BraintreeDemoCustomApplePayButtonManager.h"

typedef NS_ENUM(NSInteger, BraintreeDemoOneTouchIntegrationTechnique) {
    BraintreeDemoOneTouchIntegrationTechniqueBTPaymentButton,
    BraintreeDemoOneTouchIntegrationTechniqueBTPayPalButton,
    BraintreeDemoOneTouchIntegrationTechniqueBTVenmoButton,
    BraintreeDemoOneTouchIntegrationTechniqueCustomPayPal,
    BraintreeDemoOneTouchIntegrationTechniqueCustomVenmo,
    BraintreeDemoOneTouchIntegrationTechniqueCustomApplePay,
    BraintreeDemoOneTouchIntegrationTechniqueCustomMultiPaymentButton,
};

NSArray *BraintreeDemoOneTouchAllIntegrationTechniques() {
    return @[ @(BraintreeDemoOneTouchIntegrationTechniqueBTPaymentButton),
              @(BraintreeDemoOneTouchIntegrationTechniqueBTPayPalButton),
              @(BraintreeDemoOneTouchIntegrationTechniqueBTVenmoButton),
              @(BraintreeDemoOneTouchIntegrationTechniqueCustomPayPal),
              @(BraintreeDemoOneTouchIntegrationTechniqueCustomVenmo),
              @(BraintreeDemoOneTouchIntegrationTechniqueCustomApplePay),
              @(BraintreeDemoOneTouchIntegrationTechniqueCustomMultiPaymentButton) ];
}

NSString *BraintreeDemoOneTouchDefaultIntegrationTechniqueUserDefaultsKey = @"BraintreeDemoOneTouchDefaultIntegrationTechniqueUserDefaultsKey";


@interface BraintreeDemoOneTouchDemoViewController () <BTPaymentMethodCreationDelegate>

@property (nonatomic, strong) Braintree *braintree;
@property (nonatomic, strong) BTPaymentProvider *paymentProvider;
@property (nonatomic, copy) void (^completionBlock)(NSString *nonce);

#pragma mark Integration Methods

@property (nonatomic, strong) BTPaymentButton *btPaymentButton;
@property (nonatomic, strong) BraintreeDemoCustomMultiPaymentButtonManager*customPaymentButtonManager;

@property (nonatomic, strong) BTUIPayPalButton *btPayPalButton;
@property (nonatomic, strong) BraintreeDemoCustomPayPalButtonManager *customPayPalButtonManager;

@property (nonatomic, strong) BTUIVenmoButton *btVenmoButton;
@property (nonatomic, strong) BraintreeDemoCustomVenmoButtonManager *customVenmoButtonManager;

@property (nonatomic, strong) BraintreeDemoCustomApplePayButtonManager *customApplePayButtonManager;

#pragma mark UI Configuration


@property (nonatomic, weak) IBOutlet UILabel *venmoPaymentMethodSwitchLabel;
@property (nonatomic, weak) IBOutlet UILabel *payPalPaymentMethodSwitchLabel;
@property (nonatomic, weak) IBOutlet UISwitch *venmoPaymentMethodSwitch;
@property (nonatomic, weak) IBOutlet UISwitch *payPalPaymentMethodSwitch;

#pragma mark UI Results

@property (nonatomic, weak) IBOutlet UILabel *emailLabel;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *activityIndicator;

@end

@implementation BraintreeDemoOneTouchDemoViewController

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

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Integration"
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(showIntegrationChooser:)];

    // Setup btPaymentButton
    self.btPaymentButton = [self.braintree paymentButtonWithDelegate:self];
    if (self.btPaymentButton) {
        [self.view addSubview:self.btPaymentButton];
        [self.btPaymentButton autoCenterInSuperview];
        [self.btPaymentButton autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:0];
        [self.btPaymentButton autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:0];
//        NSLayoutConstraint *heightConstraint =  [self.btPaymentButton autoSetDimension:ALDimensionHeight toSize:44];
//        heightConstraint.priority = UILayoutPriorityDefaultLow;
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
                         self.venmoPaymentMethodSwitchLabel.alpha = switchesAlpha;
                         self.payPalPaymentMethodSwitchLabel.alpha = switchesAlpha;
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

#pragma mark -

- (void)process {
    [self.activityIndicator startAnimating];
    self.emailLabel.text = nil;
}

- (void)fail:(NSError *)error {
    NSLog(@"%@", error);
    [self.activityIndicator stopAnimating];
    self.emailLabel.text = @"An error occurred";
    [[[UIAlertView alloc] initWithTitle:@"Failure"
                                message:[error localizedDescription]
                               delegate:nil
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil] show];
}


- (void)receivePaymentMethod:(BTPaymentMethod *)paymentMethod {
    [self.activityIndicator stopAnimating];
    if ([paymentMethod isKindOfClass:[BTPayPalPaymentMethod class]]) {
        self.emailLabel.text = [NSString stringWithFormat:@"Got a nonce 💎! %@", [(BTPayPalPaymentMethod *)paymentMethod email]];
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
    NSLog(@"[ONE TOUCH DEMO] paymentMethodCreator:%@ requestsPresentationOfViewController:%@", sender, viewController);
    [self presentViewController:viewController animated:YES completion:nil];
}

- (void)paymentMethodCreator:(id)sender requestsDismissalOfViewController:(UIViewController *)viewController {
    NSLog(@"[ONE TOUCH DEMO] paymentMethodCreator:%@ requestsDismissalOfViewController:%@", sender, viewController);
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)paymentMethodCreatorWillPerformAppSwitch:(id)sender {
    NSLog(@"[ONE TOUCH DEMO] paymentMethodCreatorWillPerformAppSwitch:%@", sender);
}

- (void)paymentMethodCreatorWillProcess:(id)sender {
    NSLog(@"[ONE TOUCH DEMO] paymentMethodCreatorWillProcess:%@", sender);
    [self process];
}

- (void)paymentMethodCreatorDidCancel:(id)sender {
    NSLog(@"[ONE TOUCH DEMO] paymentMethodCreatorDidCancel:%@", sender);
    [self cancel];
}

- (void)paymentMethodCreator:(id)sender didCreatePaymentMethod:(BTPaymentMethod *)paymentMethod {
    NSLog(@"[ONE TOUCH DEMO] paymentMethodCreator:%@ didCreatePaymentMethod: %@", sender, paymentMethod);
    [self receivePaymentMethod:paymentMethod];
}

- (void)paymentMethodCreator:(id)sender didFailWithError:(NSError *)error {
    NSLog(@"[ONE TOUCH DEMO] paymentMethodCreator:%@ error: %@", sender, error);
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

    self.btPaymentButton.enabledPaymentProviderTypes = enabledPaymentProviderTypes;

    NSOrderedSet *actualEnabledPaymentProviderTypes = self.btPaymentButton.enabledPaymentProviderTypes;
    [self.payPalPaymentMethodSwitch setOn:[actualEnabledPaymentProviderTypes containsObject:@(BTPaymentProviderTypePayPal)]
                                 animated:YES];
    [self.venmoPaymentMethodSwitch setOn:[actualEnabledPaymentProviderTypes containsObject:@(BTPaymentProviderTypeVenmo)]
                                 animated:YES];
}

@end
