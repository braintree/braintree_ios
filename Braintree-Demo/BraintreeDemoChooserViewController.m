#import "BraintreeDemoChooserViewController.h"

#import <HockeySDK/HockeySDK.h>
#import <Braintree/Braintree.h>
#import <UIActionSheet+Blocks/UIActionSheet+Blocks.h>

#import "BraintreeDemoBraintreeInitializationDemoViewController.h"
#import "BraintreeDemoOneTouchDemoViewController.h"
#import "BraintreeDemoTokenizationDemoViewController.h"
#import "BraintreeDemoDirectApplePayIntegrationViewController.h"

#import "BraintreeDemoTransactionService.h"
#import "BTClient_Internal.h"

@interface BraintreeDemoChooserViewController () <BTDropInViewControllerDelegate>

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

@end

@implementation BraintreeDemoChooserViewController

- (void)viewDidLoad {
    [self switchToEnvironment:[BraintreeDemoTransactionService mostRecentlyUsedEnvironment]];

    [self initializeBraintree];
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
    [[BraintreeDemoTransactionService sharedService] createCustomerAndFetchClientTokenWithCompletion:^(NSString *clientToken, NSError *error){
        if (error) {
            [self displayError:error forTask:@"Fetching Client Token"];
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            return;
        }

        Braintree *braintree = [Braintree braintreeWithClientToken:clientToken];

        [[BraintreeDemoTransactionService sharedService] fetchMerchantConfigWithCompletion:^(NSString *merchantId, NSError *error){
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
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
    dropInViewController.summaryTitle = @"App Fancy Magazine";
    dropInViewController.summaryDescription = @"53 Week Subscription";
    dropInViewController.displayAmount = [NSNumberFormatter localizedStringFromNumber:@(19) numberStyle:NSNumberFormatterCurrencyStyle];
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
        [[BraintreeDemoTransactionService sharedService]
         makeTransactionWithPaymentMethodNonce:self.nonce
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

    if (demoViewController) {
        [self.navigationController pushViewController:demoViewController
                                             animated:YES];
    }

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
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

- (IBAction)tappedEnvironmentSelector:(UIBarButtonItem *)sender {
    [UIActionSheet showFromBarButtonItem:sender
                                animated:YES
                               withTitle:@"Choose a Merchant Server Environment"
                       cancelButtonTitle:@"Cancel"
                  destructiveButtonTitle:nil
                       otherButtonTitles:@[@"Sandbox Merchant", @"Production Merchant"]
                                tapBlock:^(UIActionSheet *actionSheet, NSInteger buttonIndex) {
                                    if (buttonIndex == actionSheet.cancelButtonIndex) {
                                        return;
                                    }

                                    BraintreeDemoTransactionServiceEnvironment environment;

                                    if (buttonIndex == 1) {
                                        environment = BraintreeDemoTransactionServiceEnvironmentProductionExecutiveSampleMerchant;
                                    } else {
                                        environment = BraintreeDemoTransactionServiceEnvironmentSandboxBraintreeSampleMerchant;
                                    }

                                    [self switchToEnvironment:environment];
                                }];
}

- (IBAction)tappedGiveFeedback {
    [[[BITHockeyManager sharedHockeyManager] feedbackManager] showFeedbackListView];
}

- (void)switchToEnvironment:(BraintreeDemoTransactionServiceEnvironment)environment {
    NSString *environmentName;

    switch (environment) {
        case BraintreeDemoTransactionServiceEnvironmentSandboxBraintreeSampleMerchant:
            environmentName = @"Sandbox";
            break;
        case BraintreeDemoTransactionServiceEnvironmentProductionExecutiveSampleMerchant:
            environmentName = @"Production";
    }

    [[BraintreeDemoTransactionService sharedService] setEnvironment:environment];
    self.environmentSelector.title = environmentName;

    [self initializeBraintree];
}


#pragma mark Drop In View Controller Delegate

- (void)dropInViewController:(__unused BTDropInViewController *)viewController didSucceedWithPaymentMethod:(BTPaymentMethod *)paymentMethod {
    self.nonce = paymentMethod.nonce;
    [self.navigationController popViewControllerAnimated:YES];
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]
                          atScrollPosition:UITableViewScrollPositionTop
                                  animated:YES];
}

- (void)dropInViewControllerDidCancel:(__unused BTDropInViewController *)viewController {
    [self.navigationController popViewControllerAnimated:YES];
    [[[UIAlertView alloc] initWithTitle:@"Drop In Canceled"
                                message:nil
                               delegate:nil
                      cancelButtonTitle:@":("
                      otherButtonTitles:nil] show];
}

@end
