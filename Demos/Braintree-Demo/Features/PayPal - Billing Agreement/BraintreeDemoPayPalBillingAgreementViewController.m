#import "BraintreeDemoPayPalBillingAgreementViewController.h"

#import <Braintree/Braintree.h>
#import "BTPayPalDriver.h"

@interface BraintreeDemoPayPalBillingAgreementViewController () <BTPayPalDriverDelegate>

@property (nonatomic, strong) BTPayPalDriver *payPalDriver;
@end

@implementation BraintreeDemoPayPalBillingAgreementViewController

- (instancetype)initWithClientToken:(NSString *)clientToken {
    self = [super initWithClientToken:clientToken];
    if (self) {
        BTClient *client = [[BTClient alloc] initWithClientToken:clientToken];
        self.payPalDriver = [[BTPayPalDriver alloc] initWithClient:client returnURLScheme:@"com.braintreepayments.Braintree-Demo.payments"];
        self.payPalDriver.delegate = self;
    }
    return self;
}

- (UIView *)paymentButton {
    if (self.payPalDriver) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setTitle:@"Start Billing Agreement Flow" forState:UIControlStateNormal];
        [button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor colorWithRed:50.0/255 green:50.0/255 blue:255.0/255 alpha:1.0] forState:UIControlStateHighlighted];
        [button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
        [button addTarget:self action:@selector(tappedPayPalBillingAgreement:) forControlEvents:UIControlEventTouchUpInside];
        return button;
    } else {
        self.progressBlock(@"Failed to initialize BTPayPalDriver");
        return nil;
    }
}

- (void)tappedPayPalBillingAgreement:(UIButton *)sender {
    self.progressBlock(@"Tapped PayPal - initiating checkout using BTPayPalDriver");
    BTPayPalCheckout *checkout = [[BTPayPalCheckout alloc] init];
    checkout.isSingleUse = NO;
    [self.payPalDriver startCheckout:checkout completion:^(BTPayPalPaymentMethod *paymentMethod, NSError *error) {
        [sender setEnabled:YES];
        if (error) {
            self.progressBlock(error.localizedDescription);
        } else if (paymentMethod) {
            self.completionBlock(paymentMethod);
        } else {
            self.progressBlock(@"Cancelled");
        }
    }];
    
    [sender setTitle:@"Processing..." forState:UIControlStateDisabled];
    [sender setEnabled:NO];
}

#pragma mark BTPayPalDriverDelegate

- (void)payPalDriverWillPerformAppSwitch:(__unused BTPayPalDriver *)payPalDriver {
    self.progressBlock(@"payPalDriverWillPerformAppSwitch:");
}

- (void)payPalDriverWillProcessAppSwitchResult:(__unused BTPayPalDriver *)payPalDriver {
    self.progressBlock(@"payPalDriverWillProcessAppSwitchResult:");
}

- (void)payPalDriver:(__unused BTPayPalDriver *)payPalDriver didPerformAppSwitchToTarget:(BTPayPalDriverAppSwitchTarget)target {
    switch (target) {
        case BTPayPalDriverAppSwitchTargetBrowser:
            self.progressBlock(@"payPalDriver:didPerformAppSwitchToTarget: browser");
            break;
        case BTPayPalDriverAppSwitchTargetPayPalApp:
            self.progressBlock(@"payPalDriver:didPerformAppSwitchToTarget: app");
            break;
    }
}


@end
