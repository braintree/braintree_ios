#import "BraintreeDemoChooserViewController.h"

#import <Braintree/Braintree.h>
#import <UIActionSheet+Blocks/UIActionSheet+Blocks.h>

#import "BraintreeDemoBraintreeInitializationDemoViewController.h"
#import "BraintreeDemoPayPalButtonDemoViewController.h"
#import "BraintreeDemoTokenizationDemoViewController.h"
#import "BraintreeDemoTransactionService.h"

@interface BraintreeDemoChooserViewController () <BTDropInViewControllerDelegate>

@property (nonatomic, weak) IBOutlet UIBarButtonItem *environmentSelector;

#pragma mark Status Cells
@property (nonatomic, weak) IBOutlet UITableViewCell *braintreeStatusCell;
@property (nonatomic, weak) IBOutlet UITableViewCell *braintreePaymentMethodNonceCell;
@property (nonatomic, weak) IBOutlet UITableViewCell *braintreeTransactionCell;

#pragma mark Initialization Cells

@property (nonatomic, weak) IBOutlet UITableViewCell *initializeBraintreeCell;

#pragma mark Drop-In Use Case Cells

@property (nonatomic, weak) IBOutlet UITableViewCell *dropInPaymentViewControllerCell;
@property (nonatomic, weak) IBOutlet UITableViewCell *customPayPalCell;

#pragma mark Custom Use Case Cells

@property (nonatomic, weak) IBOutlet UITableViewCell *tokenizationCell;

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

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self.tableView reloadData];
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithWhite:42/255.0f alpha:1.0f]; // 2a2a2a
    [self.navigationController.navigationBar setBarStyle:UIBarStyleBlack];
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
    UIViewController *demoViewController;

    if (selectedCell == self.initializeBraintreeCell) {
        // Initialize Braintree
        demoViewController = [[BraintreeDemoBraintreeInitializationDemoViewController alloc] initWithCompletion:^(Braintree *braintree, NSString *merchantId, NSError *error){
            self.braintree = braintree;
            self.merchantId = merchantId;
            self.nonce = nil;
            self.lastTransactionId = nil;
            if (error) {
                NSLog(@"Error initializing Braintree: %@", error);
            }
        }];
    } else if (selectedCell == self.dropInPaymentViewControllerCell) {
        // Drop-In (vanilla, no customization)
        demoViewController = [self configuredDropInViewController];
    } else if (selectedCell == self.customPayPalCell) {
        // Custom usage of PayPal Button
        demoViewController = [[BraintreeDemoPayPalButtonDemoViewController alloc] initWithBraintree:self.braintree];
    } else if (selectedCell == self.tokenizationCell) {
        // Custom card Tokenization
        demoViewController = [[BraintreeDemoTokenizationDemoViewController alloc] initWithBraintree:self.braintree completion:^(__unused BraintreeDemoTokenizationDemoViewController *viewController, NSString *nonce) {
            self.nonce = nonce;
            [self.navigationController popViewControllerAnimated:YES];
        }];
    } else if (selectedCell == self.makeATransactionCell) {
        [[BraintreeDemoTransactionService sharedService]
         makeTransactionWithPaymentMethodNonce:self.nonce
         completion:^(NSString *transactionId, NSError *error){
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
        cell.detailTextLabel.text = self.braintree ? [NSString stringWithFormat:@"Initialized for merchant: %@", self.merchantId] : @"(nil)";
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
        if (!self.braintree && cell != self.initializeBraintreeCell) {
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
                                    NSString *environmentName;
                                    
                                    if (buttonIndex == 1) {
                                        environment = BraintreeDemoTransactionServiceEnvironmentProductionExecutiveSampleMerchant;
                                        environmentName = self.environmentSelector.title = @"Production";
                                    } else {
                                        environment = BraintreeDemoTransactionServiceEnvironmentSandboxBraintreeSampleMerchant;
                                        environmentName = @"Sandbox";
                                    }

                                    [[BraintreeDemoTransactionService sharedService] setEnvironment:environment];
                                    self.environmentSelector.title = environmentName;
                                    self.braintree = nil;
                                    self.merchantId = nil;
                                    self.nonce = nil;
                                    self.lastTransactionId = nil;
                                }];
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
