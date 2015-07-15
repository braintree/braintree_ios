#import "BraintreeDemoScopesPayPalButtonViewController.h"

#import <Braintree/Braintree-Payments.h>
#import <Braintree/UIColor+BTUI.h>

@interface BraintreeDemoScopesPayPalButtonViewController ()
@property(nonatomic, strong) BTPaymentProvider *paymentProvider;
@property(nonatomic, strong) UITextView *addressTextView;
@end

@implementation BraintreeDemoScopesPayPalButtonViewController

- (instancetype)initWithClientToken:(NSString *)clientToken {
    self = [super initWithClientToken:clientToken];
    if (self) {
        self.paymentProvider = [self.braintree paymentProviderWithDelegate:self];
        
        self.addressTextView = [[UITextView alloc] initWithFrame:CGRectMake((self.view.bounds.size.width / 2) - 100, (self.view.bounds.size.width / 8) * 7, 200, 100)];
        [self.view addSubview:self.addressTextView];
        self.addressTextView.backgroundColor = [UIColor clearColor];
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
    self.progressBlock(@"Tapped PayPal - initiating PayPal auth using BTPaymentProvider");
    self.braintree.client.additionalPayPalScopes = [NSSet setWithObjects:BTPayPalScopeAddress, nil];
    [self.paymentProvider createPaymentMethod:BTPaymentProviderTypePayPal];
}

- (void)paymentMethodCreator:(id)sender didCreatePaymentMethod:(BTPaymentMethod *)paymentMethod {
    [super paymentMethodCreator:sender didCreatePaymentMethod:paymentMethod];
    
    BTPostalAddress *address = ((BTPayPalPaymentMethod *)paymentMethod).billingAddress;
    self.addressTextView.text = [NSString stringWithFormat:@"Address:\n%@\n%@\n%@ %@\n%@ %@", address.streetAddress, address.extendedAddress, address.locality, address.region, address.postalCode, address.countryCodeAlpha2];
}


@end
