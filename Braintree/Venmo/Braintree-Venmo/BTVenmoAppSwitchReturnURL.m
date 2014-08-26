#import "BTVenmoAppSwitchReturnURL.h"
#import "BTPaymentMethod_Mutable.h"
#import "BTURLUtils.h"

NSString *const BTVenmoAppSwitchReturnURLErrorDomain = @"BTVenmoAppSwitchReturnURLErrorDomain";

@implementation BTVenmoAppSwitchReturnURL

+ (BOOL)isValidSourceApplication:(NSString *)sourceApplication {
    return [self sourceApplicationIsValid:sourceApplication];
}

- (instancetype)initWithURL:(NSURL *)url {
    self = [self init];
    if (self) {
        NSDictionary *parameters = [BTURLUtils dictionaryForQueryString:url.query];
        if ([url.path isEqualToString:@"/vzero/auth/venmo/success"]) {
            _state = BTVenmoAppSwitchReturnURLStateSucceeded;
            _paymentMethod = [[BTPaymentMethod alloc] init];
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

+ (BOOL)sourceApplicationIsValid:(NSString *)sourceApplication {
    return [sourceApplication isEqualToString:@"net.kortina.labs.Venmo"] ||  // Venmo app
           [sourceApplication isEqualToString:@"com.paypal.PPClient.Debug"]; // fake wallet
}

@end
