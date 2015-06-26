#import "BTVenmoAppSwitchHandler.h"
#import "BTVenmoAppSwitchHandler_Internal.h"
#import "BTVenmoAppSwitchRequestURL.h"
#import "BTVenmoAppSwitchReturnURL.h"
#import "BTClient+BTVenmo.h"
#import "BTClient_Internal.h"
#import "BTMutableCardPaymentMethod.h"
#import "BTAppSwitch.h"

#import <UIKit/UIKit.h>

@implementation BTVenmoAppSwitchHandler

@synthesize returnURLScheme = _returnURLScheme;
@synthesize delegate = _delegate;

+ (void)load {
    if (self == [BTVenmoAppSwitchHandler class]) {
        [[BTAppSwitch sharedInstance] addAppSwitching:[BTVenmoAppSwitchHandler sharedHandler] forApp:BTAppTypeVenmo];
    }
}

- (BOOL)initiateAppSwitchWithClient:(BTClient *)client delegate:(id<BTAppSwitchingDelegate>)delegate error:(NSError *__autoreleasing *)error {

    client = [client copyWithMetadata:^(BTClientMutableMetadata *metadata) {
        metadata.source = BTClientMetadataSourceVenmoApp;
    }];

    NSError *appSwitchError = [self appSwitchErrorForClient:client];
    if (appSwitchError) {
        if ([appSwitchError.domain isEqualToString:BTAppSwitchErrorDomain]) {
            switch (appSwitchError.code) {
                case BTAppSwitchErrorDisabled:
                    [client postAnalyticsEvent:@"ios.venmo.appswitch.initiate.error.disabled"];
                    break;
                case BTAppSwitchErrorIntegrationReturnURLScheme:
                    [client postAnalyticsEvent:@"ios.venmo.appswitch.initiate.error.invalid.return-url-scheme"];
                    break;
                case BTAppSwitchErrorIntegrationMerchantId:
                    [client postAnalyticsEvent:@"ios.venmo.appswitch.initiate.error.invalid.merchant-id"];
                    break;
                case BTAppSwitchErrorAppNotAvailable:
                    [client postAnalyticsEvent:@"ios.venmo.appswitch.initiate.error.unavailable"];
                    break;
                default:
                    [client postAnalyticsEvent:@"ios.venmo.appswitch.initiate.error.unrecognized-error"];
                    break;
            }
        }
        if (error) {
            *error = appSwitchError;
        }
        return NO;
    }

    self.client = client;
    self.delegate = delegate;

    BOOL offline = client.btVenmo_status == BTVenmoStatusOffline;

    NSURL *venmoAppSwitchURL = [BTVenmoAppSwitchRequestURL appSwitchURLForMerchantID:client.merchantId
                                                                     returnURLScheme:self.returnURLScheme
                                                                             offline:offline
                                                                               error:error];
    if (*error) {
        return NO;
    }

    BOOL success = [[UIApplication sharedApplication] openURL:venmoAppSwitchURL];
    if (success) {
        [client postAnalyticsEvent:@"ios.venmo.appswitch.initiate.success"];
    } else {
        [client postAnalyticsEvent:@"ios.venmo.appswitch.initiate.error.failure"];
        if (error) {
            *error = [NSError errorWithDomain:BTAppSwitchErrorDomain
                                         code:BTAppSwitchErrorFailed
                                     userInfo:@{NSLocalizedDescriptionKey: @"UIApplication failed to perform app switch to Venmo."}];
        }
        return NO;
    }
    return YES;
}


- (BOOL)appSwitchAvailableForClient:(BTClient *)client {
    return [self appSwitchErrorForClient:client] == nil;
}

- (NSError *)appSwitchErrorForClient:(BTClient *)client {

    if ([client btVenmo_status] == BTVenmoStatusOff) {
        return [NSError errorWithDomain:BTAppSwitchErrorDomain
                                   code:BTAppSwitchErrorDisabled
                               userInfo:@{ NSLocalizedDescriptionKey:@"Venmo App Switch is not enabled." }];
    }

    if (!self.returnURLScheme) {
        return [NSError errorWithDomain:BTAppSwitchErrorDomain
                                   code:BTAppSwitchErrorIntegrationReturnURLScheme
                               userInfo:@{ NSLocalizedDescriptionKey:@"Venmo App Switch requires you to set a returnURLScheme. Please call +[Braintree setReturnURLScheme:]." }];
    }

    if (!client.merchantId) {
        return [NSError errorWithDomain:BTAppSwitchErrorDomain
                                   code:BTAppSwitchErrorIntegrationMerchantId
                               userInfo:@{ NSLocalizedDescriptionKey:@"Venmo App Switch could not find all required fields in the client token." }];
    }

    if (![BTVenmoAppSwitchRequestURL isAppSwitchAvailable]) {
        return [NSError errorWithDomain:BTAppSwitchErrorDomain
                                   code:BTAppSwitchErrorAppNotAvailable
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
                                                         NSError *venmoError = [NSError errorWithDomain:BTAppSwitchErrorDomain
                                                                                                   code:BTAppSwitchErrorFailureFetchingPaymentMethod
                                                                                               userInfo:@{NSLocalizedDescriptionKey: @"Failed to fetch payment method",
                                                                                                          NSUnderlyingErrorKey: error}];
                                                         [self informDelegateDidFailWithError:venmoError];
                                                     }];
                    break;
                }
                case BTVenmoStatusOff: {
                    NSError *error = [NSError errorWithDomain:BTAppSwitchErrorDomain
                                                         code:BTAppSwitchErrorDisabled
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
    NSError *error = [NSError errorWithDomain:BTAppSwitchErrorDomain
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
