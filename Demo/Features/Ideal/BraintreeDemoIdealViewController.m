#import "BraintreeDemoIdealViewController.h"
#import <BraintreePaymentFlow/BraintreePaymentFlow.h>
#import <BraintreeUI/UIColor+BTUI.h>
#import "BraintreeDemoMerchantAPI.h"

@interface BraintreeDemoIdealViewController () <BTViewControllerPresentingDelegate, BTIdealRequestDelegate>
@property (nonatomic, strong) BTPaymentFlowDriver *paymentFlowDriver;
@property (nonatomic, weak) UILabel *paymentIDLabel;
@end

@implementation BraintreeDemoIdealViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.progressBlock(@"Loading iDEAL Merchant Account...");
    self.paymentButton.hidden = YES;
    [self setUpPaymentIDField];
    [[BraintreeDemoMerchantAPI sharedService] fetchClientTokenWithMerchantAccountId:@"ideal_eur" completion:^(__unused NSString * clientToken, NSError *error) {
        if (error) {
            NSLog(@"%@", error);
        } else {
            self.paymentButton.hidden = NO;
            self.progressBlock(@"Ready!");
            BTAPIClient *idealClient = [[BTAPIClient alloc] initWithAuthorization:clientToken];
            self.paymentFlowDriver = [[BTPaymentFlowDriver alloc] initWithAPIClient:idealClient];
            self.paymentFlowDriver.viewControllerPresentingDelegate = self;
        }
    }];
    
    self.title = NSLocalizedString(@"iDEAL", nil);
}

- (UIView *)createPaymentButton {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:NSLocalizedString(@"Pay With iDEAL", nil) forState:UIControlStateNormal];
    [button setTitleColor:[UIColor bt_colorFromHex:@"3D95CE" alpha:1.0f] forState:UIControlStateNormal];
    [button setTitleColor:[[UIColor bt_colorFromHex:@"3D95CE" alpha:1.0f] bt_adjustedBrightness:0.7] forState:UIControlStateHighlighted];
    [button addTarget:self action:@selector(idealButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (void)setUpPaymentIDField {
    UILabel *paymentIDLabel = [[UILabel alloc] init];
    paymentIDLabel.translatesAutoresizingMaskIntoConstraints = NO;
    paymentIDLabel.numberOfLines = 0;
    [self.view addSubview:paymentIDLabel];
    [paymentIDLabel.leadingAnchor constraintEqualToAnchor:self.view.layoutMarginsGuide.leadingAnchor constant:8.0].active = YES;
    [paymentIDLabel.trailingAnchor constraintEqualToAnchor:self.view.layoutMarginsGuide.trailingAnchor constant:8.0].active = YES;
    [paymentIDLabel.topAnchor constraintEqualToAnchor:self.paymentButton.bottomAnchor constant:8.0].active = YES;
    [paymentIDLabel.bottomAnchor constraintEqualToAnchor:self.view.layoutMarginsGuide.bottomAnchor constant:8.0].active = YES;
    self.paymentIDLabel = paymentIDLabel;
}

- (void)idealButtonTapped {
    self.paymentIDLabel.text = nil;

    [self.paymentFlowDriver fetchIssuingBanks:^(NSArray<BTIdealBank *> * _Nullable banks, NSError * _Nullable error) {
        if (error) {
            self.progressBlock([NSString stringWithFormat:@"Error: %@", error]);
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
                [actionSheet addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:^(__unused UIAlertAction *action) {
                    //noop
                }]];
                
                for (BTIdealBank *bank in banks) {
                    UIAlertAction *alertAction = [UIAlertAction actionWithTitle:bank.name style:UIAlertActionStyleDefault handler:^(__unused UIAlertAction *action) {
                        
                        [self startPaymentWithBank:bank];
                    }];
                    
                    NSURL *url = [NSURL URLWithString:bank.imageUrl];
                    NSData *data = [NSData dataWithContentsOfURL:url];
                    UIImage *image = [UIImage imageWithData:data scale:2.25];
                    [alertAction setValue:[image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forKey:@"image"];
                    [actionSheet addAction:alertAction];
                }
                
                [self presentViewController:actionSheet animated:YES completion:nil];
            });
        }
    }];
}

- (void)startPaymentWithBank:(BTIdealBank *)bank {
    BTIdealRequest *request = [[BTIdealRequest alloc] init];
    request.orderId = [[[NSUUID UUID] UUIDString] substringToIndex:16];
    request.currency = @"EUR";
    request.amount = @"1.00";
    request.issuer = bank.issuerId;
    request.idealPaymentFlowDelegate = self;
    [self.paymentFlowDriver startPaymentFlow:request completion:^(BTPaymentFlowResult * _Nonnull result, NSError * _Nonnull error) {
        if (error) {
            if (error.code == BTPaymentFlowDriverErrorTypeCanceled) {
                self.progressBlock(@"Cancelled🎲");
            } else {
                self.progressBlock([NSString stringWithFormat:@"Error: %@", error]);
            }
        } else if (result) {
            BTIdealResult *idealResult = (BTIdealResult *)result;
            NSLog(@"%@", idealResult);
            
            [self.paymentFlowDriver pollForCompletionWithId:idealResult.idealId retries:7 delay:5000 completion:^(BTPaymentFlowResult * _Nullable result, NSError * _Nullable error) {
                BTIdealResult *idealResult = (BTIdealResult *)result;
                if (error) {
                    // ERROR
                    self.progressBlock([NSString stringWithFormat:@"Error: %@", error]);
                } else {
                    NSLog(@"Ideal Status: %@", idealResult.status);
                    NSLog(@"Ideal ID: %@", idealResult.idealId);
                    NSLog(@"Ideal Short ID: %@", idealResult.shortIdealId);
                    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:idealResult.status message:idealResult.idealId preferredStyle:UIAlertControllerStyleActionSheet];
                    [self presentViewController:actionSheet animated:YES completion:nil];
                    [actionSheet addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault handler:^(__unused UIAlertAction *action) {
                        //noop
                    }]];
                    self.progressBlock([NSString stringWithFormat:@"iDEAL Status: %@", idealResult.status]);
                }
            }];
        }
    }];
}

#pragma mark BTAppSwitchDelegate

- (void)paymentDriver:(__unused id)driver requestsPresentationOfViewController:(UIViewController *)viewController {
    [self presentViewController:viewController animated:YES completion:nil];
}

- (void)paymentDriver:(__unused id)driver requestsDismissalOfViewController:(UIViewController *)viewController {
    [viewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark BTIdealRequestDelegate

- (void)idealPaymentStarted:(BTIdealResult *)result {
    self.paymentIDLabel.text = [NSString stringWithFormat:@"Started payment: %@ %@", [result status], [result idealId]];
}

@end
