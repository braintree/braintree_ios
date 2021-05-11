#import "BTThreeDSecureResult_Internal.h"
#import "BTThreeDSecureLookup_Internal.h"

#if __has_include(<Braintree/BraintreeThreeDSecure.h>) // CocoaPods
#import <Braintree/BraintreeCore.h>
#import <Braintree/BTCardNonce_Internal.h>

#elif SWIFT_PACKAGE // SPM
#import <BraintreeCore/BraintreeCore.h>
#import "../BraintreeCard/BTCardNonce_Internal.h"

#else // Carthage
#import <BraintreeCore/BraintreeCore.h>
#import <BraintreeCard/BTCardNonce_Internal.h>

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
