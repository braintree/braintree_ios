#import "Foundation/Foundation.h"

#if __has_include(<Braintree/BraintreeApplePay.h>)
#import <Braintree/BTApplePayCardNonce.h>
#else
#import <BraintreeApplePay/BTApplePayCardNonce.h>
#endif

@implementation BTApplePayCardNonce

- (instancetype)initWithJSON:(BTJSON *)json {
    NSString *cardType = [json[@"details"][@"cardType"] asString] ?: @"ApplePayCard";
    self = [super init];
    if (self) {
        _nonce = [json[@"nonce"] asString];
        _type = cardType;
        _isDefault = [json[@"default"] isTrue];
        _binData = [[BTBinData alloc] initWithJSON:json[@"binData"]];
    }
    return self;
}

@end
