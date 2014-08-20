#import "BTVenmoAppSwitchReturnURL.h"
#import "BTPaymentMethod_Mutable.h"

@implementation BTVenmoAppSwitchReturnURL

+ (BOOL)isValidURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication {
    NSLog(@"%@ %@", url, sourceApplication);
    return [self sourceApplicationIsValid:sourceApplication] && [self returnURLIsValid:url];
}

- (instancetype)initWithURL:(NSURL *)url {
    self = [self init];
    if (self) {
        _state = [[self class] stateForURL:url];
        if (_state == BTVenmoAppSwitchReturnURLStateSucceeded) {
            _paymentMethod = [[self class] paymentMethodForURL:url];
        }
    }
    return self;
}

#pragma mark Internal Helpers

+ (BOOL)sourceApplicationIsValid:(NSString *)sourceApplication {
    return [sourceApplication isEqualToString:@"net.kortina.labs.Venmo"] ||  // Venmo app
           [sourceApplication isEqualToString:@"com.paypal.PPClient.Debug"]; // fake wallet
}

+ (BOOL)returnURLIsValid:(NSURL *)url {
    return [url.host isEqualToString:@"x-callback-url"] && [url.path hasPrefix:@"/vzero/auth/venmo/"];
}

+ (BTVenmoAppSwitchReturnURLState)stateForURL:(NSURL *)url {
    if ([url.path isEqualToString:@"/vzero/auth/venmo/success"]) {
        return BTVenmoAppSwitchReturnURLStateSucceeded;
    } else if ([url.path isEqualToString:@"/vzero/auth/venmo/fail"]) {
        return BTVenmoAppSwitchReturnURLStateFailed;
    } else if ([url.path isEqualToString:@"/vzero/auth/venmo/cancel"]) {
        return BTVenmoAppSwitchReturnURLStateCanceled;
    }
    return BTVenmoAppSwitchReturnURLStateUnknown;
}

+ (BTPaymentMethod *)paymentMethodForURL:(NSURL *)url {
    NSDictionary *parameters = [self parametersForQueryString:url];

    BTPaymentMethod *paymentMethod = [[BTPaymentMethod alloc] init];
    paymentMethod.nonce = parameters[@"venmo-nonce"];
    return paymentMethod;
}

+ (NSDictionary *)parametersForQueryString:(NSURL *)url {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    for (NSString *keyValueString in [url.query componentsSeparatedByString:@"&"]) {
        NSArray *keyValueArray = [keyValueString componentsSeparatedByString:@"="];
        NSString *key = keyValueArray[0];
        if (keyValueArray.count == 2) {
            NSString *value = keyValueArray[1];
            parameters[key] = value;
        } else {
            parameters[key] = [NSNull null];
        }
    }
    return [NSDictionary dictionaryWithDictionary:parameters];
}

@end
