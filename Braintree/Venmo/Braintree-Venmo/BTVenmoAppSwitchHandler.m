#import "BTVenmoAppSwitchHandler.h"
#import "BTVenmoAppSwitchURL.h"
#import "BTVenmoAppSwitchReturnURL.h"

@implementation BTVenmoAppSwitchHandler

- (BOOL)initiateAppSwitchWithClient:(__unused BTClient *)client delegate:(__unused id)delegate {
    if (!self.callbackURLScheme) {
        return NO;
    }

    if (![BTVenmoAppSwitchURL isAppSwitchAvailable]) {
        return NO;
    }
//        NSString *merchantID = client.merchantID;
    NSString *merchantID = @"xxx";
    NSURL *venmoAppSwitchURL = [BTVenmoAppSwitchURL appSwitchURLForMerchantID:merchantID returnURLScheme:self.callbackURLScheme];
    return [[UIApplication sharedApplication] openURL:venmoAppSwitchURL];
}

- (BOOL)canHandleReturnURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication {
    return [BTVenmoAppSwitchReturnURL isValidURL:url sourceApplication:sourceApplication];
}

- (void)handleReturnURL:(NSURL *)url {
    BTVenmoAppSwitchReturnURL *returnURL = [[BTVenmoAppSwitchReturnURL alloc] initWithURL:url];
    switch (returnURL.state) {
        case BTVenmoAppSwitchReturnURLStateSucceeded:
            // delegate 1
            break;
        case BTVenmoAppSwitchReturnURLStateFailed:
            // delegate 2
            break;
        case BTVenmoAppSwitchReturnURLStateCanceled:
            // delegate 3
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
