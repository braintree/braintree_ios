#import "BraintreeDemoCustomMultiPaymentButtonManager.h"

#import <Braintree/Braintree.h>
#import <PureLayout/PureLayout.h>
#import <Braintree/UIColor+BTUI.h>

@interface BraintreeDemoCustomMultiPaymentButtonManager ()

@property (nonatomic, strong) BTPaymentProvider *paymentProvider;

@property (nonatomic, weak) id<BTPaymentMethodCreationDelegate>delegate;

@property (nonatomic, strong) UINavigationController *cardFormNavigationViewController;
@property (nonatomic, strong) BTUICardFormView *cardForm;
@property (nonatomic, strong) Braintree *braintree;


@end

@implementation BraintreeDemoCustomMultiPaymentButtonManager

@synthesize view = _view;

- (instancetype)initWithBraintree:(Braintree *)braintree delegate:(id<BTPaymentMethodCreationDelegate>)delegate {
    self = [self init];
    if (self) {
        self.braintree = braintree;
        self.delegate = delegate;
       self.paymentProvider = [braintree paymentProviderWithDelegate:delegate];
        [self setupCustomButtonView];
    }
    return self;
}

- (void)setupCustomButtonView {
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

    _view = view;
}

- (void)tapped:(UIButton *)sender {
    if (sender.tag == -1) {
        self.cardForm = [[BTUICardFormView alloc] initForAutoLayout];
        self.cardForm.optionalFields = BTUICardFormOptionalFieldsNone;

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

        [self.delegate paymentMethodCreator:self requestsPresentationOfViewController:self.cardFormNavigationViewController];
    } else {
        [self.paymentProvider createPaymentMethod:sender.tag];
    }
}

- (void)cancelCardVC {
    [self.delegate paymentMethodCreator:self requestsDismissalOfViewController:self.cardFormNavigationViewController];
}

- (void)saveCardVC {
    [self cancelCardVC];
    [self.braintree.client saveCardWithNumber:self.cardForm.number ?: @""
                              expirationMonth:self.cardForm.expirationMonth ?: @""
                               expirationYear:self.cardForm.expirationYear ?: @""
                                          cvv:nil
                                   postalCode:nil
                                     validate:NO
                                      success:^(BTCardPaymentMethod *card) {
                                          [self.delegate paymentMethodCreator:self didCreatePaymentMethod:card];
                                      }
                                      failure:^(NSError *error) {
                                          [self.delegate paymentMethodCreator:self didFailWithError:error];
                                      }];
}

@end
