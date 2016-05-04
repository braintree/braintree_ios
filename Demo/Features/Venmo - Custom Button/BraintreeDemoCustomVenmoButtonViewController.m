#import "BraintreeDemoCustomVenmoButtonViewController.h"
#import <BraintreeVenmo/BraintreeVenmo.h>
#import <BraintreeUI/UIColor+BTUI.h>


@interface BraintreeDemoCustomVenmoButtonViewController ()
@property (nonatomic, strong) BTVenmoDriver *venmoDriver;
@end

@implementation BraintreeDemoCustomVenmoButtonViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.venmoDriver = [[BTVenmoDriver alloc] initWithAPIClient:self.apiClient];
    self.title = @"Custom Venmo Button";
    self.paymentButton.hidden = YES;
    [self checkVenmoBetaWhitelist];
}

- (UIView *)createPaymentButton {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:@"Venmo (custom button)" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor bt_colorFromHex:@"3D95CE" alpha:1.0f] forState:UIControlStateNormal];
    [button setTitleColor:[[UIColor bt_colorFromHex:@"3D95CE" alpha:1.0f] bt_adjustedBrightness:0.7] forState:UIControlStateHighlighted];
    [button addTarget:self action:@selector(tappedCustomVenmo) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (void)checkVenmoBetaWhitelist {
    NSError *error;
    NSString *phone = @"";
    NSString *email = @"johndoe@venmo.com";
    
    NSMutableURLRequest *venmoWhitelistRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://api.venmo.com/pwv-whitelist"]];
    [venmoWhitelistRequest setHTTPMethod:@"POST"];
    NSData *postData = [NSJSONSerialization dataWithJSONObject:@{@"email": email, @"phone": phone} options:0 error:&error];
    [venmoWhitelistRequest setHTTPBody:postData];
    [venmoWhitelistRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    [[[NSURLSession sharedSession] dataTaskWithRequest:venmoWhitelistRequest completionHandler:^(__unused NSData * _Nullable data, NSURLResponse * _Nullable response, __unused NSError * _Nullable error) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (httpResponse.statusCode == 200) {
                // This email/phone is whitelist for the Pay with Venmo beta
                [BTConfiguration enableVenmo:true];
            } else {
                self.progressBlock(@"Venmo user is not whitelisted.");
                return;
            }
            
            if ([self.venmoDriver isiOSAppAvailableForAppSwitch]) {
                self.paymentButton.hidden = NO;
            } else {
                self.progressBlock(@"Venmo app is not installed.");
            }
        });
    }] resume];
}

- (void)tappedCustomVenmo {
    self.progressBlock(@"Tapped Venmo - initiating Venmo auth");
    [self.venmoDriver authorizeAccountWithCompletion:^(BTVenmoAccountNonce * _Nullable venmoAccount, NSError * _Nullable error) {
        if (venmoAccount) {
            self.progressBlock(@"Got a nonce 💎!");
            NSLog(@"%@", [venmoAccount debugDescription]);
            self.completionBlock(venmoAccount);
        } else if (error) {
            self.progressBlock(error.localizedDescription);
        } else {
            self.progressBlock(@"Canceled 🔰");
        }
    }];
}

@end
