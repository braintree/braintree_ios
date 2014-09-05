#import "BTPaymentAuthorizer.h"
#import "BTClient.h"
#import "BTAppSwitching.h"

#import "BTVenmoAppSwitchHandler.h"

#import "BTPayPalViewController.h"
#import "BTPayPalAppSwitchHandler.h"
#import "BTClient+BTPayPal.h"

#import "BTLogger.h"

@interface BTPaymentAuthorizer () <BTPayPalViewControllerDelegate, BTAppSwitchingDelegate>
@end

@implementation BTPaymentAuthorizer

- (instancetype)initWithClient:(BTClient *)client {
    self = [super init];
    if (self) {
        self.client = client;
    }
    return self;
}

- (void)authorize:(BTPaymentAuthorizationType)type {
    [self authorize:type options:BTPaymentAuthorizationOptionMechanismAny];
}

- (void)authorize:(BTPaymentAuthorizationType)type options:(BTPaymentAuthorizationOptions)options {
    switch (type) {
        case BTPaymentAuthorizationTypePayPal:
            [self authorizePayPal:options];
            break;
        case BTPaymentAuthorizationTypeVenmo:
            [self authorizeVenmo:options];
            break;
        default:
            break;
    }
}

- (void)setClient:(BTClient *)client {
    _client = client;

    // If PayPal is a possibility with this client, prepare.
    if ([self.client btPayPal_isPayPalEnabled]) {
        NSError *error;
        [self.client btPayPal_preparePayPalMobileWithError:&error];
        if (error) {
            [self.client postAnalyticsEvent:@"ios.authorizer.init.paypal-error"];
            [[BTLogger sharedLogger] log:[NSString stringWithFormat:@"PayPal is unavailable: %@", [error localizedDescription]]];
        }
    }
}

- (BOOL)supportsAuthorizationType:(BTPaymentAuthorizationType)type {
    switch (type) {
        case BTPaymentAuthorizationTypePayPal:
            return [self.client btPayPal_isPayPalEnabled];
            break;
        case BTPaymentAuthorizationTypeVenmo:
            return [BTVenmoAppSwitchHandler isAvailable];
            break;
        default:
            return NO;
            break;
    }
}

#pragma mark Venmo

- (void)authorizeVenmo:(BTPaymentAuthorizationOptions)options {

    if ((options & BTPaymentAuthorizationOptionMechanismAppSwitch) == 0) {
        NSError *error = [NSError errorWithDomain:BTPaymentAuthorizationErrorDomain code:BTPaymentAuthorizationErrorOptionNotSupported userInfo:nil];
        [self.delegate paymentAuthorizer:self didFailWithError:error];
        return;
    }

    BOOL appSwitchInitiated = [[BTVenmoAppSwitchHandler sharedHandler] initiateAppSwitchWithClient:self.client delegate:self];

    if (appSwitchInitiated) {
        [self informDelegateWillRequestAuthorizationWithAppSwitch];
    } else {
        NSError *error = [NSError errorWithDomain:BTPaymentAuthorizationErrorDomain code:BTPaymentAuthorizationErrorUnknown userInfo:@{ NSLocalizedDescriptionKey: @"Venmo authorization failed" }];
        [self informDelegateDidFailWithError:error];
    }
}

#pragma mark PayPal

- (void)authorizePayPal:(BTPaymentAuthorizationOptions)options {

    BOOL appSwitchOptionEnabled = (options & BTPaymentAuthorizationOptionMechanismAppSwitch) == BTPaymentAuthorizationOptionMechanismAppSwitch;
    BOOL viewControllerOptionEnabled = (options & BTPaymentAuthorizationOptionMechanismViewController) == BTPaymentAuthorizationOptionMechanismViewController;

    if (!appSwitchOptionEnabled && !viewControllerOptionEnabled) {
        NSError *error = [NSError errorWithDomain:BTPaymentAuthorizationErrorDomain code:BTPaymentAuthorizationErrorOptionNotSupported userInfo:@{ NSLocalizedDescriptionKey: @"At least one of BTPaymentAuthorizationOptionMechanismAppSwitch or BTPaymentAuthorizationOptionMechanismViewController must be enabled in options" }];
        [self.delegate paymentAuthorizer:self didFailWithError:error];
        return;
    }

    BOOL initiated = NO;
    if (appSwitchOptionEnabled) {
        initiated = [[BTPayPalAppSwitchHandler sharedHandler] initiateAppSwitchWithClient:self.client delegate:self];
        if (initiated) {
            [self informDelegateWillRequestAuthorizationWithAppSwitch];
        }
    }

    if(!initiated && viewControllerOptionEnabled) {
        [[BTLogger sharedLogger] log:@"PayPal Touch is unavailable: falling back to BTPayPalViewController"];

        BTPayPalViewController *braintreePayPalViewController = [[BTPayPalViewController alloc] initWithClient:self.client];
        if (braintreePayPalViewController) {
            braintreePayPalViewController.delegate = self;
            [self informDelegateRequestsAuthorizationWithViewController:braintreePayPalViewController];
            initiated = YES;
        } else {
            NSError *error = [NSError errorWithDomain:BTPaymentAuthorizationErrorDomain code:BTPaymentAuthorizationErrorInitialization userInfo:@{ NSLocalizedDescriptionKey: @"Failed to initialize BTPayPalViewController" }];
            [self informDelegateDidFailWithError:error];
        }
    }

    if (!initiated) {
        NSError *error = [NSError errorWithDomain:BTPaymentAuthorizationErrorDomain code:BTPaymentAuthorizationErrorUnknown userInfo:@{ NSLocalizedDescriptionKey: @"PayPal authorization failed" }];
        [self informDelegateDidFailWithError:error];
    }
}

#pragma mark Inform Delegate

- (void)informDelegateWillRequestAuthorizationWithAppSwitch {
    [self.client postAnalyticsEvent:@"ios.authorizer.will-app-switch"];
    if ([self.delegate respondsToSelector:@selector(paymentAuthorizerWillRequestAuthorizationWithAppSwitch:)]) {
        [self.delegate paymentAuthorizerWillRequestAuthorizationWithAppSwitch:self];
    }
}

- (void)informDelegateWillProcessAuthorizationResponse {
    [self.client postAnalyticsEvent:@"ios.authorizer.will-process-authorization-response"];
    if ([self.delegate respondsToSelector:@selector(paymentAuthorizerWillProcessAuthorizationResponse:)]) {
        [self.delegate paymentAuthorizerWillProcessAuthorizationResponse:self];
    }
}

- (void)informDelegateRequestsAuthorizationWithViewController:(UIViewController *)viewController {
    [self.client postAnalyticsEvent:@"ios.authorizer.requests-authorization-with-view-controller"];
    if ([self.delegate respondsToSelector:@selector(paymentAuthorizer:requestsAuthorizationWithViewController:)]) {
        [self.delegate paymentAuthorizer:self requestsAuthorizationWithViewController:viewController];
    }
}

- (void)informDelegateRequestsDismissalOfAuthorizationViewController:(UIViewController *)viewController {
    [self.client postAnalyticsEvent:@"ios.authorizer.requests-dismissal-of-authorization-view-controller"];
    if ([self.delegate respondsToSelector:@selector(paymentAuthorizer:requestsDismissalOfAuthorizationViewController:)]) {
        [self.delegate paymentAuthorizer:self requestsDismissalOfAuthorizationViewController:viewController];
    }
}

- (void)informDelegateDidCreatePaymentMethod:(BTPaymentMethod *)paymentMethod {
    [self.client postAnalyticsEvent:@"ios.authorizer.did-create-payment-method"];
    if ([self.delegate respondsToSelector:@selector(paymentAuthorizer:didCreatePaymentMethod:)]) {
        [self.delegate paymentAuthorizer:self didCreatePaymentMethod:paymentMethod];
    }
}

- (void)informDelegateDidFailWithError:(NSError *)error {
    [self.client postAnalyticsEvent:@"ios.authorizer.did-fail-with-error"];
    if ([self.delegate respondsToSelector:@selector(paymentAuthorizer:didFailWithError:)]) {
        [self.delegate paymentAuthorizer:self didFailWithError:error];
    }
}

- (void)informDelegateDidCancel {
    [self.client postAnalyticsEvent:@"ios.authorizer.did-cancel"];
    if ([self.delegate respondsToSelector:@selector(paymentAuthorizerDidCancel:)]) {
        [self.delegate paymentAuthorizerDidCancel:self];
    }
}

#pragma mark BTPayPalViewControllerDelegate

- (void)payPalViewControllerWillCreatePayPalPaymentMethod:(BTPayPalViewController *)viewController {
    [self informDelegateRequestsDismissalOfAuthorizationViewController:viewController];
    [self informDelegateWillProcessAuthorizationResponse];
}

- (void)payPalViewController:(__unused BTPayPalViewController *)viewController didCreatePayPalPaymentMethod:(BTPayPalPaymentMethod *)payPalPaymentMethod {
    [self informDelegateDidCreatePaymentMethod:payPalPaymentMethod];
}

- (void)payPalViewController:(__unused BTPayPalViewController *)viewController didFailWithError:(NSError *)error {
    [self informDelegateDidFailWithError:error];
}

- (void)payPalViewControllerDidCancel:(BTPayPalViewController *)viewController {
    [self informDelegateRequestsDismissalOfAuthorizationViewController:viewController];
    [self informDelegateDidCancel];
}

#pragma mark BTAppSwitchingDelegate

- (void)appSwitcherWillInitiate:(__unused id<BTAppSwitching>)switcher {
    [self informDelegateWillRequestAuthorizationWithAppSwitch];
}

- (void)appSwitcherWillCreatePaymentMethod:(__unused id<BTAppSwitching>)switcher {
    [self informDelegateWillProcessAuthorizationResponse];
}

- (void)appSwitcher:(__unused id<BTAppSwitching>)switcher didCreatePaymentMethod:(BTPaymentMethod *)paymentMethod {
    [self informDelegateDidCreatePaymentMethod:paymentMethod];
}

- (void)appSwitcher:(__unused id<BTAppSwitching>)switcher didFailWithError:(NSError *)error {
    [self informDelegateDidFailWithError:error];
}

- (void)appSwitcherDidCancel:(__unused id<BTAppSwitching>)switcher {
    [self informDelegateDidCancel];
}

@end
