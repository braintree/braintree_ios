#import "BTPayPalAppSwitchHandler_Internal.h"

#import "BTClient_Metadata.h"
#import "BTClient+BTPayPal.h"
#import "BTMutablePayPalPaymentMethod.h"
#import "BTLogger.h"
#import "BTErrors+BTPayPal.h"

#import "PayPalMobile.h"
#import "PayPalTouch.h"

@implementation BTPayPalAppSwitchHandler

@synthesize returnURLScheme;
@synthesize delegate;

+ (instancetype)sharedHandler {
    static BTPayPalAppSwitchHandler *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[BTPayPalAppSwitchHandler alloc] init];
    });
    return instance;
}

- (BOOL)canHandleReturnURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication {
    if (self.client == nil || self.delegate == nil) {
        [self.client postAnalyticsEvent:@"ios.paypal.appswitch.can-handle.invalid"];
        return NO;
    }

    if (![url.scheme isEqualToString:self.returnURLScheme]) {
        [self.client postAnalyticsEvent:@"ios.paypal.appswitch.can-handle.different-scheme"];
        return NO;
    }

    if (![PayPalTouch canHandleURL:url sourceApplication:sourceApplication]) {
        [self.client postAnalyticsEvent:@"ios.paypal.appswitch.can-handle.paypal-cannot-handle"];
        return NO;
    }
    return YES;
}

- (void)handleReturnURL:(NSURL *)url {
    PayPalTouchResult *result = [PayPalTouch parseAppSwitchURL:url];
    NSString *code;
    switch (result.resultType) {
        case PayPalTouchResultTypeError: {
            [self.client postAnalyticsEvent:@"ios.paypal.appswitch.handle.error"];
            NSError *error = [NSError errorWithDomain:BTBraintreePayPalErrorDomain code:BTPayPalUnknownError userInfo:nil];
            [self informDelegateDidFailWithError:error];
            return;
        }
        case PayPalTouchResultTypeCancel:
            [self.client postAnalyticsEvent:@"ios.paypal.appswitch.handle.cancel"];
            if (result.error) {
                [self.client postAnalyticsEvent:@"ios.paypal.appswitch.handle.cancel-error"];
                [[BTLogger sharedLogger] log:[NSString stringWithFormat:@"PayPal Wallet error: %@", result.error]];
            }
            [self informDelegateDidCancel];
            return;
        case PayPalTouchResultTypeSuccess:
            code = result.authorization[@"response"][@"code"];
            break;
    }

    if (!code) {
        NSError *error = [NSError errorWithDomain:BTBraintreePayPalErrorDomain code:BTPayPalUnknownError userInfo:@{NSLocalizedDescriptionKey: @"Auth code not found in PayPal Touch app switch response" }];
        [self.client postAnalyticsEvent:@"ios.paypal.appswitch.handle.code-error"];
        [self informDelegateDidFailWithError:error];
        return;
    }

    [self.client postAnalyticsEvent:@"ios.paypal.appswitch.handle.authorized"];

    [self informDelegateWillCreatePayPalPaymentMethod];

    [self.client savePaypalPaymentMethodWithAuthCode:code
                            applicationCorrelationID:[self.client btPayPal_applicationCorrelationId]
                                             success:^(BTPayPalPaymentMethod *paypalPaymentMethod) {
                                                 NSString *userDisplayStringFromAppSwitchResponse = result.authorization[@"user"][@"display_string"];
                                                 if (paypalPaymentMethod.email == nil && [userDisplayStringFromAppSwitchResponse isKindOfClass:[NSString class]]) {
                                                     BTMutablePayPalPaymentMethod *mutablePayPalPaymentMethod = [paypalPaymentMethod mutableCopy];
                                                     mutablePayPalPaymentMethod.email = userDisplayStringFromAppSwitchResponse;
                                                     paypalPaymentMethod = mutablePayPalPaymentMethod;
                                                 }
                                                 [self.client postAnalyticsEvent:@"ios.paypal.appswitch.handle.success"];
                                                 [self informDelegateDidCreatePayPalPaymentMethod:paypalPaymentMethod];
                                             } failure:^(NSError *error) {
                                                 [self.client postAnalyticsEvent:@"ios.paypal.appswitch.handle.client-failure"];
                                                 [self informDelegateDidFailWithError:error];
                                             }];

}

- (NSError *)initiateAppSwitchWithClient:(BTClient *)client delegate:(id<BTAppSwitchingDelegate>)theDelegate {

    client = [client copyWithMetadata:^(BTClientMutableMetadata *metadata) {
        metadata.source = BTClientMetadataSourcePayPalApp;
    }];

    NSError *error = [self appSwitchErrorForClient:client delegate:theDelegate];
    if (error) {
        if ([error.domain isEqualToString:BTBraintreePayPalErrorDomain]) {
            switch (error.code) {
                case BTPayPalErrorPayPalDisabled:
                    [client postAnalyticsEvent:@"ios.paypal.appswitch.initiate.error.disabled"];
                    break;
                case BTPayPalErrorAppSwitchDisabled:
                    [client postAnalyticsEvent:@"ios.paypal.appswitch.initiate.error.app-switch-disabled"];
                    break;
                case BTPayPalErrorAppSwitchUnavailable:
                    [client postAnalyticsEvent:@"ios.paypal.appswitch.initiate.error.unavailable"];
                    break;
                case BTPayPalErrorAppSwitchReturnURLScheme:
                    [client postAnalyticsEvent:@"ios.paypal.appswitch.initiate.error.invalid.return-url-scheme"];
                    break;
                case BTPayPalErrorAppSwitchInvalidParameters:
                    [client postAnalyticsEvent:@"ios.paypal.appswitch.initiate.error.invalid.parameters"];
                    break;
                default:
                    [client postAnalyticsEvent:@"ios.paypal.appswitch.initiate.error.unrecognized-error"];
                    break;
            }
        }
        return error;
    }

    self.delegate = theDelegate;
    self.client = client;

    PayPalConfiguration *configuration = client.btPayPal_configuration;
    configuration.callbackURLScheme = self.returnURLScheme;

    BOOL payPalTouchDidAuthorize = [PayPalTouch authorizeFuturePayments:configuration];
    if (payPalTouchDidAuthorize) {
        [self.client postAnalyticsEvent:@"ios.paypal.appswitch.initiate.success"];
        [self informDelegateWillAppSwitch];
    } else {
        [self.client postAnalyticsEvent:@"ios.paypal.appswitch.initiate.error.failed"];
        error = [NSError errorWithDomain:BTBraintreePayPalErrorDomain
                                    code:BTPayPalErrorAppSwitchFailed
                                userInfo:@{NSLocalizedDescriptionKey:@"Failed to initiate PayPal app switch."}];
    }

    return error;
}

- (BOOL)appSwitchAvailableForClient:(BTClient *)client {
    return [self appSwitchErrorForClient:client] == nil;
}

- (NSError *)appSwitchErrorForClient:(BTClient *)client delegate:(id<BTAppSwitchingDelegate>)theDelegate {
    if (theDelegate == nil) {
        return [NSError errorWithDomain:BTBraintreePayPalErrorDomain
                                   code:BTPayPalErrorAppSwitchInvalidParameters
                               userInfo:@{ NSLocalizedDescriptionKey: @"PayPal app switch is missing a delegate." }];
    }
    return [self appSwitchErrorForClient:client];
}

- (NSError *)appSwitchErrorForClient:(BTClient *)client {
    if (client == nil) {
        return [NSError errorWithDomain:BTBraintreePayPalErrorDomain
                                   code:BTPayPalErrorAppSwitchInvalidParameters
                               userInfo:@{ NSLocalizedDescriptionKey: @"PayPal app switch is missing a BTClient." }];
    }

    if (![client btPayPal_isPayPalEnabled]){
        return [NSError errorWithDomain:BTBraintreePayPalErrorDomain
                                   code:BTPayPalErrorPayPalDisabled
                               userInfo:@{NSLocalizedDescriptionKey: @"PayPal is not enabled for this merchant."}];
    }

    if ([client btPayPal_isTouchDisabled]){
        return [NSError errorWithDomain:BTBraintreePayPalErrorDomain
                                   code:BTPayPalErrorAppSwitchDisabled
                               userInfo:@{NSLocalizedDescriptionKey: @"PayPal app switch is not enabled."}];
    }

    if (self.returnURLScheme == nil) {
        return [NSError errorWithDomain:BTBraintreePayPalErrorDomain
                                   code:BTPayPalErrorAppSwitchReturnURLScheme
                               userInfo:@{ NSLocalizedDescriptionKey: @"PayPal app switch is missing a returnURLScheme (See +[Braintree setReturnURLScheme:]." }];
    }

    if (![PayPalTouch canAppSwitchForUrlScheme:self.returnURLScheme]) {
        NSString *errorMessage = [NSString stringWithFormat:@"Can not app switch to PayPal. Verify that the return URL scheme (%@) starts with this app's bundle id, and that the PayPal app is installed.", self.returnURLScheme];
        return [NSError errorWithDomain:BTBraintreePayPalErrorDomain
                                   code:BTPayPalErrorAppSwitchUnavailable
                               userInfo:@{ NSLocalizedDescriptionKey: errorMessage }];
    }


    return nil;
}


#pragma mark Delegate Method Invocations

- (void)informDelegateWillAppSwitch {
    if ([self.delegate respondsToSelector:@selector(appSwitcherWillSwitch:)]) {
        [self.delegate appSwitcherWillSwitch:self];
    }
}

- (void)informDelegateWillCreatePayPalPaymentMethod {
    if ([self.delegate respondsToSelector:@selector(appSwitcherWillCreatePaymentMethod:)]) {
        [self.delegate appSwitcherWillCreatePaymentMethod:self];
    }
}

- (void)informDelegateDidCreatePayPalPaymentMethod:(BTPaymentMethod *)paymentMethod {
    [self.delegate appSwitcher:self didCreatePaymentMethod:paymentMethod];
}

- (void)informDelegateDidFailWithError:(NSError *)error {
    [self.delegate appSwitcher:self didFailWithError:error];
}

- (void)informDelegateDidFailWithErrorCode:(NSInteger)code localizedDescription:(NSString *)localizedDescription {
    NSError *error = [NSError errorWithDomain:BTBraintreePayPalErrorDomain
                                         code:code
                                     userInfo:@{ NSLocalizedDescriptionKey:localizedDescription }];
    [self informDelegateDidFailWithError:error];
}

- (void)informDelegateDidCancel {
    [self.delegate appSwitcherDidCancel:self];
}

@end
