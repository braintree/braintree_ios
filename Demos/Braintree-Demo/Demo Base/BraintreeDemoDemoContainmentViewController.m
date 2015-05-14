#import "BraintreeDemoDemoContainmentViewController.h"

#import <InAppSettingsKit/IASKAppSettingsViewController.h>
#import <InAppSettingsKit/IASKSettingsReader.h>
#import <iOS-Slide-Menu/SlideNavigationController.h>
#import <PureLayout/PureLayout.h>
#import <Braintree/BTPaymentMethod.h>

#import "BraintreeDemoMerchantAPI.h"
#import "BraintreeDemoBaseViewController.h"
#import "BraintreeDemoIntegrationViewController.h"

@interface BraintreeDemoDemoContainmentViewController () <IASKSettingsDelegate, SlideNavigationControllerDelegate, IntegrationViewControllerDelegate>
@property (nonatomic, strong) UIBarButtonItem *statusItem;
@property (nonatomic, strong) id latestPaymentMethodOrNonce;
@property (nonatomic, strong) BraintreeDemoBaseViewController *currentDemoViewController;
@property (nonatomic, strong) UIViewController *rightMenu;
@end

@implementation BraintreeDemoDemoContainmentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupToolbar];
    [self reloadIntegration];
    [self setupRightMenu];
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

- (void)setupRightMenu {
    BraintreeDemoIntegrationViewController *ivc = [[BraintreeDemoIntegrationViewController alloc] init];
    ivc.delegate = self;
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:ivc];
    self.rightMenu = nc;
    [SlideNavigationController sharedInstance].rightMenu = self.rightMenu;
}

- (BOOL)slideNavigationControllerShouldDisplayRightMenu {
    return YES;
}


#pragma mark - UI Updates

- (void)setLatestPaymentMethodOrNonce:(id)latestPaymentMethodOrNonce {
    _latestPaymentMethodOrNonce = latestPaymentMethodOrNonce;

    if (latestPaymentMethodOrNonce) {
        self.statusItem.enabled = YES;
    }
}

- (void)updateStatus:(NSString *)status {
    [self.statusItem setTitle:status];
    NSLog(@"%@", self.statusItem.title);
}


#pragma mark - UI Handlers

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


#pragma mark - Demo Integration Lifecycle


- (void)reloadIntegration {
    if (self.currentDemoViewController) {
        [self.currentDemoViewController willMoveToParentViewController:nil];
        [self.currentDemoViewController removeFromParentViewController];
        [self.currentDemoViewController.view removeFromSuperview];
    }

    [self updateStatus:@"Fetching Client Token…"];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    self.title = @"Braintree";
    [[BraintreeDemoMerchantAPI sharedService] createCustomerAndFetchClientTokenWithCompletion:^(NSString *clientToken, NSError *error) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        if (error) {
            [self updateStatus:error.localizedDescription];
        } else {
            self.currentDemoViewController = [self instantiateCurrentIntegrationViewControllerWithClientToken:clientToken];
            [self updateStatus:[NSString stringWithFormat:@"Presenting %@", NSStringFromClass([self.currentDemoViewController class])]];
            self.currentDemoViewController.progressBlock = [self progressBlock];
            self.currentDemoViewController.completionBlock = [self completionBlock];

            [self containIntegrationViewController:self.currentDemoViewController];

            self.title = self.currentDemoViewController.title;
        }
    }];
}

- (BraintreeDemoBaseViewController *)instantiateCurrentIntegrationViewControllerWithClientToken:(NSString *)clientToken {
    NSString *integrationName = [[NSUserDefaults standardUserDefaults] stringForKey:@"BraintreeDemoSettingsIntegration"];
    NSLog(@"Loading integration: %@", integrationName);

    Class integrationClass = NSClassFromString(integrationName);
    NSAssert([integrationClass isSubclassOfClass:[BraintreeDemoBaseViewController class]], @"%@ is not a valid BraintreeDemoBaseViewController", integrationName);

    return [(BraintreeDemoBaseViewController *)[integrationClass alloc] initWithClientToken:clientToken];
}

- (void)containIntegrationViewController:(UIViewController *)viewController {
    [self addChildViewController:viewController];

    [self.view addSubview:viewController.view];

    [viewController.view autoPinToTopLayoutGuideOfViewController:self withInset:0];
    [viewController.view autoPinToBottomLayoutGuideOfViewController:self withInset:0];
    [viewController.view autoPinEdgeToSuperviewEdge:ALEdgeLeading];
    [viewController.view autoPinEdgeToSuperviewEdge:ALEdgeTrailing];

    [viewController didMoveToParentViewController:self];
}


#pragma mark - Progress and Completion Blocks

- (void (^)(NSString *message))progressBlock {
    // This class is responsible for retaining the progress block
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
    // This class is responsible for retaining the completion block
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


#pragma mark IASKSettingsDelegate

- (void)settingsViewControllerDidEnd:(IASKAppSettingsViewController *)sender {
    [sender dismissViewControllerAnimated:YES completion:nil];
    [self reloadIntegration];
}

#pragma mark IntegrationViewControllerDelegate

- (void)integrationViewController:(__unused BraintreeDemoIntegrationViewController *)integrationViewController didChangeAppSetting:(__unused NSDictionary *)appSetting {
    [self reloadIntegration];
}

@end

@implementation SlideNavigationController (BraintreeDemoCustomization)

- (void)navigationController:(__unused UINavigationController *)navigationController
      willShowViewController:(__unused UIViewController *)viewController
                    animated:(__unused BOOL)animated
{
    // do nothing so that the Settings button remains on the nav bar
}

@end
