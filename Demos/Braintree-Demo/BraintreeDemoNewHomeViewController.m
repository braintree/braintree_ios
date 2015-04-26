#import "BraintreeDemoNewHomeViewController.h"
#import <InAppSettingsKit/IASKAppSettingsViewController.h>
#import <PureLayout/PureLayout.h>
#import <Braintree/BTPaymentMethod.h>

#import "BraintreeDemoMerchantAPI.h"
#import "BraintreeDemoBaseViewController.h"

@interface BraintreeDemoNewHomeViewController () <IASKSettingsDelegate>
@property (nonatomic, strong) UILabel *statusLabel;
@property (nonatomic, strong) UIBarButtonItem *statusItem;
@property (nonatomic, strong) id latestPaymentMethodOrNonce;
@property (nonatomic, strong) BraintreeDemoBaseViewController *currentDemoViewController;
@end

@implementation BraintreeDemoNewHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupToolbar];
    [self reloadIntegration];
}

- (void)setupToolbar {
    UIBarButtonItem *flexSpaceLeft = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                   target:nil
                                                                                   action:nil];
    UIBarButtonItem *flexSpaceRight = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                    target:nil
                                                                                    action:nil];
    self.statusItem = [[UIBarButtonItem alloc] initWithTitle:@"Ready"
                                                       style:UIBarButtonItemStylePlain
                                                      target:self
                                                      action:@selector(tappedStatus)];
    self.statusItem.enabled = NO;
    self.toolbarItems = @[flexSpaceLeft, self.statusItem, flexSpaceRight];
}

- (void)setLatestPaymentMethodOrNonce:(id)latestPaymentMethodOrNonce {
    _latestPaymentMethodOrNonce = latestPaymentMethodOrNonce;

    if (latestPaymentMethodOrNonce) {
        self.statusItem.enabled = YES;
    }
}

#pragma mark -

- (void)tappedStatus {
    NSLog(@"Tapped status!");

    if (self.latestPaymentMethodOrNonce) {
        NSString *nonce = [self.latestPaymentMethodOrNonce isKindOfClass:[BTPaymentMethod class]] ? [self.latestPaymentMethodOrNonce nonce] : self.latestPaymentMethodOrNonce;
        [self updateStatus:@"Creating Transaction…"];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        [[BraintreeDemoMerchantAPI sharedService] makeTransactionWithPaymentMethodNonce:nonce
                                                                             completion:^(NSString *transactionId, NSError *error){
                                                                                 [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                                                                                 self.latestPaymentMethodOrNonce = nil;
                                                                                 if (error) {
                                                                                     [self updateStatus:error.localizedDescription];
                                                                                 } else {
                                                                                     [self updateStatus:transactionId];
                                                                                 }
                                                                             }];
    }
}

- (IBAction)tappedRefresh {
    [self reloadIntegration];
}

- (IBAction)tappedSettings {
    IASKAppSettingsViewController *appSettingsViewController = [[IASKAppSettingsViewController alloc] init];
    appSettingsViewController.delegate = self;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:appSettingsViewController];
    [self presentViewController:nav animated:YES completion:nil];
}


#pragma mark -

- (void)updateStatus:(NSString *)status {
    [self.statusItem setTitle:status];
    NSLog(@"%@", self.statusItem.title);
}


- (BraintreeDemoBaseViewController *)instantiateCurrentIntegrationViewControllerWithClientToken:(NSString *)clientToken {
    NSString *integrationName = [[NSUserDefaults standardUserDefaults] stringForKey:@"BraintreeDemoSettingsIntegration"];
    NSLog(@"Loading integration: %@", integrationName);

    Class integrationClass = NSClassFromString(integrationName);
    NSAssert([integrationClass isSubclassOfClass:[BraintreeDemoBaseViewController class]], @"%@ is not a valid BraintreeDemoBaseViewController", integrationClass);

    return [[integrationClass alloc] initWithClientToken:clientToken];
}

- (void)reloadIntegration {
    [self.currentDemoViewController willMoveToParentViewController:nil];
    [self.currentDemoViewController removeFromParentViewController];
    [self.currentDemoViewController.view removeFromSuperview];

    [self updateStatus:@"Fetching Client Token…"];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];

    [[BraintreeDemoMerchantAPI sharedService] createCustomerAndFetchClientTokenWithCompletion:^(NSString *clientToken, NSError *error) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        if (error) {
            [self failWithError:error];
        } else {
            self.currentDemoViewController = [self instantiateCurrentIntegrationViewControllerWithClientToken:clientToken];
            [self updateStatus:[NSString stringWithFormat:@"Presenting %@", NSStringFromClass([self.currentDemoViewController class])]];
            self.currentDemoViewController.progressBlock = [self progressBlock];
            self.currentDemoViewController.completionBlock = [self completionBlock];
            [self addChildViewController:self.currentDemoViewController];
            [self.view addSubview:self.currentDemoViewController.view];
            [self.currentDemoViewController.view autoPinEdgesToSuperviewMargins];
            [self.currentDemoViewController didMoveToParentViewController:self];
        }
    }];
}


#pragma mark -

- (void (^)(NSString *message))progressBlock {
    static id block;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        block = ^(NSString *message){
            [self updateStatus:message];
        };
    });
    return block;
}

- (void (^)(BTPaymentMethod *paymentMethod))completionBlock {
    static id block;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        block = ^(id paymentMethod){
            self.latestPaymentMethodOrNonce = paymentMethod;
            [self updateStatus:[NSString stringWithFormat:@"Got a nonce. Tap to make a transaction."]];
        };
    });
    return block;
}

- (void)failWithError:(NSError *)error {
    [self updateStatus:[NSString stringWithFormat:@"Failed: %@", error.localizedDescription]];
    NSLog(@"%@", error);
}

#pragma mark IASKSettingsDelegate

- (void)settingsViewControllerDidEnd:(IASKAppSettingsViewController *)sender {
    [sender dismissViewControllerAnimated:YES completion:nil];
    [self reloadIntegration];
}

@end
