#import "BTVenmoAppSwitchReturnURL.h"

#if __has_include("BraintreeCore.h")
#import "BTURLUtils.h"
#else
#import <BraintreeCore/BTURLUtils.h>
#endif

NSString *const BTVenmoAppSwitchReturnURLErrorDomain = @"com.braintreepayments.BTVenmoAppSwitchReturnURLErrorDomain";

@implementation BTVenmoAppSwitchReturnURL

+ (BOOL)isValidURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication {
    return [self isVenmoSourceApplication:sourceApplication] || // Pre iOS 13
           [self isValidVenmoURL:url andUnknownApplication:sourceApplication] || // iOS 13+
           [self isFakeWalletURL:url andSourceApplication:sourceApplication];
}

- (instancetype)initWithURL:(NSURL *)url {
    self = [self init];
    if (self) {
        NSDictionary *parameters = [BTURLUtils queryParametersForURL:url];
        if ([url.path isEqualToString:@"/vzero/auth/venmo/success"]) {
            _state = BTVenmoAppSwitchReturnURLStateSucceeded;
            _nonce = parameters[@"paymentMethodNonce"];
            _username = parameters[@"username"];
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
    return [sourceApplication hasPrefix:@"net.kortina.labs.Venmo"];
}

+ (BOOL)isFakeWalletURL:(NSURL *)url andSourceApplication:(NSString *)sourceApplication {
    return [sourceApplication isEqualToString:@"com.paypal.PPClient.Debug"] && [url.host isEqualToString:@"x-callback-url"] && [url.path hasPrefix:@"/vzero/auth/venmo/"];
}

+ (BOOL)isValidVenmoURL:(NSURL *)url andUnknownApplication:(NSString *)sourceApplication {
    return sourceApplication == nil && [url.host isEqualToString:@"x-callback-url"] && [url.path hasPrefix:@"/vzero/auth/venmo/"];
}

@end
