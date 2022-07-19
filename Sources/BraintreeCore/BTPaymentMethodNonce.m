#if __has_include(<Braintree/BraintreeCore.h>)
#import <Braintree/BTPaymentMethodNonce.h>
#else
#import <BraintreeCore/BTPaymentMethodNonce.h>
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

@interface BTPaymentMethodNonce ()

@property (nonatomic, copy, readwrite) NSString *nonce;
@property (nonatomic, copy, readwrite) NSString *type;
@property (nonatomic, readwrite, assign) BOOL isDefault;

@end

@implementation BTPaymentMethodNonce

- (instancetype)initWithNonce:(NSString *)nonce type:(NSString *)type {
    if (!nonce) return nil;
    
    if (self = [super init]) {
        self.nonce = nonce;
        self.type = type;
    }
    return self;
}

- (nullable instancetype)initWithNonce:(NSString *)nonce {
    return [self initWithNonce:nonce type:@"Unknown"];
}

- (nullable instancetype)initWithNonce:(NSString *)nonce
                                  type:(nonnull NSString *)type
                             isDefault:(BOOL)isDefault {
    if (self = [self initWithNonce:nonce type:type]) {
        _isDefault = isDefault;
    }
    return self;
}

@end
