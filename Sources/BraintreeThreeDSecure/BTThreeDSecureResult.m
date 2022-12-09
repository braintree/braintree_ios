#import "BTThreeDSecureResult_Internal.h"
#import "BTThreeDSecureLookup_Internal.h"

// MARK: - Objective-C File Imports for Package Managers
#if __has_include(<Braintree/BraintreeThreeDSecure.h>) // CocoaPods
#import <Braintree/BTCardNonce_Internal.h>

#elif SWIFT_PACKAGE // SPM
#import "../BraintreeCard/BTCardNonce_Internal.h"

#else // Carthage
#import <BraintreeCard/BTCardNonce_Internal.h>

#endif

// MARK: - Swift File Imports for Package Managers
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

@implementation BTThreeDSecureResult

- (instancetype)initWithJSON:(BTJSON *)json {
    self = [super init];
    if (self) {
        if ([json[@"paymentMethod"] asDictionary]) {
            _tokenizedCard = [BTCardNonce cardNonceWithJSON:json[@"paymentMethod"]];
        }

        if ([json[@"lookup"] asDictionary]) {
            _lookup = [[BTThreeDSecureLookup alloc] initWithJSON:json[@"lookup"]];
        }

        if ([json[@"errors"] asArray]) {
            NSDictionary *firstError = (NSDictionary *)[json[@"errors"] asArray].firstObject;
            if (firstError[@"message"]) {
                _errorMessage = [firstError[@"message"] asString];
            }
        } else {
            _errorMessage = [json[@"error"][@"message"] asString];
        }
    }
    return self;
}

@end
