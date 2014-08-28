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


// TODO: Temporary typdefs, pending implementation of these classes
typedef UIButton BTPaymentButton;

@interface BraintreeDemoOneTouchDemoViewController () <BTAppSwitchingDelegate, BTPayPalButtonDelegate, BTPayPalAdapterDelegate>

@property (nonatomic, strong) Braintree *braintree;
@property (nonatomic, copy) void (^completionBlock)(NSString *nonce);

#pragma mark Integration Methods

@property (nonatomic, strong) BTPaymentButton *btPaymentButton;

@property (nonatomic, strong) BTPayPalButton *btPayPalButton;
@property (nonatomic, strong) BraintreeDemoCustomPayPalButtonManager *customPayPalButtonManager;

@property (nonatomic, strong) BTUIVenmoButton *btVenmoButton;
@property (nonatomic, strong) BraintreeDemoCustomVenmoButtonManager *customVenmoButtonManager;


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

    // Setup btPayPalButton
    self.btPayPalButton = [self.braintree payPalButtonWithDelegate:self];

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
        [self.view addSubview:self.btVenmoButton];
        [self.btVenmoButton autoCenterInSuperview];
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

- (UIControl *)integrationButtonForTechnique:(BraintreeDemoOneTouchIntegrationTechnique)integrationTechnique {
    static UIButton *notAvailableLabel;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        notAvailableLabel = [[UIButton alloc] init];
        [notAvailableLabel setTitle:@"Not Yet Implemented" forState:UIControlStateNormal];
        [notAvailableLabel setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        notAvailableLabel.alpha = 0;
        notAvailableLabel.enabled = NO;
        [self.view addSubview:notAvailableLabel];
        [notAvailableLabel autoCenterInSuperview];
    });

    UIControl *button;

    switch (integrationTechnique) {
        case BraintreeDemoOneTouchIntegrationTechniqueBTPaymentButton:
            button = self.btPaymentButton;
            break;
        case BraintreeDemoOneTouchIntegrationTechniqueCustomVenmo:
            button = self.customVenmoButtonManager.button;
            break;
        case BraintreeDemoOneTouchIntegrationTechniqueCustomPayPal:
            button = self.customPayPalButtonManager.button;
            break;
        case BraintreeDemoOneTouchIntegrationTechniqueBTVenmoButton:
            button = self.btVenmoButton;
            break;
        case BraintreeDemoOneTouchIntegrationTechniqueBTPayPalButton:
            button = self.btPayPalButton;
            break;
    }
    return button ?: notAvailableLabel;
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

#pragma mark -


- (IBAction)didTapVenmo:(__unused id)sender {
    [BTVenmoAppSwitchHandler sharedHandler].returnURLScheme = @"com.braintreepayments.Braintree-Demo.payments";
    [[BTVenmoAppSwitchHandler sharedHandler] initiateAppSwitchWithClient:self.braintree.client delegate:self];
}

- (void)willReceivePaymentMethod {
    [self.activityIndicator startAnimating];
    self.emailLabel.text = nil;
}

- (void)fail:(NSError *)error {
    NSLog(@"%@", error);
    [self.activityIndicator stopAnimating];
    self.emailLabel.text = @"An error occurred";
    [[[UIAlertView alloc] initWithTitle:@"Failed to tokenize PayPal Auth Code"
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

#pragma mark PayPal Adapter Delegate Methods

- (void)payPalAdapterWillCreatePayPalPaymentMethod:(__unused BTPayPalAdapter *)payPalAdapter {
    [self willReceivePaymentMethod];
}

- (void)payPalAdapter:(__unused BTPayPalAdapter *)payPalAdapter didCreatePayPalPaymentMethod:(BTPayPalPaymentMethod *)paymentMethod {
    [self receivePaymentMethod:paymentMethod];
}

- (void)payPalAdapter:(__unused BTPayPalAdapter *)payPalAdapter didFailWithError:(NSError *)error {
    [self fail:error];
}

- (void)payPalAdapterDidCancel:(__unused BTPayPalAdapter *)payPalAdapter {
    [self cancel];
}

- (void)payPalAdapter:(__unused BTPayPalAdapter *)payPalAdapter requestsPresentationOfViewController:(UIViewController *)viewController {
    [self presentViewController:viewController
                       animated:YES
                     completion:nil];
}

- (void)payPalAdapter:(__unused BTPayPalAdapter *)payPalAdapter requestsDismissalOfViewController:(UIViewController *)viewController {
    [viewController dismissViewControllerAnimated:YES
                                       completion:nil];
}

#pragma mark -

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


@end


