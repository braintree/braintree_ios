#import "BraintreeDemoApplePayPaymentProviderViewController.h"
#import "ALView+PureLayout.h"

#import <Braintree/Braintree.h>

@interface BraintreeDemoApplePayPaymentProviderViewController ()
@property(nonatomic, strong) BTPaymentProvider *paymentProvider;
@end

@implementation BraintreeDemoApplePayPaymentProviderViewController

- (instancetype)initWithClientToken:(NSString *)clientToken {
    self = [super initWithClientToken:clientToken];
    if (self) {
        self.paymentProvider = [self.braintree paymentProviderWithDelegate:self];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Apple Pay via BTPaymentProvider";
}

- (UIView *)paymentButton {
    if ([self.paymentProvider canCreatePaymentMethodWithProviderType:BTPaymentProviderTypeApplePay]) {
        UIButton *customButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [customButton setTitle:@"Apple Pay (Custom Button)" forState:UIControlStateNormal];
        [customButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
        [customButton setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
        [customButton setContentEdgeInsets:UIEdgeInsetsMake(20, 20, 20, 20)];
        [customButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [customButton setBackgroundColor:[UIColor blackColor]];
        customButton.layer.cornerRadius = 8;
        [customButton addTarget:self action:@selector(tappedApplePayButton) forControlEvents:UIControlEventTouchUpInside];

        UIView *applePayButtonsContainer = [[UIView alloc] initForAutoLayout];
        [applePayButtonsContainer addSubview:customButton];

        [customButton autoAlignAxisToSuperviewMarginAxis:ALAxisVertical];
        [customButton autoPinEdgeToSuperviewMargin:ALEdgeTop];

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80300
        if ([PKPaymentButton class]) {
            UIButton *officialButton = [PKPaymentButton buttonWithType:PKPaymentButtonTypePlain style:PKPaymentButtonStyleBlack];
            [officialButton addTarget:self action:@selector(tappedApplePayButton) forControlEvents:UIControlEventTouchUpInside];
            [applePayButtonsContainer addSubview:officialButton];
            [officialButton autoAlignAxisToSuperviewMarginAxis:ALAxisVertical];
            [officialButton autoPinEdgeToSuperviewMargin:ALEdgeBottom];
            
            [customButton autoPinEdge:ALEdgeBottom toEdge:ALEdgeTop ofView:officialButton withOffset:-50];
        } else {
#else
        if (false) {
#endif
            [customButton autoPinEdgeToSuperviewMargin:ALEdgeBottom];
        }

        return applePayButtonsContainer;
    } else {
        self.progressBlock(@"canCreatePaymentMethodWithProviderType returns NO, hiding Apple Pay button");
        return nil;
    }
}

- (void)tappedApplePayButton {
    PKPaymentSummaryItem *testTotal = [PKPaymentSummaryItem summaryItemWithLabel:@"BRAINTREE" amount:[NSDecimalNumber decimalNumberWithString:@"10"]];
    [self.paymentProvider setPaymentSummaryItems:@[testTotal]];

    [self.paymentProvider createPaymentMethod:BTPaymentProviderTypeApplePay];
}

@end
