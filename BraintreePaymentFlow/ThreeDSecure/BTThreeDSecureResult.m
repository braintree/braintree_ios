#import "BTThreeDSecureResult.h"
#if __has_include("BraintreeCard.h")
#import "BTCardNonce_Internal.h"
#else
#import <BraintreeCard/BTCardNonce_Internal.h>
#endif

@implementation BTThreeDSecureResult

- (instancetype)initWithJSON:(BTJSON *)json {
    self = [super init];
    if (self) {
        if (json[@"paymentMethod"]) {
            _tokenizedCard = [BTCardNonce cardNonceWithJSON:json[@"paymentMethod"]];
        }
        if ([json[@"errors"] asArray]) {
            NSDictionary *firstError = (NSDictionary *)[json[@"errors"] asArray].firstObject;
            if (firstError[@"message"]) {
                _errorMessage = firstError[@"message"];
            }
        } else {
            _errorMessage = [json[@"error"][@"message"] asString];
        }
        _liabilityShifted = [json[@"threeDSecureInfo"][@"liabilityShifted"] isTrue];
        _liabilityShiftPossible = [json[@"threeDSecureInfo"][@"liabilityShiftPossible"] isTrue];

        // Account for absence of "success" key in 2.0 gateway responses
        if ([json[@"success"] isBool]) {
            _success = [json[@"success"] isTrue];
        } else {
            _success = _errorMessage == nil;
        }
    }
    return self;
}

- (NSString *)debugDescription {
    return [NSString stringWithFormat:@"<BTThreeDSecureResult: %p errorMessage:%@>", self, self.tokenizedCard.threeDSecureInfo.errorMessage];
}

@end
