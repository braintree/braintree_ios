#import "BTVenmoAppSwitchHandler.h"
#import "BTVenmoAppSwitchRequestURL.h"
#import "BTVenmoAppSwitchReturnURL.h"
#import "BTClient+BTVenmo.h"
#import "BTClient_Metadata.h"
#import "BTMutableCardPaymentMethod.h"
#import "BTVenmoErrors.h"

@interface BTVenmoAppSwitchHandler ()
@property (nonatomic, strong) BTClient *client;
@end

@implementation BTVenmoAppSwitchHandler

@synthesize returnURLScheme = _returnURLScheme;
@synthesize delegate = _delegate;

- (BOOL)initiateAppSwitchWithClient:(BTClient *)client delegate:(id<BTAppSwitchingDelegate>)delegate {

    client = [client copyWithMetadata:^(BTClientMutableMetadata *metadata) {
        metadata.source = BTClientMetadataSourceVenmoApp;
    }];

    self.client = client;
    self.delegate = delegate;

    if ([client btVenmo_status] == BTVenmoStatusOff) {
        [client postAnalyticsEvent:@"ios.venmo.appswitch.initiate.venmo-status-off"];
        [self informDelegateDidFailWithErrorCode:BTVenmoErrorAppSwitchDisabled localizedDescription:@"Venmo App Switch is not enabled."];
        return NO;
    }

    if (!self.returnURLScheme) {
        [client postAnalyticsEvent:@"ios.venmo.appswitch.initiate.nil-return-url-scheme"];
        [self informDelegateDidFailWithErrorCode:BTVenmoErrorInvalidIntegration localizedDescription:@"Venmo App Switch requires you to set a returnURLScheme. Please call +[Braintree setReturnURLScheme:]."];
        return NO;
    }

    if (!client.merchantId) {
        [client postAnalyticsEvent:@"ios.venmo.appswitch.initiate.nil-merchant-id"];
        [self informDelegateDidFailWithErrorCode:BTVenmoErrorInvalidIntegration localizedDescription:@"Venmo App Switch could not find all required fields in the client token."];
        return NO;
    }

    if (![BTVenmoAppSwitchRequestURL isAppSwitchAvailable]) {
        [client postAnalyticsEvent:@"ios.venmo.appswitch.initiate.app-switch-unavailable"];
        [self informDelegateDidFailWithErrorCode:BTVenmoErrorAppSwitchVenmoAppNotAvailable localizedDescription:@"No version of the Venmo app is installed on this device that is compatible with app switch."];
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

+ (BOOL)isAvailableForClient:(BTClient *)client {
    return [BTVenmoAppSwitchRequestURL isAppSwitchAvailable] && client.btVenmo_status != BTVenmoStatusOff;
}

- (BOOL)canHandleReturnURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication {
    return [BTVenmoAppSwitchReturnURL isValidURL:url sourceApplication:sourceApplication];
}

- (void)handleReturnURL:(NSURL *)url {
    [self informDelegateWillCreatePaymentMethod];
    BTVenmoAppSwitchReturnURL *returnURL = [[BTVenmoAppSwitchReturnURL alloc] initWithURL:url];
    switch (returnURL.state) {
        case BTVenmoAppSwitchReturnURLStateSucceeded: {
            [self.client postAnalyticsEvent:@"ios.venmo.appswitch.handle.authorized"];

            switch (self.client.btVenmo_status) {
                case BTVenmoStatusOffline: {
                    [self.client postAnalyticsEvent:@"ios.venmo.appswitch.handle.offline"];
                    BTMutableCardPaymentMethod *fakeCard = [[BTMutableCardPaymentMethod alloc] init];
                    fakeCard.lastTwo = @"11";
                    fakeCard.type = BTCardTypeVisa;
                    fakeCard.nonce = returnURL.paymentMethod.nonce;
                    [self informDelegateDidCreatePaymentMethod:fakeCard];
                    break;
                }
                case BTVenmoStatusProduction: {
                    [self.client fetchPaymentMethodWithNonce:returnURL.paymentMethod.nonce
                                                     success:^(BTPaymentMethod *paymentMethod){
                                                         [self.client postAnalyticsEvent:@"ios.venmo.appswitch.handle.success"];
                                                         [self informDelegateDidCreatePaymentMethod:paymentMethod];
                                                     }
                                                     failure:^(NSError *error){
                                                         [self.client postAnalyticsEvent:@"ios.venmo.appswitch.handle.client-failure"];
                                                         [self informDelegateDidFailWithError:error];
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
