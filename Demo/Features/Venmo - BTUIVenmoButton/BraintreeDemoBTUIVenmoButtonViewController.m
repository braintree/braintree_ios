#import "BraintreeDemoBTUIVenmoButtonViewController.h"
#import <BraintreeVenmo/BraintreeVenmo.h>
#import <BraintreeUI/BraintreeUI.h>

@interface BraintreeDemoBTUIVenmoButtonViewController ()
@property (nonatomic, strong) BTUIVenmoButton *venmoButton;
@end

@implementation BraintreeDemoBTUIVenmoButtonViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"BTUIVenmoButton";
    self.venmoButton.hidden = YES;
    [self.apiClient fetchOrReturnRemoteConfiguration:^(BTConfiguration * _Nullable configuration, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                self.progressBlock(error.localizedDescription);
                NSLog(@"Failed to fetch configuration: %@", error);
                return;
            }
    
            [self checkVenmoBetaWhitelist:configuration];
        });
    }];
}

- (UIView *)createPaymentButton {
    if (!self.venmoButton) {
        self.venmoButton = [[BTUIVenmoButton alloc] init];
        [self.venmoButton addTarget:self action:@selector(tappedPayPalButton) forControlEvents:UIControlEventTouchUpInside];
    }
    return self.venmoButton;
}

- (void)checkVenmoBetaWhitelist:(BTConfiguration*)configuration {
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
                [BTConfiguration enableVenmo:true];
            } else {
                self.progressBlock(@"Venmo user is not whitelisted.");
                return;
            }
            
            if (configuration.isVenmoEnabled) {
                self.venmoButton.hidden = NO;
            } else {
                self.progressBlock(@"canCreatePaymentMethodWithProviderType returns NO, hiding Venmo button");
            }
        });
    }] resume];
}

- (void)tappedPayPalButton {
    self.progressBlock(@"Tapped Venmo - initiating Venmo auth");

    BTVenmoDriver *driver = [[BTVenmoDriver alloc] initWithAPIClient:self.apiClient];
    
    [driver authorizeAccountWithCompletion:^(BTVenmoAccountNonce * _Nullable venmoAccount, NSError * _Nullable error) {
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
