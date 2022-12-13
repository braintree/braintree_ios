#if __has_include(<Braintree/BraintreeCard.h>)
#import <Braintree/BTThreeDSecureInfo.h>
#else
#import <BraintreeCard/BTThreeDSecureInfo.h>
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

@interface BTThreeDSecureInfo ()

@property (nonatomic, strong) BTJSON *threeDSecureJSON;

@end

@implementation BTThreeDSecureInfo

- (instancetype)initWithJSON:(BTJSON *)json {
    if (self = [super init]) {
        if (json != nil) {
            _threeDSecureJSON = json;
        } else {
            _threeDSecureJSON = [BTJSON new];
        }
    }
    return self;
}

- (NSString *)acsTransactionID {
    return [self.threeDSecureJSON[@"acsTransactionId"] asString];
}

- (NSString *)authenticationTransactionStatus {
    return [self.threeDSecureJSON[@"authentication"][@"transStatus"] asString];
}

- (NSString *)authenticationTransactionStatusReason {
    return [self.threeDSecureJSON[@"authentication"][@"transStatusReason"] asString];
}

- (NSString *)cavv {
    return [self.threeDSecureJSON[@"cavv"] asString];
}

- (NSString *)dsTransactionID {
    return [self.threeDSecureJSON[@"dsTransactionId"] asString];
}

- (NSString *)eciFlag {
    return [self.threeDSecureJSON[@"eciFlag"] asString];
}

- (NSString *)enrolled {
    return [self.threeDSecureJSON[@"enrolled"] asString];
}

- (BOOL)liabilityShifted {
    return [self.threeDSecureJSON[@"liabilityShifted"] isTrue];
}

- (BOOL)liabilityShiftPossible {
    return [self.threeDSecureJSON[@"liabilityShiftPossible"] isTrue];
}

- (NSString *)lookupTransactionStatus {
    return [self.threeDSecureJSON[@"lookup"][@"transStatus"] asString];
}

- (NSString *)lookupTransactionStatusReason {
    return [self.threeDSecureJSON[@"lookup"][@"transStatusReason"] asString];
}

- (NSString *)paresStatus {
    return [self.threeDSecureJSON[@"paresStatus"] asString];
}

- (NSString *)status {
    return [self.threeDSecureJSON[@"status"] asString];
}

- (NSString *)threeDSecureAuthenticationID {
    return [self.threeDSecureJSON[@"threeDSecureAuthenticationId"] asString];
}

- (NSString *)threeDSecureServerTransactionID {
    return [self.threeDSecureJSON[@"threeDSecureServerTransactionId"] asString];
}

- (NSString *)threeDSecureVersion {
    return [self.threeDSecureJSON[@"threeDSecureVersion"] asString];
}

- (BOOL)wasVerified {
    return ![self.threeDSecureJSON[@"liabilityShifted"] isError] &&
        ![self.threeDSecureJSON[@"liabilityShiftPossible"] isError];
}

- (NSString *)xid {
    return [self.threeDSecureJSON[@"xid"] asString];
}

@end
