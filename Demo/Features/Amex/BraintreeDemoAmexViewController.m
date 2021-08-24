#import "BraintreeDemoAmexViewController.h"
#import <BraintreeCard/BraintreeCard.h>
#import <BraintreeAmericanExpress/BraintreeAmericanExpress.h>
#import <BraintreeUI/UIColor+BTUI.h>

@interface BraintreeDemoAmexViewController ()
@property (nonatomic, strong) BTAmericanExpressClient *amexClient;
@end

@implementation BraintreeDemoAmexViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.amexClient = [[BTAmericanExpressClient alloc] initWithAPIClient:self.apiClient];
    self.title = NSLocalizedString(@"Amex", nil);
}

- (UIView *)createPaymentButton {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:NSLocalizedString(@"Get rewards balance", nil) forState:UIControlStateNormal];
    [button setTitleColor:[UIColor bt_colorFromHex:@"3D95CE" alpha:1.0f] forState:UIControlStateNormal];
    [button setTitleColor:[[UIColor bt_colorFromHex:@"3D95CE" alpha:1.0f] bt_adjustedBrightness:0.7] forState:UIControlStateHighlighted];
    [button addTarget:self action:@selector(tapped) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (void)tapped {
    BTCardClient *cardClient = [[BTCardClient alloc] initWithAPIClient:self.apiClient];
    BTCard *card = [[BTCard alloc] initWithNumber:@"371260714673002"
                                  expirationMonth:@"12"
                                   expirationYear:@"2020"
                                              cvv:@"1234"];

    self.progressBlock(@"Tokenizing Card");
    [cardClient tokenizeCard:card completion:^(BTCardNonce *tokenized, NSError *error) {
        if (error) {
            self.progressBlock(error.localizedDescription);
            NSLog(@"Error: %@", error);
            return;
        }

        self.progressBlock(@"Amex - getting rewards balance");
        [self.amexClient getRewardsBalanceForNonce:tokenized.nonce currencyIsoCode:@"USD" completion:^(__unused BTAmericanExpressRewardsBalance * _Nullable rewardsBalance, NSError * _Nullable error) {
            if (error) {
                self.progressBlock(error.localizedDescription);
            } else {
                self.progressBlock(@"Amex - received rewards balance");
            }
        }];
    }];

}

@end
