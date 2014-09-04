#import "BTPaymentAuthorizer.h"
#import "BTClient.h"
#import "BTPaymentAuthorizer_Protected.h"
#import "BTPaymentAuthorizerPayPal.h"
#import "BTPaymentAuthorizerVenmo.h"

@implementation BTPaymentAuthorizer

- (instancetype)initWithType:(BTPaymentAuthorizationType)type
                      client:(BTClient *)client {
    switch (type) {
        case BTPaymentAuthorizationTypePayPal:
            self = [[BTPaymentAuthorizerPayPal alloc] init];
            break;
        case BTPaymentAuthorizationTypeVenmo:
            self = [[BTPaymentAuthorizerVenmo alloc] init];
            break;
        default:
            break;
    }
    self.client = client;
    return self;
}

- (void)authorize {
    [NSException raise:@"Unimplemented abstract authorization" format:nil];
}

- (void)informDelegateWillRequestUserChallengeWithAppSwitch {
    if ([self.delegate respondsToSelector:@selector(paymentAuthorizerWillRequestUserChallengeWithAppSwitch:)]) {
        [self.delegate paymentAuthorizerWillRequestUserChallengeWithAppSwitch:self];
    }
}

- (void)informDelegateDidCompleteUserChallengeWithAppSwitch {
    if ([self.delegate respondsToSelector:@selector(paymentAuthorizerDidCompleteUserChallengeWithAppSwitch:)]) {
        [self.delegate paymentAuthorizerDidCompleteUserChallengeWithAppSwitch:self];
    }
}

- (void)informDelegateRequestsUserChallengeWithViewController:(UIViewController *)viewController {
    if ([self.delegate respondsToSelector:@selector(paymentAuthorizer:requestsUserChallengeWithViewController:)]) {
        [self.delegate paymentAuthorizer:self requestsUserChallengeWithViewController:viewController];
    }
}

- (void)informDelegateRequestsDismissalOfUserChallengeViewController:(UIViewController *)viewController {
    if ([self.delegate respondsToSelector:@selector(paymentAuthorizer:requestsDismissalOfUserChallengeViewController:)]) {
        [self.delegate paymentAuthorizer:self requestsDismissalOfUserChallengeViewController:viewController];
    }
}

- (void)informDelegateDidCreatePaymentMethod:(BTPaymentMethod *)paymentMethod {
    if ([self.delegate respondsToSelector:@selector(paymentAuthorizer:didCreatePaymentMethod:)]) {
        [self.delegate paymentAuthorizer:self didCreatePaymentMethod:paymentMethod];
    }
}

- (void)informDelegateDidFailWithError:(NSError *)error {
    if ([self.delegate respondsToSelector:@selector(paymentAuthorizer:didFailWithError:)]) {
        [self.delegate paymentAuthorizer:self didFailWithError:error];
    }
}

@end
