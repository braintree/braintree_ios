#import <BraintreePaymentFlow/BTThreeDSecureResult_Internal.h>
#import <BraintreePaymentFlow/BTThreeDSecureLookup_Internal.h>
#import <BraintreeCore/BTJSON.h>
#import <BraintreeCard/BTCardNonce_Internal.h>

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
                _errorMessage = firstError[@"message"];
            }
        } else {
            _errorMessage = [json[@"error"][@"message"] asString];
        }
    }
    return self;
}

@end
