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
        _tokenizedCard = [BTCardNonce cardNonceWithJSON:json[@"paymentMethod"]];
        _errorMessage = [json[@"error"][@"message"] asString];
        _liabilityShifted = [json[@"threeDSecureInfo"][@"liabilityShifted"] isTrue];
        _liabilityShiftPossible = [json[@"threeDSecureInfo"][@"liabilityShiftPossible"] isTrue];
        _success = [json[@"success"] isTrue];
    }
    return self;
}

- (NSString *)debugDescription {
    return [NSString stringWithFormat:@"<BTThreeDSecureResult: %p errorMessage:%@>", self, self.errorMessage];
}

@end
