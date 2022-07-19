#if __has_include(<Braintree/BraintreeApplePay.h>)
#import <Braintree/BTApplePayCardNonce.h>
#else
#import <BraintreeApplePay/BTApplePayCardNonce.h>
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

@implementation BTApplePayCardNonce

- (instancetype)initWithJSON:(BTJSON *)json {
    NSString *cardType = [json[@"details"][@"cardType"] asString] ?: @"ApplePayCard";
    self = [super initWithNonce:[json[@"nonce"] asString] type:cardType isDefault:[json[@"default"] isTrue]];
    
    if (self) {
        _binData = [[BTBinData alloc] initWithJSON:json[@"binData"]];
    }
    return self;
}

@end
