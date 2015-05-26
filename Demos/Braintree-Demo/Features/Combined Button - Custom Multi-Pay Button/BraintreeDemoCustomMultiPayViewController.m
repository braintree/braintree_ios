#import "BraintreeDemoCustomMultiPayViewController.h"

#import <PureLayout/ALView+PureLayout.h>
#import <Braintree/Braintree.h>
#import <Braintree/UIColor+BTUI.h>

@interface BraintreeDemoCustomMultiPayViewController ()
@property(nonatomic, strong) BTPaymentProvider *paymentProvider;
@property(nonatomic, strong) BTUICardFormView *cardForm;
@property (nonatomic, strong) UINavigationController *cardFormNavigationViewController;
@end

@implementation BraintreeDemoCustomMultiPayViewController

- (instancetype)initWithClientToken:(NSString *)clientToken {
    self = [super initWithClientToken:clientToken];
    if (self) {
        self.paymentProvider = [self.braintree paymentProviderWithDelegate:self];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Custom Button+BTPaymentProvider";
}

- (UIView *)paymentButton {
    UIView *view = [[UIView alloc] initForAutoLayout];

    UIButton *venmoButton = [UIButton buttonWithType:UIButtonTypeSystem];
    venmoButton.translatesAutoresizingMaskIntoConstraints = NO;
    venmoButton.titleLabel.font = [UIFont fontWithName:@"AmericanTypewriter" size:[UIFont systemFontSize]];
    venmoButton.backgroundColor = [[BTUI braintreeTheme] venmoPrimaryBlue];
    [venmoButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [venmoButton setTitle:@"Venmo" forState:UIControlStateNormal];
    venmoButton.tag = BTPaymentProviderTypeVenmo;

    UIButton *payPalButton = [UIButton buttonWithType:UIButtonTypeSystem];
    payPalButton.translatesAutoresizingMaskIntoConstraints = NO;
    payPalButton.titleLabel.font = [UIFont fontWithName:@"GillSans-BoldItalic" size:[UIFont systemFontSize]];
    payPalButton.backgroundColor = [[BTUI braintreeTheme] palBlue];
    [payPalButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [payPalButton setTitle:@"PayPal" forState:UIControlStateNormal];
    payPalButton.tag = BTPaymentProviderTypePayPal;

    UIButton *cardButton = [UIButton buttonWithType:UIButtonTypeSystem];
    cardButton.translatesAutoresizingMaskIntoConstraints = NO;
    cardButton.backgroundColor = [UIColor bt_colorFromHex:@"DDDECB" alpha:1.0f];
    [cardButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [cardButton setTitle:@"💳" forState:UIControlStateNormal];
    cardButton.tag = -1;

    [venmoButton addTarget:self action:@selector(tapped:) forControlEvents:UIControlEventTouchUpInside];
    [payPalButton addTarget:self action:@selector(tapped:) forControlEvents:UIControlEventTouchUpInside];
    [cardButton addTarget:self action:@selector(tapped:) forControlEvents:UIControlEventTouchUpInside];

    [view addSubview:payPalButton];
    [view addSubview:venmoButton];
    [view addSubview:cardButton];

    [venmoButton autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:payPalButton];
    [payPalButton autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:cardButton];

    [venmoButton autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:0];
    [venmoButton autoPinEdge:ALEdgeRight toEdge:ALEdgeLeft ofView:payPalButton];
    [payPalButton autoPinEdge:ALEdgeRight toEdge:ALEdgeLeft ofView:cardButton];
    [cardButton autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:0];

    [venmoButton autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:0];
    [venmoButton autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:0];
    [payPalButton autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:0];
    [payPalButton autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:0];
    [cardButton autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:0];
    [cardButton autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:0];

    [view autoMatchDimension:ALDimensionHeight toDimension:ALDimensionHeight ofView:venmoButton];

    return view;
}

- (void)tapped:(UIButton *)sender {
    if (sender.tag == -1) {
        self.cardForm = [[BTUICardFormView alloc] initForAutoLayout];
        self.cardForm.optionalFields = BTUICardFormOptionalFieldsAll;

        UIViewController *cardFormViewController = [[UIViewController alloc] init];
        cardFormViewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                                                target:self
                                                                                                                action:@selector(cancelCardVC)];
        cardFormViewController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                                                                                                 target:self
                                                                                                                 action:@selector(saveCardVC)];
        cardFormViewController.navigationItem.rightBarButtonItem.style = UIBarButtonItemStyleDone;

        cardFormViewController.title = @"💳";
        [cardFormViewController.view addSubview:self.cardForm];
        cardFormViewController.view.backgroundColor = sender.backgroundColor;

        [self.cardForm autoPinToTopLayoutGuideOfViewController:cardFormViewController withInset:40];
        [self.cardForm autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:0];
        [self.cardForm autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:0];

        self.cardFormNavigationViewController = [[UINavigationController alloc] initWithRootViewController:cardFormViewController];

        [self paymentMethodCreator:self requestsPresentationOfViewController:self.cardFormNavigationViewController];
    } else {
        [self.paymentProvider createPaymentMethod:sender.tag];
    }
}

- (void)cancelCardVC {
    [self paymentMethodCreator:self requestsDismissalOfViewController:self.cardFormNavigationViewController];
}

- (void)saveCardVC {
    [self cancelCardVC];

    BTClientCardRequest *request = [[BTClientCardRequest alloc] init];
    request.number = self.cardForm.number;
    request.expirationMonth = self.cardForm.expirationMonth;
    request.expirationYear = self.cardForm.expirationYear;
    request.cvv = self.cardForm.cvv;
    request.postalCode = self.cardForm.postalCode;
    request.shouldValidate = NO;

    [self.braintree.client saveCardWithRequest:request
                                       success:^(BTCardPaymentMethod *card) {
                                           [self paymentMethodCreator:self didCreatePaymentMethod:card];
                                       }
                                       failure:^(NSError *error) {
                                           [self paymentMethodCreator:self didFailWithError:error];
                                       }];
}


@end
