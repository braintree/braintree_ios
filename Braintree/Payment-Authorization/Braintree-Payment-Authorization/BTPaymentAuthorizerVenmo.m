#import "BTPaymentAuthorizerVenmo.h"
#import "BTPaymentAuthorizer_Protected.h"

#import "BTVenmoAppSwitchHandler.h"
#import "BTClient+BTPayPal.h"
#import "BTLogger.h"

@implementation BTPaymentAuthorizerVenmo

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
    BOOL appSwitchInitiated = [[BTVenmoAppSwitchHandler sharedHandler] initiateAppSwitchWithClient:self.client delegate:self];

    if (appSwitchInitiated) {
        [self.client postAnalyticsEvent:@"ios.venmo.authorizer.appswitch.initiate"];
        [self informDelegateWillRequestUserChallengeWithAppSwitch];
    }
    return appSwitchInitiated;
}

@end
