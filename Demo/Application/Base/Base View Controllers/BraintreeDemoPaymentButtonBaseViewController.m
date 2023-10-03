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

    [self.view setBackgroundColor:UIColor.systemBackgroundColor];

    self.paymentButton = [self createPaymentButton];
    self.paymentButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.paymentButton];

    [NSLayoutConstraint activateConstraints:@[
        [self.paymentButton.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
        [self.paymentButton.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20],
        [self.paymentButton.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor constant:self.centerYConstant],
        [self.paymentButton.heightAnchor constraintEqualToConstant:100.0]
    ]];
}

- (UIView *)createPaymentButton {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:@"Subclasses of BraintreeDemoPaymentButtonViewController must override createPaymentButton. BraintreeDemoPaymentButtonViewController should not be initialized directly."
                                 userInfo:nil];
}

@end
