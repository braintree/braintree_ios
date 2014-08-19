#import "BTVenmoAppSwitchHandler.h"
#import "BTVenmoAppSwitchReturnURL.h"

@implementation BTVenmoAppSwitchHandler

- (BOOL)initiateAppSwitchWithClient:(BTClient *)client delegate:(id)delegate {
    NSLog(@"%@ %@", client, delegate);
    return YES;
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
