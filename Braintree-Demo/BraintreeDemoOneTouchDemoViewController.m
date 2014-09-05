#import "BraintreeDemoOneTouchDemoViewController.h"

#import <Braintree/Braintree.h>
#import <Braintree/BTClient+BTPayPal.h>
#import <Braintree/BTVenmoAppSwitchHandler.h>

#import <UIActionSheet+Blocks/UIActionSheet+Blocks.h>

#import <PureLayout/PureLayout.h>

#import "BraintreeDemoCustomPayPalButtonManager.h"
#import "BraintreeDemoCustomVenmoButtonManager.h"

typedef NS_ENUM(NSInteger, BraintreeDemoOneTouchIntegrationTechnique) {
    BraintreeDemoOneTouchIntegrationTechniqueBTPaymentButton,
    BraintreeDemoOneTouchIntegrationTechniqueBTPayPalButton,
    BraintreeDemoOneTouchIntegrationTechniqueBTVenmoButton,
    BraintreeDemoOneTouchIntegrationTechniqueCustomPayPal,
    BraintreeDemoOneTouchIntegrationTechniqueCustomVenmo,
};

NSArray *BraintreeDemoOneTouchAllIntegrationTechniques() {
    return @[ @(BraintreeDemoOneTouchIntegrationTechniqueBTPaymentButton),
              @(BraintreeDemoOneTouchIntegrationTechniqueBTPayPalButton),
              @(BraintreeDemoOneTouchIntegrationTechniqueBTVenmoButton),
              @(BraintreeDemoOneTouchIntegrationTechniqueCustomPayPal),
              @(BraintreeDemoOneTouchIntegrationTechniqueCustomVenmo) ];
}

NSString *BraintreeDemoOneTouchDefaultIntegrationTechniqueUserDefaultsKey = @"BraintreeDemoOneTouchDefaultIntegrationTechniqueUserDefaultsKey";


@interface BraintreeDemoOneTouchDemoViewController () <BTPaymentMethodCreationDelegate, BTPayPalButtonDelegate>

@property (nonatomic, strong) Braintree *braintree;
@property (nonatomic, copy) void (^completionBlock)(NSString *nonce);

#pragma mark Integration Methods

@property (nonatomic, strong) BTPaymentButton *btPaymentButton;

@property (nonatomic, strong) BTPayPalButton *btPayPalButton;
@property (nonatomic, strong) BraintreeDemoCustomPayPalButtonManager *customPayPalButtonManager;

@property (nonatomic, strong) BTUIVenmoButton *btVenmoButton;
@property (nonatomic, strong) BraintreeDemoCustomVenmoButtonManager *customVenmoButtonManager;

#pragma mark UI Configuration

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
        self.completionBlock = completionBlock;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemOrganize
                                                                                           target:self
                                                                                           action:@selector(showIntegrationChooser:)];

    // Setup btPaymentButton
    self.btPaymentButton = [[BTPaymentButton alloc] initWithFrame:CGRectZero];
    if (self.btPaymentButton) {
        self.btPaymentButton.delegate = self;
        self.btPaymentButton.client = self.braintree.client;
        [self.view addSubview:self.btPaymentButton];
        [self.btPaymentButton autoCenterInSuperview];
        [self.btPaymentButton autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:0];
        [self.btPaymentButton autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:0];
        NSLayoutConstraint *heightConstraint =  [self.btPaymentButton autoSetDimension:ALDimensionHeight toSize:44];
        heightConstraint.priority = UILayoutPriorityDefaultLow;
        [self.btPaymentButton setContentHuggingPriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisVertical];
    }

    // Setup btPayPalButton
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    self.btPayPalButton = [self.braintree payPalButtonWithDelegate:self];
#pragma clang diagnostic pop
    if (self.btPayPalButton) {
        self.btPayPalButton.delegate = self;
        [self.btPayPalButton setTranslatesAutoresizingMaskIntoConstraints:NO];
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

    // Setup btVenmoButton
    self.btVenmoButton = [[BTUIVenmoButton alloc] initWithFrame:CGRectZero];
    if (self.btVenmoButton) {
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

#pragma mark Integration Chooser

- (NSString *)integrationNameForTechnique:(BraintreeDemoOneTouchIntegrationTechnique)integrationTechnique {
    switch (integrationTechnique) {
        case BraintreeDemoOneTouchIntegrationTechniqueBTPaymentButton:
            return @"BTPaymentButton";
        case BraintreeDemoOneTouchIntegrationTechniqueCustomVenmo:
            return @"Custom Venmo button";
        case BraintreeDemoOneTouchIntegrationTechniqueCustomPayPal:
            return @"Custom PayPal button";
        case BraintreeDemoOneTouchIntegrationTechniqueBTVenmoButton:
            return @"BTVenmoButton";
        case BraintreeDemoOneTouchIntegrationTechniqueBTPayPalButton:
            return @"BTPayPalButton";
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
        case BraintreeDemoOneTouchIntegrationTechniqueCustomPayPal:
            paymentButton = self.customPayPalButtonManager.button;
            break;
        case BraintreeDemoOneTouchIntegrationTechniqueBTVenmoButton:
            paymentButton = self.btVenmoButton;
            break;
        case BraintreeDemoOneTouchIntegrationTechniqueBTPayPalButton:
            paymentButton = self.btPayPalButton;
            break;
    }
    return paymentButton;
}

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
                         [self setTitle:[self integrationNameForTechnique:selectedIntegrationTechnique]];
                     }];
    self.emailLabel.text = [self integrationNameForTechnique:selectedIntegrationTechnique];
    [self setDefaultIntegration:selectedIntegrationTechnique];
}

- (void)tappedVenmoButton:(__unused id)sender {
    [[self.braintree paymentProviderWithDelegate:self] createPaymentMethod:BTPaymentProviderTypeVenmo];
}

#pragma mark -

- (void)willReceivePaymentMethod {
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
        self.emailLabel.text = [(BTPayPalPaymentMethod *)paymentMethod email];
    } else {
        self.emailLabel.text = @"Got a nonce!";
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

#pragma mark PayPal Button Delegate Methods

- (void)payPalButtonWillCreatePayPalPaymentMethod:(__unused BTPayPalButton *)button {
    [self willReceivePaymentMethod];
}

- (void)payPalButton:(__unused BTPayPalButton *)button didCreatePayPalPaymentMethod:(BTPayPalPaymentMethod *)paymentMethod {
    [self receivePaymentMethod:paymentMethod];
}

- (void)payPalButton:(__unused BTPayPalButton *)button didFailWithError:(NSError *)error {
    [self fail:error];
}

- (void)payPalButtonDidCancel {
    [self cancel];
}


#pragma mark App Switcher Delegate

- (void)appSwitcherWillSwitch:(id<BTAppSwitching>)switcher {
    NSLog(@"appSwitcherWillSwitch:%@", switcher);
}

- (void)appSwitcherWillCreatePaymentMethod:(id<BTAppSwitching>)switcher {
    NSLog(@"appSwitcherWillCreatePaymentMethod:%@", switcher);
    [self willReceivePaymentMethod];
}

- (void)appSwitcher:(id<BTAppSwitching>)switcher didCreatePaymentMethod:(BTPaymentMethod *)paymentMethod {
    NSLog(@"appSwitcher:%@ didCreatePaymentMethod: %@", switcher, paymentMethod);
    [self receivePaymentMethod:paymentMethod];
}

- (void)appSwitcher:(id<BTAppSwitching>)switcher didFailWithError:(NSError *)error {
    NSLog(@"appSwitcher:%@ error: %@", switcher, error);
    [self fail:error];
}

- (void)appSwitcherDidCancel:(id<BTAppSwitching>)switcher {
    NSLog(@"appSwitcherDidCancel:%@", switcher);
    [self cancel];
}

#pragma mark PaymentMethodCreationDelegate

- (void)paymentMethodCreator:(id)sender requestsPresentationOfViewController:(UIViewController *)viewController {
    NSLog(@"paymentMethodCreator:%@ requestsPresentationOfViewController:%@", sender, viewController);
    [self presentViewController:viewController animated:YES completion:nil];
}

- (void)paymentMethodCreator:(id)sender requestsDismissalOfViewController:(UIViewController *)viewController {
    NSLog(@"paymentMethodCreator:%@ requestsDismissalOfViewController:%@", sender, viewController);
    [viewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)paymentMethodCreatorWillPerformAppSwitch:(id)sender {
    NSLog(@"paymentMethodCreatorWillPerformAppSwitch:%@", sender);
}

- (void)paymentMethodCreatorWillProcess:(id)sender {
    NSLog(@"paymentMethodCreatorWillProcess:%@", sender);
    [self willReceivePaymentMethod];
}

- (void)paymentMethodCreatorDidCancel:(id)sender {
    NSLog(@"paymentMethodCreatorDidCancel:%@", sender);
    [self cancel];
}

- (void)paymentMethodCreator:(id)sender didCreatePaymentMethod:(BTPaymentMethod *)paymentMethod {
    NSLog(@"paymentMethodCreator:%@ didCreatePaymentMethod: %@", sender, paymentMethod);
    [self receivePaymentMethod:paymentMethod];
}

- (void)paymentMethodCreator:(id)sender didFailWithError:(NSError *)error {
    NSLog(@"paymentMethodCreator:%@ error: %@", sender, error);
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