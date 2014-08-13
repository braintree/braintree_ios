#import "BTVenmoAppSwitchReturnURL.h"

@implementation BTVenmoAppSwitchReturnURL
//        [sourceApplication isEqualToString:@"net.kortina.labs.Venmo"]) {


+ (BOOL)isValidURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication {
    NSLog(@"%@ %@", url, sourceApplication);
    return NO;
}

- (instancetype)initWithURL:(NSURL *)url {
    NSLog(@"%@", url);
    return nil;
}

- (id)paymentMethod {
    return nil;
}

- (BTVenmoAppSwitchReturnURLState)state {
    return BTVenmoAppSwitchReturnURLStateFailed;
}

@end
