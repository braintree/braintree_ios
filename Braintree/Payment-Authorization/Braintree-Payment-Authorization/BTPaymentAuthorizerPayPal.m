#import "BTPaymentAuthorizer_Protected.h"
#import "BTPaymentAuthorizerPayPal.h"

#import "BTPayPalViewController.h"
#import "BTPayPalAppSwitchHandler.h"
#import "BTClient+BTPayPal.h"
#import "BTLogger.h"

@interface BTPaymentAuthorizerPayPal ()<BTPayPalViewControllerDelegate>
@end

@implementation BTPaymentAuthorizerPayPal

- (void)setClient:(BTClient *)client {
    _client = client;
    NSError *error;
    [self.client btPayPal_preparePayPalMobileWithError:&error];
    if (error) {
        [self.client postAnalyticsEvent:@"ios.paypal.authorizer.init.error"];
        [[BTLogger sharedLogger] log:[NSString stringWithFormat:@"PayPal is unavailable: %@", [error localizedDescription]]];
    }
}

- (BOOL)authorize {
    BOOL appSwitchInitiated = [[BTPayPalAppSwitchHandler sharedHandler] initiateAppSwitchWithClient:self.client delegate:self];

    if (appSwitchInitiated) {
        [self.client postAnalyticsEvent:@"ios.paypal.authorizer.appswitch.initiate"];
        [self informDelegateWillRequestUserChallengeWithAppSwitch];
    } else {
        [self.client postAnalyticsEvent:@"ios.paypal.authorizer.viewcontroller.initiate"];
        [[BTLogger sharedLogger] log:@"PayPal Touch is unavailable: falling back to BTPayPalViewController"];

        BTPayPalViewController *braintreePayPalViewController = [[BTPayPalViewController alloc] initWithClient:self.client];
        braintreePayPalViewController.delegate = self;
        [self informDelegateRequestsUserChallengeWithViewController:braintreePayPalViewController];
    }
    return YES;
}

#pragma mark BTPayPalViewControllerDelegate

- (void)payPalViewControllerWillCreatePayPalPaymentMethod:(BTPayPalViewController *)viewController {
    [self.client postAnalyticsEvent:@"ios.paypal.authorizer.viewcontroller.will-create-payment-method"];
    [self informDelegateRequestsDismissalOfUserChallengeViewController:viewController];
}

- (void)payPalViewController:(__unused BTPayPalViewController *)viewController didCreatePayPalPaymentMethod:(BTPayPalPaymentMethod *)payPalPaymentMethod {
    [self.client postAnalyticsEvent:@"ios.paypal.authorizer.viewcontroller.did-create-payment-method"];
    [self informDelegateDidCreatePaymentMethod:payPalPaymentMethod];
}

- (void)payPalViewController:(__unused BTPayPalViewController *)viewController didFailWithError:(NSError *)error {
    [self.client postAnalyticsEvent:@"ios.paypal.authorizer.viewcontroller.did-fail-with-error"];
    [self informDelegateDidFailWithError:error];
}

- (void)payPalViewControllerDidCancel:(BTPayPalViewController *)viewController {
    [self.client postAnalyticsEvent:@"ios.paypal.authorizer.viewcontroller.did-cancel"];
    [self informDelegateRequestsDismissalOfUserChallengeViewController:viewController];
}

@end
