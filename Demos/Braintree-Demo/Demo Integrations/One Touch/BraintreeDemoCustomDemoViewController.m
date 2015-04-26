#import "BraintreeDemoCustomDemoViewController.h"

#import <Braintree/Braintree.h>

#import <PureLayout/PureLayout.h>

NSString *const BraintreeDemoCustomDemoViewControllerDefaultIntegrationTechniqueUserDefaultsKey = @"BraintreeDemoCustomDemoViewControllerDefaultIntegrationTechniqueUserDefaultsKey";
@interface BraintreeDemoCustomDemoViewController ()

@property (nonatomic, strong) Braintree *braintree;
@property (nonatomic, copy) void (^completionBlock)(NSString *nonce);

@property (nonatomic, strong) UIBarButtonItem *statusItem;
@end

@implementation BraintreeDemoCustomDemoViewController

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

    self.statusItem = [[UIBarButtonItem alloc] initWithTitle:@"Test" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.toolbarItems = @[self.statusItem];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Integration"
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(showIntegrationChooser:)];

//    // Setup btPaymentButton
//    self.btPaymentButton = [self.braintree paymentButtonWithDelegate:self];
//    if (self.btPaymentButton) {
//        [self.view addSubview:self.btPaymentButton];
//        [self.btPaymentButton autoCenterInSuperview];
//        [self.btPaymentButton autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:0];
//        [self.btPaymentButton autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:0];
//        [ALView autoSetPriority:UILayoutPriorityDefaultLow forConstraints:^{
//            [self.btPaymentButton autoSetDimension:ALDimensionHeight toSize:44];
//        }];
//        [self.btPaymentButton setContentHuggingPriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisVertical];
//    }
//
//    // Setup btPayPalButton
//    self.btPayPalButton = [[BTUIPayPalButton alloc] init];
//    if (self.btPayPalButton && [self.paymentProvider canCreatePaymentMethodWithProviderType:BTPaymentProviderTypePayPal]) {
//        [self.btPayPalButton addTarget:self action:@selector(tappedPayPalButton:) forControlEvents:UIControlEventTouchUpInside];
//        [self.view addSubview:self.btPayPalButton];
//        [self.btPayPalButton autoCenterInSuperview];
//        [self.btPayPalButton autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:0];
//        [self.btPayPalButton autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:0];
//        [self.btPayPalButton autoSetDimension:ALDimensionHeight toSize:60];
//    }
//
//    // Setup customPayPalButton
//    self.customPayPalButtonManager = [[BraintreeDemoCustomPayPalButtonManager alloc] initWithClient:self.braintree.client delegate:self];
//    if (self.customPayPalButtonManager) {
//        [self.view addSubview:self.customPayPalButtonManager.button];
//        [self.customPayPalButtonManager.button autoCenterInSuperview];
//    }
//
//    // Setup custom multi-provider button
//    self.customPaymentButtonManager = [[BraintreeDemoCustomMultiPaymentButtonManager alloc] initWithBraintree:self.braintree delegate:self];
//    if (self.customPaymentButtonManager) {
//        UIView *customPaymentButton = self.customPaymentButtonManager.view;
//        [self.view addSubview:customPaymentButton];
//        [customPaymentButton autoCenterInSuperview];
//        [customPaymentButton autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:0];
//        [customPaymentButton autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:0];
//        [customPaymentButton autoSetDimension:ALDimensionHeight toSize:52];
//    }
//
//    // Setup btVenmoButton
//    self.btVenmoButton = [[BTUIVenmoButton alloc] initWithFrame:CGRectZero];
//    if (self.btVenmoButton && [self.paymentProvider canCreatePaymentMethodWithProviderType:BTPaymentProviderTypeVenmo]) {
//        [self.btVenmoButton addTarget:self action:@selector(tappedVenmoButton:) forControlEvents:UIControlEventTouchUpInside];
//        [self.view addSubview:self.btVenmoButton];
//        [self.btVenmoButton autoCenterInSuperview];
//        [self.btVenmoButton autoSetDimension:ALDimensionHeight toSize:44];
//        [self.btVenmoButton autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:0];
//        [self.btVenmoButton autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:0];
//    }
//
//    // Setup customVenmoButton
//    self.customVenmoButtonManager = [[BraintreeDemoCustomVenmoButtonManager alloc] initWithClient:self.braintree.client delegate:self];
//    if (self.customVenmoButtonManager) {
//        [self.view addSubview:self.customVenmoButtonManager.button];
//        [self.customVenmoButtonManager.button autoCenterInSuperview];
//    }
//
//    // Setup customApplePayButton
//    self.customApplePayButtonManager = [[BraintreeDemoCustomApplePayButtonManager alloc] initWithClient:self.braintree.client delegate:self];
//    if (self.customApplePayButtonManager) {
//        [self.view addSubview:self.customApplePayButtonManager.button];
//        [self.customApplePayButtonManager.button autoCenterInSuperview];
//    }
//

    [self switchToIntegration:self.defaultIntegration animated:NO];
}

#pragma mark Default Integration Technique Persistence

- (id<BraintreeDemoUseCase>)defaultIntegration {
    NSString *techniqueClassName = [[NSUserDefaults standardUserDefaults] stringForKey:BraintreeDemoCustomDemoViewControllerDefaultIntegrationTechniqueUserDefaultsKey];
    if (NSClassFromString(techniqueClassName)) {
        return [[NSClassFromString(techniqueClassName) alloc] init];
    } else {
        // Integration technique does not exist. This occurs if it was added in a later version of Braintree-Demo
        return [[BraintreeDemoUseCaseManager sharedInstance] useCaseAtIndex:0];
    }
}

- (void)setDefaultIntegration:(id<BraintreeDemoUseCase>)integrationTechnique {
    [[NSUserDefaults standardUserDefaults] setObject:NSStringFromClass([integrationTechnique class]) forKey:BraintreeDemoCustomDemoViewControllerDefaultIntegrationTechniqueUserDefaultsKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark Integration Chooser Data

//- (UIView *)integrationButtonForTechnique:(BraintreeDemoOneTouchIntegrationTechnique)integrationTechnique {
//    UIView *paymentButton = nil;
//    switch (integrationTechnique) {
//        case BraintreeDemoOneTouchIntegrationTechniqueBTPaymentButton:
//            paymentButton = self.btPaymentButton;
//            break;
//        case BraintreeDemoOneTouchIntegrationTechniqueCustomVenmo:
//            paymentButton = self.customVenmoButtonManager.button;
//            break;
//        case BraintreeDemoOneTouchIntegrationTechniqueCustomApplePay:
//            paymentButton = self.customApplePayButtonManager.button;
//            break;
//        case BraintreeDemoOneTouchIntegrationTechniqueCustomPayPal:
//            paymentButton = self.customPayPalButtonManager.button;
//            break;
//        case BraintreeDemoOneTouchIntegrationTechniqueBTVenmoButton:
//            paymentButton = self.btVenmoButton;
//            break;
//        case BraintreeDemoOneTouchIntegrationTechniqueBTPayPalButton:
//            paymentButton = self.btPayPalButton;
//            break;
//        case BraintreeDemoOneTouchIntegrationTechniqueCustomMultiPaymentButton:
//            paymentButton = self.customPaymentButtonManager.view;
//            break;
//    }
//    return paymentButton;
//}

//- (BOOL)shouldShowPaymentProviderSwitchForTechnique:(BraintreeDemoOneTouchIntegrationTechnique)integrationTechnique {
//    return integrationTechnique == BraintreeDemoOneTouchIntegrationTechniqueBTPaymentButton;
//}

#pragma mark Integration Chooser

- (void)showIntegrationChooser:(__unused id)sender {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Choose an Integration"
                                        message:nil
                                 preferredStyle:UIAlertControllerStyleActionSheet];

    NSArray *allUseCases = [[BraintreeDemoUseCaseManager sharedInstance] allUseCases];
    for (Class<BraintreeDemoUseCase> integrationTechnique in allUseCases) {
        [alert addAction:[UIAlertAction actionWithTitle:[integrationTechnique useCaseName]
                                                  style:UIAlertActionStyleDefault
                                                handler:^(__unused UIAlertAction *action) {
                                                    [self switchToIntegration:0 animated:YES];
                                                }]];
    }

    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel"
                                             style:UIAlertActionStyleCancel
                                            handler:nil]];

    [self presentViewController:alert animated:YES completion:nil];
}

- (void)switchToIntegration:(id<BraintreeDemoUseCase>)selectedIntegrationTechnique animated:(__unused BOOL)animated {
    NSLog(@"woudl switch to integration %@", selectedIntegrationTechnique);
//    [UIView animateWithDuration:(animated ? 0.2f : 0.0f)
//                     animations:^{
//                         for (NSNumber *integrationTechnique in BraintreeDemoUseCaseDemoViewController()) {
//                             [[self integrationButtonForTechnique:[integrationTechnique integerValue]] setAlpha:0.0f];
//                         }
//
//                         [[self integrationButtonForTechnique:selectedIntegrationTechnique] setAlpha:1.0f];
//                         self.navigationItem.rightBarButtonItem.title = [self integrationNameForTechnique:selectedIntegrationTechnique];
//
//                         CGFloat switchesAlpha = [self shouldShowPaymentProviderSwitchForTechnique:selectedIntegrationTechnique] ? 1.0f : 0.0f;
//                         self.venmoPaymentMethodSwitch.alpha = switchesAlpha;
//                         self.payPalPaymentMethodSwitch.alpha = switchesAlpha;
//                         self.venmoPaymentMethodSwitchLabel.alpha = switchesAlpha;
//                         self.payPalPaymentMethodSwitchLabel.alpha = switchesAlpha;
//                     }];
    [self setDefaultIntegration:selectedIntegrationTechnique];
}

#pragma mark -

- (void)process {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}

- (void)fail:(NSError *)error {
    NSLog(@"%@", error);
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [self setStatusText:@"An error occurred"];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error"
                                                                   message:error.localizedDescription
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK"
                                              style:UIAlertActionStyleCancel
                                            handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}


- (void)receivePaymentMethod:(BTPaymentMethod *)paymentMethod {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];

    if ([paymentMethod isKindOfClass:[BTPayPalPaymentMethod class]]) {
        [self setStatusText:[NSString stringWithFormat:@"Got a nonce 💎! %@", [(BTPayPalPaymentMethod *)paymentMethod email]]];
    } else if ([paymentMethod isKindOfClass:[BTApplePayPaymentMethod class]]) {
        [self setStatusText:[NSString stringWithFormat:@"Got a nonce via !"]];
#warning TODO: handle more types
    } else {
        [self setStatusText:@"Got a nonce 💎!"];
    }

    NSLog(@"Got a nonce! %@", paymentMethod.nonce);
    if (self.completionBlock) {
        self.completionBlock(paymentMethod.nonce);
    }
}

- (void)cancel {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [self setStatusText:@"Canceled 🔰"];
}


#pragma mark -

- (void)setStatusText:(NSString *)text {
    self.statusItem.title = text;
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

//- (IBAction)togglePaymentMethods {
//    NSMutableOrderedSet *enabledPaymentProviderTypes = [NSMutableOrderedSet orderedSet];
//    if (self.payPalPaymentMethodSwitch.on) {
//        [enabledPaymentProviderTypes addObject:@(BTPaymentProviderTypePayPal)];
//    }
//    if (self.venmoPaymentMethodSwitch.on) {
//        [enabledPaymentProviderTypes addObject:@(BTPaymentProviderTypeVenmo)];
//    }
//
//    self.btPaymentButton.enabledPaymentProviderTypes = enabledPaymentProviderTypes;
//
//    NSOrderedSet *actualEnabledPaymentProviderTypes = self.btPaymentButton.enabledPaymentProviderTypes;
//    [self.payPalPaymentMethodSwitch setOn:[actualEnabledPaymentProviderTypes containsObject:@(BTPaymentProviderTypePayPal)]
//                                 animated:YES];
//    [self.venmoPaymentMethodSwitch setOn:[actualEnabledPaymentProviderTypes containsObject:@(BTPaymentProviderTypeVenmo)]
//                                 animated:YES];
//}

@end
