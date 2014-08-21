#import "BTVenmoAppSwitchHandler.h"
#import "BTVenmoAppSwitchURL.h"
#import "BTVenmoAppSwitchReturnURL.h"

@implementation BTVenmoAppSwitchHandler

- (BOOL)initiateAppSwitchWithClient:(__unused BTClient *)client delegate:(__unused id)delegate {
    if (!self.returnURLScheme) {
        return NO;
    }

    if (![BTVenmoAppSwitchURL isAppSwitchAvailable]) {
        return NO;
    }
//        NSString *merchantID = client.merchantID;
    NSString *merchantID = @"xxx";
    NSURL *venmoAppSwitchURL = [BTVenmoAppSwitchURL appSwitchURLForMerchantID:merchantID returnURLScheme:self.returnURLScheme];
    self.delegate = delegate;
    return [[UIApplication sharedApplication] openURL:venmoAppSwitchURL];
}

- (BOOL)canHandleReturnURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication {
    return [BTVenmoAppSwitchReturnURL isValidURL:url sourceApplication:sourceApplication];
}

- (void)handleReturnURL:(NSURL *)url {
    [self.delegate appSwitchHandlerWillCreatePaymentMethod:self];
    BTVenmoAppSwitchReturnURL *returnURL = [[BTVenmoAppSwitchReturnURL alloc] initWithURL:url];
    switch (returnURL.state) {
        case BTVenmoAppSwitchReturnURLStateSucceeded:
            [self.delegate appSwitchHandler:self didCreatePaymentMethod:returnURL.paymentMethod];
            break;
        case BTVenmoAppSwitchReturnURLStateFailed:
            // TODO - failure
            break;
        case BTVenmoAppSwitchReturnURLStateCanceled:
            [self.delegate appSwitchHandlerDidCancel:self];
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
