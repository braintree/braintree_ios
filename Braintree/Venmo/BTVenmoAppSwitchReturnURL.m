#import "BTVenmoAppSwitchReturnURL.h"
#import "BTMutableCardPaymentMethod.h"
#import "BTURLUtils.h"

NSString *const BTVenmoAppSwitchReturnURLErrorDomain = @"BTVenmoAppSwitchReturnURLErrorDomain";

@implementation BTVenmoAppSwitchReturnURL

+ (BOOL)isValidURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication {
    return [self isVenmoSourceApplication:sourceApplication] || [self isFakeWalletURL:url andSourceApplication:sourceApplication];
}

- (instancetype)initWithURL:(NSURL *)url {
    self = [self init];
    if (self) {
        NSDictionary *parameters = [BTURLUtils dictionaryForQueryString:url.query];
        if ([url.path isEqualToString:@"/vzero/auth/venmo/success"]) {
            _state = BTVenmoAppSwitchReturnURLStateSucceeded;
            _paymentMethod = [[BTMutableCardPaymentMethod alloc] init];
            _paymentMethod.nonce = parameters[@"paymentMethodNonce"];
        } else if ([url.path isEqualToString:@"/vzero/auth/venmo/error"]) {
            _state = BTVenmoAppSwitchReturnURLStateFailed;
            NSString *errorMessage = parameters[@"errorMessage"];
            NSInteger errorCode = [parameters[@"errorCode"] integerValue];
            _error = [NSError errorWithDomain:BTVenmoAppSwitchReturnURLErrorDomain code:errorCode userInfo:(errorMessage != nil ? @{ NSLocalizedDescriptionKey: errorMessage } : nil)];
        } else if ([url.path isEqualToString:@"/vzero/auth/venmo/cancel"]) {
            _state = BTVenmoAppSwitchReturnURLStateCanceled;
        } else {
            _state = BTVenmoAppSwitchReturnURLStateUnknown;
        }
    }
    return self;
}

#pragma mark Internal Helpers

+ (BOOL)isVenmoSourceApplication:(NSString *)sourceApplication {
    return [sourceApplication isEqualToString:@"net.kortina.labs.Venmo"];
}

+ (BOOL)isFakeWalletURL:(NSURL *)url andSourceApplication:(NSString *)sourceApplication {
   return [sourceApplication isEqualToString:@"com.paypal.PPClient.Debug"] && [url.host isEqualToString:@"x-callback-url"] && [url.path hasPrefix:@"/vzero/auth/venmo/"];
}

@end
