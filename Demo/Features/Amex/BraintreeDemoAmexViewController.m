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
    self.title = @"Amex";
}

- (UIView *)createPaymentButton {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:@"Get rewards balance" forState:UIControlStateNormal];
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
        NSDictionary *options = @{@"nonce": tokenized.nonce, @"currencyIsoCode": @"USD"};
        [self.amexClient getRewardsBalance:options completion:^(__unused NSDictionary * _Nullable payload, NSError * _Nullable error) {
            if (error) {
                self.progressBlock(error.localizedDescription);
            } else {
                self.progressBlock(@"Amex - received rewards balance");
            }
        }];
    }];

}

@end
