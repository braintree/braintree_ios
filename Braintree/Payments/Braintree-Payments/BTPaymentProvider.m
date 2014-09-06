#import "BTPaymentProvider.h"
#import "BTClient.h"
#import "BTAppSwitching.h"

#import "BTVenmoAppSwitchHandler.h"

#import "BTPayPalViewController.h"
#import "BTPayPalAppSwitchHandler.h"
#import "BTClient+BTPayPal.h"

#import "BTLogger.h"

@interface BTPaymentProvider () <BTPayPalViewControllerDelegate, BTAppSwitchingDelegate>
@end

@implementation BTPaymentProvider

- (instancetype)initWithClient:(BTClient *)client {
    self = [super init];
    if (self) {
        self.client = client;
    }
    return self;
}

- (void)createPaymentMethod:(BTPaymentProviderType)type {
    [self createPaymentMethod:type options:BTPaymentAuthorizationOptionMechanismAny];
}

- (void)createPaymentMethod:(BTPaymentProviderType)type options:(BTPaymentMethodCreationOptions)options {
    switch (type) {
        case BTPaymentProviderTypePayPal:
            [self authorizePayPal:options];
            break;
        case BTPaymentProviderTypeVenmo:
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

- (BOOL)supportsAuthorizationType:(BTPaymentProviderType)type {
    switch (type) {
        case BTPaymentProviderTypePayPal:
            return [self.client btPayPal_isPayPalEnabled];
            break;
        case BTPaymentProviderTypeVenmo:
            return [BTVenmoAppSwitchHandler isAvailableForClient:self.client];
            break;
        default:
            return NO;
            break;
    }
}

#pragma mark Venmo

- (void)authorizeVenmo:(BTPaymentMethodCreationOptions)options {

    if ((options & BTPaymentAuthorizationOptionMechanismAppSwitch) == 0) {
        NSError *error = [NSError errorWithDomain:BTPaymentAuthorizationErrorDomain code:BTPaymentAuthorizationErrorOptionNotSupported userInfo:nil];
        [self.delegate paymentMethodCreator:self didFailWithError:error];
        return;
    }

    [[BTVenmoAppSwitchHandler sharedHandler] initiateAppSwitchWithClient:self.client delegate:self];
}

#pragma mark PayPal

- (void)authorizePayPal:(BTPaymentMethodCreationOptions)options {

    BOOL appSwitchOptionEnabled = (options & BTPaymentAuthorizationOptionMechanismAppSwitch) == BTPaymentAuthorizationOptionMechanismAppSwitch;
    BOOL viewControllerOptionEnabled = (options & BTPaymentAuthorizationOptionMechanismViewController) == BTPaymentAuthorizationOptionMechanismViewController;

    if (!appSwitchOptionEnabled && !viewControllerOptionEnabled) {
        NSError *error = [NSError errorWithDomain:BTPaymentAuthorizationErrorDomain code:BTPaymentAuthorizationErrorOptionNotSupported userInfo:@{ NSLocalizedDescriptionKey: @"At least one of BTPaymentAuthorizationOptionMechanismAppSwitch or BTPaymentAuthorizationOptionMechanismViewController must be enabled in options" }];
        [self.delegate paymentMethodCreator:self didFailWithError:error];
        return;
    }

    BOOL initiated = NO;
    if (appSwitchOptionEnabled) {
        initiated = [[BTPayPalAppSwitchHandler sharedHandler] initiateAppSwitchWithClient:self.client delegate:self];
    }

    if(!initiated && viewControllerOptionEnabled) {
        [[BTLogger sharedLogger] log:@"PayPal Touch is unavailable: falling back to BTPayPalViewController"];

        BTPayPalViewController *braintreePayPalViewController = [[BTPayPalViewController alloc] initWithClient:self.client];
        if (braintreePayPalViewController) {
            braintreePayPalViewController.delegate = self;
            [self informDelegateRequestsPresentationOfViewController:braintreePayPalViewController];
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

- (void)informDelegateWillPerformAppSwitch {
    [self.client postAnalyticsEvent:@"ios.authorizer.will-app-switch"];
    if ([self.delegate respondsToSelector:@selector(paymentMethodCreatorWillPerformAppSwitch:)]) {
        [self.delegate paymentMethodCreatorWillPerformAppSwitch:self];
    }
}

- (void)informDelegateWillProcess {
    [self.client postAnalyticsEvent:@"ios.authorizer.will-process-authorization-response"];
    if ([self.delegate respondsToSelector:@selector(paymentMethodCreatorWillProcess:)]) {
        [self.delegate paymentMethodCreatorWillProcess:self];
    }
}

- (void)informDelegateRequestsPresentationOfViewController:(UIViewController *)viewController {
    [self.client postAnalyticsEvent:@"ios.authorizer.requests-authorization-with-view-controller"];
    if ([self.delegate respondsToSelector:@selector(paymentMethodCreator:requestsPresentationOfViewController:)]) {
        [self.delegate paymentMethodCreator:self requestsPresentationOfViewController:viewController];
    }
}

- (void)informDelegateRequestsDismissalOfAuthorizationViewController:(UIViewController *)viewController {
    [self.client postAnalyticsEvent:@"ios.authorizer.requests-dismissal-of-authorization-view-controller"];
    if ([self.delegate respondsToSelector:@selector(paymentMethodCreator:requestsDismissalOfViewController:)]) {
        [self.delegate paymentMethodCreator:self requestsDismissalOfViewController:viewController];
    }
}

- (void)informDelegateDidCreatePaymentMethod:(BTPaymentMethod *)paymentMethod {
    [self.client postAnalyticsEvent:@"ios.authorizer.did-create-payment-method"];
    if ([self.delegate respondsToSelector:@selector(paymentMethodCreator:didCreatePaymentMethod:)]) {
        [self.delegate paymentMethodCreator:self didCreatePaymentMethod:paymentMethod];
    }
}

- (void)informDelegateDidFailWithError:(NSError *)error {
    [self.client postAnalyticsEvent:@"ios.authorizer.did-fail-with-error"];
    if ([self.delegate respondsToSelector:@selector(paymentMethodCreator:didFailWithError:)]) {
        [self.delegate paymentMethodCreator:self didFailWithError:error];
    }
}

- (void)informDelegateDidCancel {
    [self.client postAnalyticsEvent:@"ios.authorizer.did-cancel"];
    if ([self.delegate respondsToSelector:@selector(paymentMethodCreatorDidCancel:)]) {
        [self.delegate paymentMethodCreatorDidCancel:self];
    }
}

#pragma mark BTPayPalViewControllerDelegate

- (void)payPalViewControllerWillCreatePayPalPaymentMethod:(BTPayPalViewController *)viewController {
    [self informDelegateRequestsDismissalOfAuthorizationViewController:viewController];
    [self informDelegateWillProcess];
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
    [self informDelegateWillPerformAppSwitch];
}

- (void)appSwitcherWillSwitch:(__unused id<BTAppSwitching>)switcher {
    [self informDelegateWillPerformAppSwitch];
}

- (void)appSwitcherWillCreatePaymentMethod:(__unused id<BTAppSwitching>)switcher {
    [self informDelegateWillProcess];
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
