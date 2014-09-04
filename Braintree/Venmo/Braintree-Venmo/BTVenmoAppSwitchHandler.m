#import "BTVenmoAppSwitchHandler.h"
#import "BTVenmoAppSwitchRequestURL.h"
#import "BTVenmoAppSwitchReturnURL.h"

@interface BTVenmoAppSwitchHandler ()
@property (nonatomic, strong) BTClient *client;
@end

@implementation BTVenmoAppSwitchHandler

@synthesize returnURLScheme;
@synthesize delegate;

- (BOOL)initiateAppSwitchWithClient:(BTClient *)client delegate:(__unused id<BTAppSwitchingDelegate>)theDelegate {
    self.client = client;

    if (!self.returnURLScheme) {
        return NO;
    }

    if (!client.merchantId) {
        return NO;
    }

    if (![BTVenmoAppSwitchRequestURL isAppSwitchAvailable]) {
        return NO;
    }

    NSURL *venmoAppSwitchURL = [BTVenmoAppSwitchRequestURL appSwitchURLForMerchantID:client.merchantId returnURLScheme:self.returnURLScheme];
    self.delegate = theDelegate;

    if ([self.delegate respondsToSelector:@selector(appSwitcherWillSwitch:)]) {
        [self.delegate appSwitcherWillSwitch:self];
    }
    return [[UIApplication sharedApplication] openURL:venmoAppSwitchURL];
}

+ (BOOL)isAvailable {
    return [BTVenmoAppSwitchRequestURL isAppSwitchAvailable];
}

- (BOOL)canHandleReturnURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication {
    return [BTVenmoAppSwitchReturnURL isValidURL:url sourceApplication:sourceApplication];
}

- (void)handleReturnURL:(NSURL *)url {
    if ([self.delegate respondsToSelector:@selector(appSwitcherWillCreatePaymentMethod:)]) {
        [self.delegate appSwitcherWillCreatePaymentMethod:self];
    }
    BTVenmoAppSwitchReturnURL *returnURL = [[BTVenmoAppSwitchReturnURL alloc] initWithURL:url];
    switch (returnURL.state) {
        case BTVenmoAppSwitchReturnURLStateSucceeded: {
            [self.client fetchPaymentMethodWithNonce:returnURL.paymentMethod.nonce
                                             success:^(BTPaymentMethod *paymentMethod){
                                                 [self.delegate appSwitcher:self didCreatePaymentMethod:paymentMethod];
                                             }
                                             failure:^(NSError *error){
                                                 // TODO: Wrap error
                                                 [self.delegate appSwitcher:self didFailWithError:error];
                                             }];
            break;
        }
        case BTVenmoAppSwitchReturnURLStateFailed:
            [self.delegate appSwitcher:self didFailWithError:returnURL.error];
            break;
        case BTVenmoAppSwitchReturnURLStateCanceled:
            [self.delegate appSwitcherDidCancel:self];
            break;
        default:
            // should not happen
            break;
    }
}

+ (instancetype)sharedHandler {
    static BTVenmoAppSwitchHandler *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[BTVenmoAppSwitchHandler alloc] init];
    });
    return instance;
}

@end
