#import "BraintreeDemoPaymentButtonBaseViewController.h"
@import BraintreeCore;

@implementation BraintreeDemoPaymentButtonBaseViewController

- (instancetype)initWithAuthorization:(NSString *)authorization {
    self = [super initWithAuthorization:authorization];
    if (self) {
        self.apiClient = [[BTAPIClient alloc] initWithAuthorization:authorization];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = NSLocalizedString(@"Payment Button", nil);

    [self.view setBackgroundColor:[UIColor colorWithRed:250.0f/255.0f green:253.0f/255.0f blue:255.0f/255.0f alpha:1.0f]];

    self.paymentButton = [self createPaymentButton];
    self.paymentButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.paymentButton];

    [NSLayoutConstraint activateConstraints:@[
        [self.paymentButton.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [self.paymentButton.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor constant:self.centerYConstant],
        [self.paymentButton.heightAnchor constraintEqualToConstant:44.0]
    ]];
}

- (UIView *)createPaymentButton {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:@"Subclasses of BraintreeDemoPaymentButtonViewController must override createPaymentButton. BraintreeDemoPaymentButtonViewController should not be initialized directly."
                                 userInfo:nil];
}

@end
