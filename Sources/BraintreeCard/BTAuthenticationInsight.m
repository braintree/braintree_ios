#import "BTAuthenticationInsight_Internal.h"

#if __has_include(<Braintree/BraintreeCard.h>)
#import <Braintree/BraintreeCore.h>
#else
#import <BraintreeCore/BraintreeCore.h>
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

@implementation BTAuthenticationInsight

- (instancetype)initWithJSON:(BTJSON *)json {
    if (self = [super init]) {
        NSString *regulationEnvironment;
        
        if ([json[@"customerAuthenticationRegulationEnvironment"] asString]) {
            regulationEnvironment = [json[@"customerAuthenticationRegulationEnvironment"] asString];
        } else if ([json[@"regulationEnvironment"] asString]) {
            regulationEnvironment = [json[@"regulationEnvironment"] asString];
        }
        
        // GraphQL returns "PSDTWO" instead of "psd2"
        if ([regulationEnvironment isEqualToString:@"PSDTWO"]) {
            regulationEnvironment = @"psd2";
        }
        
        if (regulationEnvironment) {
            regulationEnvironment = regulationEnvironment.lowercaseString;
        }
        
        _regulationEnvironment = regulationEnvironment;
    }
    return self;
}

@end
