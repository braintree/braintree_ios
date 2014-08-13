#import "BTPayPalAdapter.h"
#import "BTPayPalViewController.h"
#import "BTLogger.h"
#import "BTClient+BTPayPal.h"
#import "BTPayPalAppSwitchHandler.h"

#import "PayPalMobile.h"

@interface BTPayPalAdapter () <BTPayPalViewControllerDelegate, BTPayPalAppSwitchHandlerDelegate>

@end

@implementation BTPayPalAdapter

- (instancetype)initWithClient:(BTClient *)client {
    self = [self init];
    if (self) {
        self.client = client;

        NSError *error;
        [self.client btPayPal_preparePayPalMobileWithError:&error];
        if (error) {
            [self.client postAnalyticsEvent:@"ios.paypal.adapter.init.error"];
            [[BTLogger sharedLogger] log:[NSString stringWithFormat:@"PayPal is unavailable: %@", [error localizedDescription]]];
            return nil;
        }
    }
    return self;
}

- (void)initiatePayPalAuth {

    BOOL appSwitchHandled = [[BTPayPalAppSwitchHandler sharedHandler] initiatePayPalAuthWithClient:self.client delegate:self];

    if (appSwitchHandled) {
        [self.client postAnalyticsEvent:@"ios.paypal.adapter.appswitch.initiate"];
    } else {
        [self.client postAnalyticsEvent:@"ios.paypal.adapter.viewcontroller.initiate"];
        [[BTLogger sharedLogger] log:@"PayPal Touch is unavailable: falling back to BTPayPalViewController"];

        BTPayPalViewController *braintreePayPalViewController = [[BTPayPalViewController alloc] initWithClient:self.client];
        braintreePayPalViewController.delegate = self;
        [self.delegate payPalAdapter:self requestsPresentationOfViewController:braintreePayPalViewController];
    }
}

- (void)requestDismissalOfViewController:(BTPayPalViewController *)viewController {
    [self.delegate payPalAdapter:self requestsDismissalOfViewController:viewController];
}

- (void)informDelegateWillAppSwitch {
    if ([self.delegate respondsToSelector:@selector(payPalAdapterWillAppSwitch:)]) {
        [self.delegate payPalAdapterWillAppSwitch:self];
    }
}

- (void)informDelegateWillCreatePayPalPaymentMethod {
    if ([self.delegate respondsToSelector:@selector(payPalAdapterWillCreatePayPalPaymentMethod:)]) {
        [self.delegate payPalAdapterWillCreatePayPalPaymentMethod:self];
    }
}

- (void)informDelegateDidCreatePayPalPaymentMethod:(BTPayPalPaymentMethod *)payPalPaymentMethod {
    [self.delegate payPalAdapter:self didCreatePayPalPaymentMethod:payPalPaymentMethod];
}

- (void)informDelegateDidFailWithError:(NSError *)error {
    [self.delegate payPalAdapter:self didFailWithError:error];
}

- (void)informDelegateDidCancel {
    [self.delegate payPalAdapterDidCancel:self];
}


#pragma mark BTPayPalViewControllerDelegate implementation

- (void)payPalViewControllerWillCreatePayPalPaymentMethod:(BTPayPalViewController *)viewController {
    [self.client postAnalyticsEvent:@"ios.paypal.adapter.viewcontroller.will-create-payment-method"];
    [self requestDismissalOfViewController:viewController];
    [self informDelegateWillCreatePayPalPaymentMethod];
}

- (void)payPalViewController:(__unused BTPayPalViewController *)viewController didCreatePayPalPaymentMethod:(BTPayPalPaymentMethod *)payPalPaymentMethod {
    [self.client postAnalyticsEvent:@"ios.paypal.adapter.viewcontroller.did-create-payment-method"];
    [self informDelegateDidCreatePayPalPaymentMethod:payPalPaymentMethod];
}

- (void)payPalViewController:(BTPayPalViewController *)viewController didFailWithError:(NSError *)error {
    [self.client postAnalyticsEvent:@"ios.paypal.adapter.viewcontroller.did-fail-with-error"];
    [self requestDismissalOfViewController:viewController];
    [self informDelegateDidFailWithError:error];
}

- (void)payPalViewControllerDidCancel:(BTPayPalViewController *)viewController {
    [self.client postAnalyticsEvent:@"ios.paypal.adapter.viewcontroller.did-cancel"];
    [self requestDismissalOfViewController:viewController];
    [self informDelegateDidCancel];
}

#pragma mark BTPayPalAppSwitchHandler Delegate implementation

- (void)payPalAppSwitchHandlerWillAppSwitch:(__unused BTPayPalAppSwitchHandler *)appSwitchHandler {
    [self informDelegateWillAppSwitch];
}

- (void)payPalAppSwitchHandlerWillCreatePayPalPaymentMethod:(__unused BTPayPalAppSwitchHandler *)appSwitchHandler {
    [self.client postAnalyticsEvent:@"ios.paypal.adapter.appswitch.will-create-payment-method"];
    [self informDelegateWillCreatePayPalPaymentMethod];
}

- (void)payPalAppSwitchHandler:(__unused BTPayPalAppSwitchHandler *)appSwitchHandler didCreatePayPalPaymentMethod:(BTPayPalPaymentMethod *)payPalPaymentMethod {
    [self.client postAnalyticsEvent:@"ios.paypal.adapter.appswitch.did-create-payment-method"];
    [self informDelegateDidCreatePayPalPaymentMethod:payPalPaymentMethod];
}

- (void)payPalAppSwitchHandler:(__unused BTPayPalAppSwitchHandler *)appSwitchHandler didFailWithError:(NSError *)error {
    [self.client postAnalyticsEvent:@"ios.paypal.adapter.appswitch.did-fail-with-error"];
    [self informDelegateDidFailWithError:error];
}

- (void)payPalAppSwitchHandlerAuthenticatorAppDidCancel:(__unused BTPayPalAppSwitchHandler *)appSwitchHandler {
    [self.client postAnalyticsEvent:@"ios.paypal.adapter.appswitch.did-cancel"];
    [self informDelegateDidCancel];
}

@end
