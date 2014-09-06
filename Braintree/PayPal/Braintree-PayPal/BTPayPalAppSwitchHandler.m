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
    NSError *validationError = [[self class] validateClient:self.client delegate:self.delegate returnURLScheme:self.returnURLScheme];
    if (validationError) {
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

- (BOOL)initiateAppSwitchWithClient:(BTClient *)client delegate:(id<BTAppSwitchingDelegate>)theDelegate {

    client = [client copyWithMetadata:^(BTClientMutableMetadata *metadata) {
        metadata.source = BTClientMetadataSourcePayPalApp;
    }];

    _client = client;
    self.delegate = theDelegate;

    if ([self.client btPayPal_isTouchDisabled]){
        [self.client postAnalyticsEvent:@"ios.paypal.appswitch.initiate.disabled"];

        [self informDelegateDidFailWithErrorCode:BTPayPalErrorAppSwitchDisabled localizedDescription:@"PayPal app switch is not enabled."];
        return NO;
    }

    NSError *setupValidationError = [[self class] validateClient:self.client delegate:theDelegate returnURLScheme:self.returnURLScheme];
    if (setupValidationError) {
        [self.client postAnalyticsEvent:@"ios.paypal.appswitch.initiate.invalid"];
        [self informDelegateDidFailWithError:setupValidationError];
        return NO;
    }

    if (![PayPalTouch canAppSwitchForUrlScheme:self.returnURLScheme]) {
        [self.client postAnalyticsEvent:@"ios.paypal.appswitch.initiate.bad-callback-url-scheme"];
        NSString *errorMessage = [NSString stringWithFormat:@"The current appReturnURL (%@) is not supported by PayPal. Return URL schemes must start with this app's bundle id.", self.returnURLScheme];
        [self informDelegateDidFailWithErrorCode:BTPayPalErrorAppSwitchPayPalAppNotAvailable
                            localizedDescription:errorMessage];
        return NO;
    }

    PayPalConfiguration *configuration = client.btPayPal_configuration;
    configuration.callbackURLScheme = self.returnURLScheme;

    BOOL payPalTouchDidAuthorize = [PayPalTouch authorizeFuturePayments:configuration];
    if (!payPalTouchDidAuthorize) {
        [self.client postAnalyticsEvent:@"ios.paypal.appswitch.initiate.failure"];
        [self informDelegateDidFailWithErrorCode:BTPayPalErrorAppSwitchFailed
                            localizedDescription:@"Failed to initiate PayPal app switch."];
        return NO;
    }


    [self.client postAnalyticsEvent:@"ios.paypal.appswitch.initiate.success"];
    [self informDelegateWillAppSwitch];
    return YES;
}

+ (NSError *)validateClient:(BTClient *)client delegate:(id<BTAppSwitchingDelegate>)delegate returnURLScheme:(NSString *)returnURLScheme {
    if (client == nil) {
        return [NSError errorWithDomain:BTBraintreePayPalErrorDomain
                                   code:BTMerchantIntegrationErrorPayPalConfiguration
                               userInfo:@{ NSLocalizedDescriptionKey: @"PayPal app switch is missing a BTClient." }];
    }

    if (delegate == nil) {
        return [NSError errorWithDomain:BTBraintreePayPalErrorDomain
                                   code:BTMerchantIntegrationErrorPayPalConfiguration
                               userInfo:@{ NSLocalizedDescriptionKey: @"PayPal app switch is missing a delegate." }];
    }

    if (!returnURLScheme) {
        return [NSError errorWithDomain:BTBraintreePayPalErrorDomain
                                   code:BTMerchantIntegrationErrorPayPalConfiguration
                               userInfo:@{ NSLocalizedDescriptionKey: @"PayPal app switch is missing a returnURLScheme (See +[Braintree setReturnURLScheme:]." }];
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
