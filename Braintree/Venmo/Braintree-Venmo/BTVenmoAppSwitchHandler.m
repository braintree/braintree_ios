#import "BTVenmoAppSwitchHandler.h"
#import "BTVenmoAppSwitchHandler_Internal.h"
#import "BTVenmoAppSwitchRequestURL.h"
#import "BTVenmoAppSwitchReturnURL.h"
#import "BTClient+BTVenmo.h"
#import "BTVenmoErrors.h"
#import "BTClient_Metadata.h"
#import "BTMutableCardPaymentMethod.h"
#import "BTVenmoErrors.h"

@implementation BTVenmoAppSwitchHandler

@synthesize returnURLScheme = _returnURLScheme;
@synthesize delegate = _delegate;

- (BOOL)initiateAppSwitchWithClient:(BTClient *)client delegate:(id<BTAppSwitchingDelegate>)delegate {

    client = [client copyWithMetadata:^(BTClientMutableMetadata *metadata) {
        metadata.source = BTClientMetadataSourceVenmoApp;
    }];

    self.client = client;
    self.delegate = delegate;

    NSError *error = [self availabilityErrorForClient:client];
    if (error) {
        switch (error.code) {
            case BTVenmoErrorAppSwitchDisabled:
                [client postAnalyticsEvent:@"ios.venmo.appswitch.initiate.venmo-status-off"];
                break;
            case BTVenmoErrorIntegrationReturnURLScheme:
                [client postAnalyticsEvent:@"ios.venmo.appswitch.initiate.invalid-return-url-scheme"];
                break;
            case BTVenmoErrorIntegrationClientMerchantId:
                [client postAnalyticsEvent:@"ios.venmo.appswitch.initiate.invalid-merchant-id"];
                break;
            case BTVenmoErrorAppSwitchVenmoAppNotAvailable:
                [client postAnalyticsEvent:@"ios.venmo.appswitch.initiate.app-switch-unavailable"];
                break;
            default:
                [client postAnalyticsEvent:@"ios.venmo.appswitch.initiate.unrecognized-error"];
                break;
        }
        [self informDelegateDidFailWithError:error];
        return NO;
    }

    BOOL offline = client.btVenmo_status == BTVenmoStatusOffline;

    NSURL *venmoAppSwitchURL = [BTVenmoAppSwitchRequestURL appSwitchURLForMerchantID:client.merchantId returnURLScheme:self.returnURLScheme offline:offline];

    BOOL success = [[UIApplication sharedApplication] openURL:venmoAppSwitchURL];
    if (!success) {
        [client postAnalyticsEvent:@"ios.venmo.appswitch.initiate.failure"];
        [self informDelegateDidFailWithErrorCode:BTVenmoErrorAppSwitchFailed localizedDescription:@"UIApplication failed to perform app switch to Venmo."];
        return NO;
    }

    [client postAnalyticsEvent:@"ios.venmo.appswitch.initiate.success"];
    [self informDelegateWillSwitch];
    return YES;
}


- (BOOL)isAvailableForClient:(BTClient *)client {
    return [self availabilityErrorForClient:client] == nil;
}

- (NSError *)availabilityErrorForClient:(BTClient *)client {

    if ([client btVenmo_status] == BTVenmoStatusOff) {
        return [NSError errorWithDomain:BTVenmoErrorDomain
                                   code:BTVenmoErrorAppSwitchDisabled
                               userInfo:@{ NSLocalizedDescriptionKey:@"Venmo App Switch is not enabled." }];
    }

    if (!self.returnURLScheme) {
        return [NSError errorWithDomain:BTVenmoErrorDomain
                                   code:BTVenmoErrorIntegrationReturnURLScheme
                               userInfo:@{ NSLocalizedDescriptionKey:@"Venmo App Switch requires you to set a returnURLScheme. Please call +[Braintree setReturnURLScheme:]." }];
    }

    if (!client.merchantId) {
        return [NSError errorWithDomain:BTVenmoErrorDomain
                                   code:BTVenmoErrorIntegrationClientMerchantId
                               userInfo:@{ NSLocalizedDescriptionKey:@"Venmo App Switch could not find all required fields in the client token." }];
    }

    if (![BTVenmoAppSwitchRequestURL isAppSwitchAvailable]) {
        return [NSError errorWithDomain:BTVenmoErrorDomain
                                   code:BTVenmoErrorAppSwitchVenmoAppNotAvailable
                               userInfo:@{ NSLocalizedDescriptionKey:@"No version of the Venmo app is installed on this device that is compatible with app switch." }];
    }

    return nil;
}

- (BOOL)canHandleReturnURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication {
    return [BTVenmoAppSwitchReturnURL isValidURL:url sourceApplication:sourceApplication];
}

- (void)handleReturnURL:(NSURL *)url {
    BTVenmoAppSwitchReturnURL *returnURL = [[BTVenmoAppSwitchReturnURL alloc] initWithURL:url];
    switch (returnURL.state) {
        case BTVenmoAppSwitchReturnURLStateSucceeded: {
            [self informDelegateWillCreatePaymentMethod];
            [self.client postAnalyticsEvent:@"ios.venmo.appswitch.handle.authorized"];

            switch (self.client.btVenmo_status) {
                case BTVenmoStatusOffline:
                    /* FALLTHROUGH */
                    [self.client postAnalyticsEvent:@"ios.venmo.appswitch.handle.offline"];
                case BTVenmoStatusProduction: {
                    [self.client fetchPaymentMethodWithNonce:returnURL.paymentMethod.nonce
                                                     success:^(BTPaymentMethod *paymentMethod){
                                                         [self.client postAnalyticsEvent:@"ios.venmo.appswitch.handle.success"];
                                                         [self informDelegateDidCreatePaymentMethod:paymentMethod];
                                                     }
                                                     failure:^(NSError *error){
                                                         [self.client postAnalyticsEvent:@"ios.venmo.appswitch.handle.client-failure"];
                                                         NSError *venmoError = [NSError errorWithDomain:BTVenmoErrorDomain
                                                                                                   code:BTVenmoErrorFailureFetchingPaymentMethod
                                                                                               userInfo:@{NSLocalizedDescriptionKey: @"Failed to fetch payment method",
                                                                                                          NSUnderlyingErrorKey: error}];
                                                         [self informDelegateDidFailWithError:venmoError];
                                                     }];
                    break;
                }
                case BTVenmoStatusOff: {
                    NSError *error = [NSError errorWithDomain:BTVenmoErrorDomain
                                                         code:BTVenmoErrorAppSwitchDisabled
                                                     userInfo:@{ NSLocalizedDescriptionKey: @"Received a Venmo app switch return while Venmo is disabled" }];
                    [self informDelegateDidFailWithError:error];
                    [self.client postAnalyticsEvent:@"ios.venmo.appswitch.handle.off"];
                    break;
                }
            }
            break;
        }
        case BTVenmoAppSwitchReturnURLStateFailed:
            [self.client postAnalyticsEvent:@"ios.venmo.appswitch.handle.error"];
            [self informDelegateDidFailWithError:returnURL.error];
            break;
        case BTVenmoAppSwitchReturnURLStateCanceled:
            [self.client postAnalyticsEvent:@"ios.venmo.appswitch.handle.cancel"];
            [self informDelegateDidCancel];
            break;
        default:
            // should not happen
            break;
    }
}

#pragma mark Delegate Informers

- (void)informDelegateWillSwitch {
    if ([self.delegate respondsToSelector:@selector(appSwitcherWillSwitch:)]) {
        [self.delegate appSwitcherWillSwitch:self];
    }
}

- (void)informDelegateWillCreatePaymentMethod {
    if ([self.delegate respondsToSelector:@selector(appSwitcherWillCreatePaymentMethod:)]) {
        [self.delegate appSwitcherWillCreatePaymentMethod:self];
    }
}

- (void)informDelegateDidCreatePaymentMethod:(BTPaymentMethod *)paymentMethod {
    if ([self.delegate respondsToSelector:@selector(appSwitcher:didCreatePaymentMethod:)]) {
        [self.delegate appSwitcher:self didCreatePaymentMethod:paymentMethod];
    }
}

- (void)informDelegateDidFailWithError:(NSError *)error {
    if ([self.delegate respondsToSelector:@selector(appSwitcher:didFailWithError:)]) {
        [self.delegate appSwitcher:self didFailWithError:error];
    }
}

- (void)informDelegateDidFailWithErrorCode:(NSInteger)code localizedDescription:(NSString *)localizedDescription {
    NSError *error = [NSError errorWithDomain:BTVenmoErrorDomain
                                         code:code
                                     userInfo:@{ NSLocalizedDescriptionKey:localizedDescription }];
    [self informDelegateDidFailWithError:error];
}

- (void)informDelegateDidCancel {
    if ([self.delegate respondsToSelector:@selector(appSwitcherDidCancel:)]) {
        [self.delegate appSwitcherDidCancel:self];
    }
}

#pragma mark Singleton

+ (instancetype)sharedHandler {
    static BTVenmoAppSwitchHandler *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[BTVenmoAppSwitchHandler alloc] init];
    });
    return instance;
}

@end
