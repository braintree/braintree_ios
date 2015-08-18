#import <PureLayout/ALView+PureLayout.h>
#import "BraintreeDemoBTPaymentButtonViewController.h"
#import <BraintreeCore/BraintreeCore.h>
#import <BraintreeCard/BraintreeCard.h>

@interface BraintreeDemoBTPaymentButtonViewController ()
@end

@implementation BraintreeDemoBTPaymentButtonViewController

- (UIView *)paymentButton {
    return [Braintree paymentButton];
//    return [BTPaymentButton buttonWithClient:apiClient];
}


@end

@interface Braintree
+ (void)setUpWithClientKey:(NSString *)clientKey;
@property (nonatomic, strong) BTAPIClient *apiClient;
@end

@class BTPaymentButton;

@interface Braintree (BraintreeUI)
+ (BTPaymentButton *)paymentButton;
- (UIView *)paymentButtonWithCompletion:(void(^)(id <BTTokenized> token, NSError *error))completion;
@end

@class BTPaymentButton;



//BTPaymentButton *button = [Braintree paymentButton];
//button.delegate = self;

@implementation Braintree (BraintreeUI)
+ (BTPaymentButton *)paymentButtonWithCompletion:(void(^)(id <BTTokenized> token, NSError *error))completion {
    BTPaymentButton *button = [[BTPaymentButton alloc] initWithAPIClient:self.apiClient completion:completion];
}
@end

@interface BTPaymentButton : UIButton
- (instancetype)initWithAPIClient:(BTAPIClient *)apiClient completion:(void(^)(id <BTTokenized> token, NSError *error))completion;
@property (nonatomic, strong) BTAPIClient *apiClient;
@property (nonatomic, copy) void(^completion)(id <BTTokenized> tokenization, NSError *error);
@end

@implementation BTPaymentButton

- (instancetype)initWithAPIClient:(BTAPIClient *)apiClient
                       completion:(void(^)(id <BTTokenized> token, NSError *error))completion
{
    if (self = [super initWithFrame:CGRectZero]) {
        _apiClient = apiClient;
        _completion = completion;
    }
    return self;
}

- (IBAction)someButtonGetsPressed:(BTPaymentButton *)button {
    BTCardTokenizationClient *cardTokenizationClient = [[BTCardTokenizationClient alloc] initWithAPIClient:self.apiClient];
    [cardTokenizationClient tokenizeCard:nil completion:self.completion];
}

@end