#import "BTPaymentAuthorizer.h"

@interface BTPaymentAuthorizer () {
@protected
    BTClient *_client;
}

@property (nonatomic, assign) BTPaymentAuthorizationType type;
@property (nonatomic, strong) BTClient *client;

- (void)informDelegateWillRequestUserChallengeWithAppSwitch;
- (void)informDelegateDidCompleteUserChallengeWithAppSwitch;

- (void)informDelegateRequestsUserChallengeWithViewController:(UIViewController *)viewController;
- (void)informDelegateRequestsDismissalOfUserChallengeViewController:(UIViewController *)viewController;

- (void)informDelegateDidCreatePaymentMethod:(BTPaymentMethod *)paymentMethod;
- (void)informDelegateDidFailWithError:(NSError *)error;


@end

