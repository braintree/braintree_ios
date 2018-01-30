#import "BTThreeDSecureResult.h"

@implementation BTThreeDSecureResult

- (instancetype)initWithJSON:(BTJSON *)json {
    self = [super init];
    if (self) {
        _tokenizedCard = [BTCardNonce cardNonceWithJSON:json[@"paymentMethod"]];
        _errorMessage = [json[@"error"][@"message"] asString];
        _success = [json[@"success"] isTrue];
    }
    return self;
}

- (NSString *)debugDescription {
    return [NSString stringWithFormat:@"<BTThreeDSecureResult: %p errorMessage:%@>", self, self.errorMessage];
}

@end
