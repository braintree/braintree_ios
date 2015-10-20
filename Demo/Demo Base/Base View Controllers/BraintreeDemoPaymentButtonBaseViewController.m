#import "BraintreeDemoBTPaymentButtonViewController.h"
#import <PureLayout/ALView+PureLayout.h>
#import "BraintreeDemoPaymentButtonBaseViewController.h"
#import <BraintreeCore/BraintreeCore.h>

@implementation BraintreeDemoPaymentButtonBaseViewController

- (instancetype)initWithClientToken:(NSString *)clientToken {
    self = [super initWithClientToken:clientToken];
    if (self) {
        self.apiClient = [[BTAPIClient alloc] initWithClientKeyOrToken:clientToken];
    }
    return self;
}

- (instancetype)initWithClientKey:(NSString *)clientKey {
    if (self = [super initWithClientKey:clientKey]) {
        self.apiClient = [[BTAPIClient alloc] initWithClientKeyOrToken:clientKey];
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
    // This margin is important for the Apple Pay button.
    // BTPaymentButton looks fine without, but it's also not too terrible with it.
    [paymentButton autoPinEdgeToSuperviewEdge:ALEdgeLeading withInset:20];
    [paymentButton autoPinEdgeToSuperviewEdge:ALEdgeTrailing withInset:20];
    [paymentButton autoSetDimension:ALDimensionHeight toSize:44 relation:NSLayoutRelationGreaterThanOrEqual];
}

- (UIView *)paymentButton {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:@"Subclasses of BraintreeDemoPaymentButtonViewController must override paymentButton. BraintreeDemoPaymentButtonViewController should not be initialized directly."
                                 userInfo:nil];
}

@end
