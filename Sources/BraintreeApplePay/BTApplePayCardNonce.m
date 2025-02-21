#if __has_include(<Braintree/BraintreeApplePay.h>)
#import <Braintree/BTApplePayCardNonce.h>
#else
#import <BraintreeApplePay/BTApplePayCardNonce.h>
#endif

@implementation BTApplePayCardNonce

- (instancetype)initWithJSON:(BTJSON *)json {
    NSString *cardType = [json[@"details"][@"cardType"] asString] ?: @"ApplePayCard";
    self = [super initWithNonce:[json[@"nonce"] asString] type:cardType isDefault:[json[@"default"] isTrue]];
    
    if (self) {
        _isDeviceToken = [json[@"details"][@"isDeviceToken"] isTrue];
        _binData = [[BTBinData alloc] initWithJSON:json[@"binData"]];
    }
    return self;
}

@end
