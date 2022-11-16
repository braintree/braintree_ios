#import "BTThreeDSecureLookup_Internal.h"

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

@implementation BTThreeDSecureLookup

- (instancetype)initWithJSON:(BTJSON *)json {
    self = [super init];
    if (self) {
        _PAReq = [json[@"pareq"] asString];
        _MD = [json[@"md"] asString];
        _acsURL = [json[@"acsUrl"] asURL];
        _termURL = [json[@"termUrl"] asURL];
        _threeDSecureVersion = [json[@"threeDSecureVersion"] asString];
        _transactionID = [json[@"transactionId"] asString];
    }
    return self;
}

- (BOOL)requiresUserAuthentication {
    return self.acsURL != nil;
}

- (BOOL)isThreeDSecureVersion2 {
    return [self.threeDSecureVersion hasPrefix:@"2."];
}

@end
