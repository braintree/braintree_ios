#import "BraintreeDemoBTPaymentButtonViewController.h"
#import <PureLayout/ALView+PureLayout.h>
#import "BraintreeDemoPaymentButtonBaseViewController.h"
#import <BraintreeCore/BraintreeCore.h>

@implementation BraintreeDemoPaymentButtonBaseViewController

- (instancetype)initWithClientToken:(NSString *)clientToken {
    self = [super initWithClientToken:clientToken];
    if (self) {
        self.apiClient = [[BTAPIClient alloc] initWithClientToken:clientToken];
    }
    return self;
}

- (instancetype)initWithClientKey:(NSString *)clientKey {
    if (self = [super initWithClientKey:clientKey]) {
        self.apiClient = [[BTAPIClient alloc] initWithClientKey:clientKey];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"Payment Button";

    [self.view setBackgroundColor:[UIColor colorWithRed:250.0f/255.0f green:253.0f/255.0f blue:255.0f/255.0f alpha:1.0f]];

    UIView *paymentButton = [self paymentButton];
    [self.view addSubview:paymentButton];

    [paymentButton autoCenterInSuperviewMargins];
    [paymentButton autoPinEdgeToSuperviewEdge:ALEdgeLeading];
    [paymentButton autoPinEdgeToSuperviewEdge:ALEdgeTrailing];
    [paymentButton autoSetDimension:ALDimensionHeight toSize:44 relation:NSLayoutRelationGreaterThanOrEqual];
}

- (UIView *)paymentButton {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:@"Subclasses of BraintreeDemoPaymentButtonViewController must override paymentButton. BraintreeDemoPaymentButtonViewController should not be initialized directly."
                                 userInfo:nil];
}

@end
