#import "BraintreeDemoDropInViewController.h"

#import <PureLayout/PureLayout.h>
#import <CardIO/CardIO.h>

#import <Braintree/Braintree.h>

#import "BraintreeDemoSettings.h"

@interface BraintreeDemoDropInViewController () <BTDropInViewControllerDelegate, CardIOPaymentViewControllerDelegate>

@property (nonatomic, strong) Braintree *braintree;
@property (nonatomic, strong) UISwitch *prepopulateDataSwitch;
@property (nonatomic, strong) UISwitch *useCardIOSwitch;

@end

@implementation BraintreeDemoDropInViewController

- (instancetype)initWithClientToken:(NSString *)clientToken {
    self = [super initWithClientToken:clientToken];
    if (self) {
        self.braintree = [Braintree braintreeWithClientToken:clientToken];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"Drop In";

    UIButton *dropInButton = [UIButton buttonWithType:UIButtonTypeSystem];
    dropInButton.translatesAutoresizingMaskIntoConstraints = NO;
    [dropInButton addTarget:self action:@selector(tappedButton) forControlEvents:UIControlEventTouchUpInside];
    [dropInButton setBackgroundColor:[UIColor purpleColor]];
    [dropInButton setTitleColor:[UIColor whiteColor]forState:UIControlStateNormal];
    dropInButton.layer.cornerRadius = 5.0f;
    dropInButton.contentEdgeInsets = UIEdgeInsetsMake(8, 8, 8, 8);
    [dropInButton setTitle:@"Buy Now" forState:UIControlStateNormal];
    [dropInButton sizeToFit];

    [self.view addSubview:dropInButton];
    [dropInButton autoCenterInSuperview];

    self.prepopulateDataSwitch = [UISwitch new];
    [self.view addSubview:self.prepopulateDataSwitch];
    [self.prepopulateDataSwitch autoConstrainAttribute:ALAttributeRight toAttribute:ALAttributeMarginRight ofView:self.view];
    [self.prepopulateDataSwitch autoConstrainAttribute:ALAttributeBottom toAttribute:ALAttributeMarginBottom ofView:self.view withOffset:-20.0f];

    UILabel *prepopulateLabel = [UILabel new];
    prepopulateLabel.text = @"Modify card form";
    [self.view addSubview:prepopulateLabel];
    [prepopulateLabel autoConstrainAttribute:ALAttributeLeft toAttribute:ALAttributeMarginLeft ofView:self.view];
    [prepopulateLabel autoConstrainAttribute:ALAttributeHorizontal toAttribute:ALAttributeHorizontal ofView:self.prepopulateDataSwitch];


    self.useCardIOSwitch = [UISwitch new];
    [self.view addSubview:self.useCardIOSwitch];
    [self.useCardIOSwitch autoConstrainAttribute:ALAttributeRight toAttribute:ALAttributeMarginRight ofView:self.view];
    [self.useCardIOSwitch autoConstrainAttribute:ALAttributeBottom toAttribute:ALAttributeMarginTop ofView:self.prepopulateDataSwitch withOffset:-20.0f];

    UILabel *cardIOLabel = [UILabel new];
    cardIOLabel.text = @"Use Card.IO";
    [self.view addSubview:cardIOLabel];
    [cardIOLabel autoConstrainAttribute:ALAttributeLeft toAttribute:ALAttributeMarginLeft ofView:self.view];
    [cardIOLabel autoConstrainAttribute:ALAttributeHorizontal toAttribute:ALAttributeHorizontal ofView:self.useCardIOSwitch];


    self.progressBlock(@"Ready to present Drop In");
}

- (void)tappedButton {

    if (self.useCardIOSwitch.on) {
        CardIOPaymentViewController *cardIO = [[CardIOPaymentViewController alloc] initWithPaymentDelegate:self];
        cardIO.useCardIOLogo = YES;
        cardIO.suppressScanConfirmation = YES;
        [self presentViewController:cardIO animated:YES completion:nil];
    } else{
        BTDropInViewController *dropIn = [self buildDropInViewController];
        if (self.prepopulateDataSwitch.on) {
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"MM/yyyy"];
            [dropIn setCardExpirationDate:[dateFormatter dateFromString: @"12/2018"]];
            dropIn.cardNumber = @"4111111111111111";
            dropIn.cardCVV = @"123";
            dropIn.cardPostalCode = @"12345";
            dropIn.requireCardCVV = YES;
            dropIn.requireCardPostalCode = YES;
        }
        [self presentDropIn:dropIn];
    }
}

- (void)cancel {
    self.progressBlock(@"Dismissing");
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)presentDropIn:(UIViewController *)dropIn {
    if ([BraintreeDemoSettings useModalPresentation]) {
        self.progressBlock(@"Presenting Drop In Modally");
        dropIn.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel)];
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:dropIn];
        [self presentViewController:nav animated:YES completion:nil];
    } else {
        self.progressBlock(@"Pushing Drop In on nav stack");
        [self.navigationController pushViewController:dropIn animated:YES];
    }
}

- (BTDropInViewController *)buildDropInViewController {
    BTDropInViewController *dropIn = [self.braintree dropInViewControllerWithDelegate:self];
    dropIn.title = @"Check Out";
    dropIn.summaryTitle = @"Our Fancy Magazine";
    dropIn.summaryDescription = @"53 Week Subscription";
    dropIn.displayAmount = @"$19.00";
    dropIn.callToActionText = @"$19 - Subscribe Now";
    dropIn.shouldHideCallToAction = NO;
    return dropIn;
}

#pragma mark - BTDropInViewControllerDelegate

- (void)dropInViewController:(BTDropInViewController *)viewController didSucceedWithPaymentMethod:(BTPaymentMethod *)paymentMethod {
    if ([BraintreeDemoSettings useModalPresentation]) {
        [viewController dismissViewControllerAnimated:YES completion:^{
            self.completionBlock(paymentMethod);
        }];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)dropInViewControllerWillComplete:(__unused BTDropInViewController *)viewController {
    self.progressBlock(@"Drop In Will Complete");
}

- (void)dropInViewControllerDidCancel:(BTDropInViewController *)viewController {
    self.progressBlock(@"User Canceled Drop In");
    [viewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - CardIOViewControllerDelegate

- (void)userDidCancelPaymentViewController:(__unused CardIOPaymentViewController *)paymentViewController {
    [self cancel];
}

- (void)userDidProvideCreditCardInfo:(CardIOCreditCardInfo *)cardInfo inPaymentViewController:(CardIOPaymentViewController *)paymentViewController {
    BTDropInViewController *dropIn = [self buildDropInViewController];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM/yyyy"];
    NSString *expirationString = [NSString stringWithFormat:@"%lu/%lu", (unsigned long)cardInfo.expiryMonth, (unsigned long)cardInfo.expiryYear];
    [dropIn setCardExpirationDate:[dateFormatter dateFromString:expirationString]];
    dropIn.cardNumber = cardInfo.cardNumber;
    [self dismissViewControllerAnimated:YES completion:^{
        [self presentDropIn:dropIn];
    }];
}

@end
