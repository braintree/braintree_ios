#import "BTVenmoAppSwitchReturnURL.h"

// Swift Module Imports
#if __has_include(<Braintree/Braintree-Swift.h>) // CocoaPods
#import <Braintree/Braintree-Swift.h>

#elif SWIFT_PACKAGE                              // SPM
/* Use @import for SPM support
 * See https://forums.swift.org/t/using-a-swift-package-in-a-mixed-swift-and-objective-c-project/27348
 */
@import BraintreeCore;

#elif __has_include("Braintree-Swift.h")         // CocoaPods for ReactNative
/* Use quoted style when importing Swift headers for ReactNative support
 * See https://github.com/braintree/braintree_ios/issues/671
 */
#import "Braintree-Swift.h"

#else                                            // Carthage
#import <BraintreeCore/BraintreeCore-Swift.h>
#endif

NSString *const BTVenmoAppSwitchReturnURLErrorDomain = @"com.braintreepayments.BTVenmoAppSwitchReturnURLErrorDomain";

@implementation BTVenmoAppSwitchReturnURL

+ (BOOL)isValidURL:(NSURL *)url {
    return [url.host isEqualToString:@"x-callback-url"] && [url.path hasPrefix:@"/vzero/auth/venmo/"];
}

- (instancetype)initWithURL:(NSURL *)url {
    self = [self init];
    if (self) {
        NSDictionary *parameters = [BTURLUtils queryParametersForURL:url];
        if ([url.path isEqualToString:@"/vzero/auth/venmo/success"]) {
            if (parameters[@"resource_id"]) {
                _state = BTVenmoAppSwitchReturnURLStateSucceededWithPaymentContext;
                _paymentContextID = parameters[@"resource_id"];
            } else {
                _state = BTVenmoAppSwitchReturnURLStateSucceeded;
                _nonce = parameters[@"paymentMethodNonce"];
                _username = parameters[@"username"];
            }
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

@end
