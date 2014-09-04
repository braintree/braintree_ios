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

- (BOOL)authorize {
    [NSException raise:@"Unimplemented abstract authorization" format:nil];
    return NO;
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


#pragma mark BTAppSwitchingDelegate

- (void)appSwitcherWillInitiate:(__unused id<BTAppSwitching>)switcher {
    [self.client postAnalyticsEvent:@"ios.paypal.authorizer.appswitch.will-initiate"];
    [self informDelegateWillRequestUserChallengeWithAppSwitch];
}

- (void)appSwitcherWillCreatePaymentMethod:(__unused id<BTAppSwitching>)switcher {
    [self.client postAnalyticsEvent:@"ios.paypal.authorizer.appswitch.will-create-payment-method"];
    [self informDelegateDidCompleteUserChallengeWithAppSwitch];
}

- (void)appSwitcher:(__unused id<BTAppSwitching>)switcher didCreatePaymentMethod:(BTPaymentMethod *)paymentMethod {
    [self.client postAnalyticsEvent:@"ios.paypal.authorizer.appswitch.did-create-payment-method"];
    [self informDelegateDidCreatePaymentMethod:paymentMethod];
}

- (void)appSwitcher:(__unused id<BTAppSwitching>)switcher didFailWithError:(NSError *)error {
    [self.client postAnalyticsEvent:@"ios.paypal.authorizer.appswitch.did-fail-with-error"];
    [self informDelegateDidFailWithError:error];
}

- (void)appSwitcherDidCancel:(__unused id<BTAppSwitching>)switcher {
    [self.client postAnalyticsEvent:@"ios.paypal.authorizer.appswitch.did-cancel"];
    [self informDelegateDidCompleteUserChallengeWithAppSwitch];
}



@end
