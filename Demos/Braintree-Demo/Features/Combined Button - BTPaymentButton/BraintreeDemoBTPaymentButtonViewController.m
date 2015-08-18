#import "BraintreeDemoBTPaymentButtonViewController.h"
#import <BraintreeCard/BraintreeCard.h>
#import <BraintreeUI/BraintreeUI.h>
#import <PureLayout/ALView+PureLayout.h>

@interface BraintreeDemoBTPaymentButtonViewController ()
@end

@implementation BraintreeDemoBTPaymentButtonViewController

- (UIView *)paymentButton {
    return [[BTPaymentButton alloc] initWithAPIClient:self.apiClient completion:^(id<BTTokenized> tokenization, NSError *error) {
        if (tokenization) {
            self.progressBlock(@"Got a nonce 💎!");
            NSLog(@"%@", [tokenization debugDescription]);
            self.completionBlock(tokenization);
        } else if (error) {
            self.progressBlock(error.localizedDescription);
        } else {
            self.progressBlock(@"Canceled 🔰");
        }
    }];
}

@end
