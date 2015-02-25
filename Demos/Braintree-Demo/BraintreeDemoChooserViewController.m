#import "BraintreeDemoChooserViewController.h"

#import <HockeySDK/HockeySDK.h>
#import <Braintree/Braintree.h>
#import <Braintree/Braintree-3D-Secure.h>
#import <UIActionSheet+Blocks/UIActionSheet+Blocks.h>
#import <InAppSettingsKit/IASKAppSettingsViewController.h>

#import "BraintreeDemoSettings.h"
#import "BraintreeDemoBraintreeInitializationDemoViewController.h"
#import "BraintreeDemoOneTouchDemoViewController.h"
#import "BraintreeDemoTokenizationDemoViewController.h"
#import "BraintreeDemoDirectApplePayIntegrationViewController.h"

#import "BraintreeDemoMerchantAPI.h"
#import "BTClient_Internal.h"

@interface BraintreeDemoChooserViewController () <BTDropInViewControllerDelegate, BTPaymentMethodCreationDelegate>

@property (nonatomic, weak) IBOutlet UIBarButtonItem *environmentSelector;

#pragma mark Status Cells

@property (nonatomic, weak) IBOutlet UITableViewCell *braintreeStatusCell;
@property (nonatomic, weak) IBOutlet UITableViewCell *braintreePaymentMethodNonceCell;
@property (nonatomic, weak) IBOutlet UITableViewCell *braintreeTransactionCell;

#pragma mark Drop-In Use Case Cells

@property (nonatomic, weak) IBOutlet UITableViewCell *dropInPaymentViewControllerCell;
@property (nonatomic, weak) IBOutlet UITableViewCell *customPayPalCell;

#pragma mark Custom Use Case Cells

@property (nonatomic, weak) IBOutlet UITableViewCell *tokenizationCell;
@property (nonatomic, weak) IBOutlet UITableViewCell *directApplePayCell;

#pragma mark Braintree Operation Cells

@property (nonatomic, weak) IBOutlet UITableViewCell *makeATransactionCell;

#pragma mark Meta Cells

@property (nonatomic, weak) IBOutlet UITableViewCell *libraryVersionCell;

#pragma mark Payment Data

@property (nonatomic, strong) Braintree *braintree;
@property (nonatomic, copy) NSString *merchantId;
@property (nonatomic, copy) NSString *nonce;
@property (nonatomic, copy) NSString *lastTransactionId;

#pragma mark ThreeDSecure

@property (nonatomic, strong) BTThreeDSecure *threeDSecure;

@end

@implementation BraintreeDemoChooserViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(initializeBraintree) forControlEvents:UIControlEventValueChanged];

    [self switchToEnvironment];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(switchToEnvironment) name:BraintreeDemoMerchantAPIEnvironmentDidChangeNotification object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:BraintreeDemoMerchantAPIEnvironmentDidChangeNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self.tableView reloadData];
}


#pragma mark Checkout Lifecycle

- (void)initializeBraintree {
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];

    self.braintree = nil;
    self.merchantId = nil;
    self.nonce = nil;
    self.lastTransactionId = nil;

    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [[BraintreeDemoMerchantAPI sharedService] createCustomerAndFetchClientTokenWithCompletion:^(NSString *clientToken, NSError *error){
        if (error) {
            [self displayError:error forTask:@"Fetching Client Token"];
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            return;
        }

        Braintree *braintree = [Braintree braintreeWithClientToken:clientToken];

        [[BraintreeDemoMerchantAPI sharedService] fetchMerchantConfigWithCompletion:^(NSString *merchantId, NSError *error){
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            [self.refreshControl endRefreshing];
            if (error) {
                [self displayError:error forTask:@"Fetching Merchant Config"];
                return;
            }

            [self resetWithBraintree:braintree merchantId:merchantId];
        }];
    }];
}

- (void)resetWithBraintree:(Braintree *)braintree merchantId:(NSString *)merchantId {
    self.braintree = braintree;
    self.merchantId = merchantId;
    self.nonce = nil;
    self.lastTransactionId = nil;
}

- (void)setNonce:(NSString *)nonce {
    _nonce = nonce;
    self.lastTransactionId = nil;
    [self.tableView reloadData];
}
- (void)setLastTransactionId:(NSString *)lastTransactionId {
    _lastTransactionId = lastTransactionId;
    [self.tableView reloadData];
}

- (void)displayError:(NSError *)error forTask:(NSString *)task {
    [[[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Error %@", task]
                                message:[error localizedDescription]
                               delegate:nil
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil] show];
    NSLog(@"Failed %@: %@", task, error);
}

- (BTDropInViewController *)configuredDropInViewController {
    BTDropInViewController *dropInViewController = [self.braintree dropInViewControllerWithDelegate:self];

    dropInViewController.title = @"Subscribe";
    dropInViewController.summaryTitle = @"Our Fancy Magazine";
    dropInViewController.summaryDescription = @"53 Week Subscription";
    dropInViewController.displayAmount = @"$19.00";
    dropInViewController.callToActionText = @"$19 - Subscribe Now";
    dropInViewController.shouldHideCallToAction = NO;

    return dropInViewController;
}

#pragma mark Table View Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
    UIViewController *demoViewController;

    if (selectedCell == self.dropInPaymentViewControllerCell) {
        // Drop-In (vanilla, no customization)
        demoViewController = [self configuredDropInViewController];
    } else if (selectedCell == self.customPayPalCell) {
        // Custom usage of PayPal Button
        demoViewController = [[BraintreeDemoOneTouchDemoViewController alloc] initWithBraintree:self.braintree completion:^(NSString *nonce) {
            self.nonce = nonce;
        }];
    } else if (selectedCell == self.tokenizationCell) {
        // Custom card Tokenization
        demoViewController = [[BraintreeDemoTokenizationDemoViewController alloc] initWithBraintree:self.braintree completion:^(NSString *nonce) {
            [self.navigationController popViewControllerAnimated:YES];
            self.nonce = nonce;
        }];
    } else if (selectedCell == self.directApplePayCell) {
        demoViewController = [[BraintreeDemoDirectApplePayIntegrationViewController alloc] initWithBraintree:self.braintree completion:^(NSString *nonce) {
            [self.navigationController popViewControllerAnimated:YES];
            self.nonce = nonce;
        }];
    } else if (selectedCell == self.makeATransactionCell) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];

        [self makeATransactionWithThreeDSecure:[BraintreeDemoSettings threeDSecureEnabled]];
    } else {
        return;
    }

    if (demoViewController) {
        if (self.useModalPresentation) {
            demoViewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelPresentedViewController:)];
            UINavigationController *vc = [[UINavigationController alloc] initWithRootViewController:demoViewController];

            [self presentViewController:vc animated:YES completion:nil];

        } else {
            [self.navigationController pushViewController:demoViewController
                                                 animated:YES];

        }
    }

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)cancelPresentedViewController:(__unused id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)tableView:(__unused UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(__unused NSIndexPath *)indexPath {
    if (cell == self.braintreeStatusCell) {
        cell.userInteractionEnabled = cell.textLabel.enabled = cell.detailTextLabel.enabled = (self.braintree != nil);
        cell.detailTextLabel.text = self.braintree ? [NSString stringWithFormat:@"%@", self.merchantId] : @"(nil)";
    } else if (cell == self.braintreePaymentMethodNonceCell) {
        cell.userInteractionEnabled = cell.textLabel.enabled = cell.detailTextLabel.enabled = (self.nonce != nil);
        cell.detailTextLabel.text = self.nonce ?: @"(nil)";
    } else if (cell == self.braintreeTransactionCell) {
        cell.userInteractionEnabled = cell.textLabel.enabled = cell.detailTextLabel.enabled = (self.lastTransactionId != nil);
        cell.detailTextLabel.text = self.lastTransactionId ?: @"(nil)";
    } else if (cell == self.makeATransactionCell) {
        cell.userInteractionEnabled = cell.textLabel.enabled = cell.detailTextLabel.enabled = (self.nonce != nil);
    } else if (cell == self.libraryVersionCell) {
        cell.textLabel.text = [NSString stringWithFormat:@"pod \"Braintree\", \"%@\"", [Braintree libraryVersion]];
    } else if (indexPath.section == 4) {
    } else {
        if (!self.braintree) {
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.userInteractionEnabled = NO;
            cell.textLabel.enabled = NO;
            cell.detailTextLabel.enabled = NO;
        } else {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.userInteractionEnabled = YES;
            cell.textLabel.enabled = YES;
            cell.detailTextLabel.enabled = YES;
        }
    }
}

#pragma mark UI Actions

- (IBAction)tappedEnvironmentSelector:(__unused UIBarButtonItem *)sender {
    IASKAppSettingsViewController *appSettingsViewController = [[IASKAppSettingsViewController alloc] init];
    appSettingsViewController.showDoneButton = NO;
    [self.navigationController pushViewController:appSettingsViewController animated:YES];
}

- (IBAction)tappedGiveFeedback {
    [[[BITHockeyManager sharedHockeyManager] feedbackManager] showFeedbackListView];
}

- (void)switchToEnvironment {
    NSString *environmentName;

    switch ([BraintreeDemoSettings currentEnvironment]) {
        case BraintreeDemoTransactionServiceEnvironmentSandboxBraintreeSampleMerchant:
            environmentName = @"Sandbox";
            break;
        case BraintreeDemoTransactionServiceEnvironmentProductionExecutiveSampleMerchant:
            environmentName = @"Production";
    }

    self.environmentSelector.title = environmentName;

    [self initializeBraintree];
}

#pragma mark -

- (void)makeATransactionWithThreeDSecure:(BOOL)enableThreeDSecure {
    if (enableThreeDSecure && [BraintreeDemoSettings threeDSecureEnabled]) {
        NSLog(@"Verifying card with 3D Secure...");
        self.threeDSecure = [[BTThreeDSecure alloc] initWithClient:self.braintree.client delegate:self];
        [self.threeDSecure verifyCardWithNonce:self.nonce amount:[NSDecimalNumber decimalNumberWithString:@"10"]];
    } else {
        [[BraintreeDemoMerchantAPI sharedService] makeTransactionWithPaymentMethodNonce:self.nonce
                                                                             completion:^(NSString *transactionId, NSError *error){
                                                                                 [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                                                                                 if (error) {
                                                                                     [self displayError:error forTask:@"Creating Transation"];
                                                                                 } else {
                                                                                     self.lastTransactionId = transactionId;
                                                                                     NSLog(@"Created transaction: %@", transactionId);
                                                                                     [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]
                                                                                                           atScrollPosition:UITableViewScrollPositionTop
                                                                                                                   animated:YES];
                                                                                 }
                                                                             }];
    }
}

#pragma mark Drop In View Controller Delegate

- (void)dropInViewController:(__unused BTDropInViewController *)viewController didSucceedWithPaymentMethod:(BTPaymentMethod *)paymentMethod {
    self.nonce = paymentMethod.nonce;
    if (self.useModalPresentation) {
        [viewController dismissViewControllerAnimated:YES completion:^{
            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]
                                  atScrollPosition:UITableViewScrollPositionTop
                                          animated:YES];
        }];
        
    } else {
        [self.navigationController popViewControllerAnimated:YES];
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]
                              atScrollPosition:UITableViewScrollPositionTop
                                      animated:YES];
    }
}

- (void)dropInViewControllerDidCancel:(__unused BTDropInViewController *)viewController {
    [self.navigationController popViewControllerAnimated:YES];
    [[[UIAlertView alloc] initWithTitle:@"Drop In Canceled"
                                message:nil
                               delegate:nil
                      cancelButtonTitle:@":("
                      otherButtonTitles:nil] show];
}


#pragma mark Payment Method Creation Delegate

- (void)paymentMethodCreator:(id)sender requestsPresentationOfViewController:(UIViewController *)viewController {
    if (sender == self.threeDSecure) {
        [self presentViewController:viewController animated:YES completion:nil];
        self.nonce = nil;
    }
}

- (void)paymentMethodCreator:(__unused id)sender requestsDismissalOfViewController:(UIViewController *)viewController {
    [viewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)paymentMethodCreator:(id)sender didCreatePaymentMethod:(BTPaymentMethod *)paymentMethod {
    if (sender == self.threeDSecure) {
        NSLog(@"3D Secure Completed");
        self.nonce = paymentMethod.nonce;
        [self makeATransactionWithThreeDSecure:NO];
    }
}

- (void)paymentMethodCreator:(id)sender didFailWithError:(NSError *)error {
    if (sender == self.threeDSecure) {
        [self displayError:error forTask:@"3D Secure"];
    }
}

- (void)paymentMethodCreatorDidCancel:(__unused id)sender {
    NSLog(@"3D Secure Canceled");
}

- (void)paymentMethodCreatorWillPerformAppSwitch:(__unused id)sender {
}

- (void)paymentMethodCreatorWillProcess:(__unused id)sender {
}

#pragma mark Settings

- (BOOL)useModalPresentation {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"BraintreeDemoChooserViewControllerShouldUseModalPresentationDefaultsKey"];
}

@end
