#if __has_include(<Braintree/BraintreePaymentFlow.h>)
#import <Braintree/BTConfiguration+LocalPayment.h>
#else
#import <BraintreePaymentFlow/BTConfiguration+LocalPayment.h>
#endif

// Swift Module Imports
#if __has_include(<Braintree/Braintree-Swift.h>) // Cocoapods-generated Swift Header
#import <Braintree/Braintree-Swift.h>

#elif SWIFT_PACKAGE                              // SPM
/* Use @import for SPM support
 * See https://forums.swift.org/t/using-a-swift-package-in-a-mixed-swift-and-objective-c-project/27348
 */
@import BraintreeCoreSwift;

#elif __has_include("Braintree-Swift.h")         // CocoaPods for ReactNative
/* Use quoted style when importing Swift headers for ReactNative support
 * See https://github.com/braintree/braintree_ios/issues/671
 */
#import "Braintree-Swift.h"

#else // Carthage or Local Builds
#import <BraintreeCoreSwift/BraintreeCoreSwift-Swift.h>
#endif

@implementation BTConfiguration (LocalPayment)

- (BOOL)isLocalPaymentEnabled {
    // Local Payments are enabled when PayPal is enabled
    return [self.json[@"paypalEnabled"] isTrue];
}

@end
