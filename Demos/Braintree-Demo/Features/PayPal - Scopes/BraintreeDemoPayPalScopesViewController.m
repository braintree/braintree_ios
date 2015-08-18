#import "BraintreeDemoPayPalScopesViewController.h"

#import <BraintreeCore/BraintreeCore.h>
#import <BraintreeUI/UIColor+BTUI.h>

#import "BTPayPalDriver.h"
#import "BTAppSwitch.h"

@interface BraintreeDemoPayPalScopesViewController ()
@property(nonatomic, strong) BTPaymentProvider *paymentProvider;
@property(nonatomic, strong) UITextView *addressTextView;
@end

@implementation BraintreeDemoPayPalScopesViewController

- (instancetype)initWithClientToken:(NSString *)clientToken {
    self = [super initWithClientToken:clientToken];
    if (self) {
        self.paymentProvider = [self.braintree paymentProviderWithDelegate:self];
        self.addressTextView = [[UITextView alloc] initWithFrame:CGRectMake((self.view.bounds.size.width / 2) - 100, (self.view.bounds.size.width / 8) * 7, 200, 100)];
        [self.view addSubview:self.addressTextView];
        self.addressTextView.backgroundColor = [UIColor clearColor];
        self.addressTextView.editable = NO;
    }
    return self;
}

- (UIView *)paymentButton {
    if ([self.paymentProvider canCreatePaymentMethodWithProviderType:BTPaymentProviderTypePayPal]) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setTitle:@"PayPal (Address Scope)" forState:UIControlStateNormal];
        [button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [button setTitleColor:[[UIColor blueColor] bt_adjustedBrightness:0.5] forState:UIControlStateHighlighted];
        [button addTarget:self action:@selector(tappedCustomPayPal) forControlEvents:UIControlEventTouchUpInside];
        return button;
    } else {
        return nil;
    }
}

- (void)tappedCustomPayPal {

    BTPayPalDriver *driver = [[BTPayPalDriver alloc] initWithClient:self.braintree.client returnURLScheme:[BTAppSwitch sharedInstance].returnURLScheme];
    self.progressBlock(@"Tapped PayPal - initiating authorization using BTPayPalDriver");
    [driver startAuthorizationWithAdditionalScopes:[NSSet setWithObjects:@"address", nil] completion:^(BTPayPalPaymentMethod *paymentMethod, NSError *error) {
        if (error) {
            self.progressBlock(error.localizedDescription);
        } else if (paymentMethod) {
            self.completionBlock(paymentMethod);
            
            BTPostalAddress *address = paymentMethod.billingAddress;
            self.addressTextView.text = [NSString stringWithFormat:@"Address:\n%@\n%@\n%@ %@\n%@ %@", address.streetAddress, address.extendedAddress, address.locality, address.region, address.postalCode, address.countryCodeAlpha2];
            
        } else {
            self.progressBlock(@"Cancelled");
        }
    }];
}

@end
