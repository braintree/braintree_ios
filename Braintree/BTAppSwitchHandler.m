#import "BTAppSwitchHandler.h"

#import "BTPayPalPaymentMethod.h"
#import "BTPayPalAppSwitchHandler.h"
#import "BTVenmoAppSwitchHandler.h"

@implementation BTAppSwitchHandler

+ (instancetype)sharedHandler {
    static BTAppSwitchHandler *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[BTAppSwitchHandler alloc] init];
    });
    return instance;
}

- (void)setAppSwitchCallbackURLScheme:(NSString *)appSwitchCallbackURLScheme {
    [BTPayPalAppSwitchHandler sharedHandler].appSwitchCallbackURLScheme = appSwitchCallbackURLScheme;
}

- (NSString *)appSwitchCallbackURLScheme {
    return [BTPayPalAppSwitchHandler sharedHandler].appSwitchCallbackURLScheme;
}

- (BOOL)handleAppSwitchURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication {
    if ([[BTVenmoAppSwitchHandler sharedHandler] canHandleReturnURL:url sourceApplication:sourceApplication]) {
        [[BTVenmoAppSwitchHandler sharedHandler] handleReturnURL:url];
        return YES;
    }
    if ([[BTPayPalAppSwitchHandler sharedHandler] canHandleReturnURL:url sourceApplication:sourceApplication]) {
        [[BTPayPalAppSwitchHandler sharedHandler] handleReturnURL:url];
        return YES;
    }
    return NO;
}

@end
