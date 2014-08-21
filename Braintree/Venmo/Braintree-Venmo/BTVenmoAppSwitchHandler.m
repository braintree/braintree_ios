#import "BTVenmoAppSwitchHandler.h"
#import "BTVenmoAppSwitchURL.h"
#import "BTVenmoAppSwitchReturnURL.h"

@implementation BTVenmoAppSwitchHandler

@synthesize returnURLScheme;
@synthesize delegate;

- (BOOL)initiateAppSwitchWithClient:(__unused BTClient *)client delegate:(__unused id<BTAppSwitchingDelegate>)theDelegate {
    if (!self.returnURLScheme) {
        return NO;
    }

    if (![BTVenmoAppSwitchURL isAppSwitchAvailable]) {
        return NO;
    }
//        NSString *merchantID = client.merchantID;
    NSString *merchantID = @"xxx";
    NSURL *venmoAppSwitchURL = [BTVenmoAppSwitchURL appSwitchURLForMerchantID:merchantID returnURLScheme:self.returnURLScheme];
    self.delegate = theDelegate;
    return [[UIApplication sharedApplication] openURL:venmoAppSwitchURL];
}

- (BOOL)canHandleReturnURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication {
    return [BTVenmoAppSwitchReturnURL isValidURL:url sourceApplication:sourceApplication];
}

- (void)handleReturnURL:(NSURL *)url {
    [self.delegate appSwitcherWillCreatePaymentMethod:self];
    BTVenmoAppSwitchReturnURL *returnURL = [[BTVenmoAppSwitchReturnURL alloc] initWithURL:url];
    switch (returnURL.state) {
        case BTVenmoAppSwitchReturnURLStateSucceeded:
            [self.delegate appSwitcher:self didCreatePaymentMethod:returnURL.paymentMethod];
            break;
        case BTVenmoAppSwitchReturnURLStateFailed:
            // TODO - failure
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
