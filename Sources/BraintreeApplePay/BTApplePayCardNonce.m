#if __has_include(<Braintree/BraintreeApplePay.h>)
#import <Braintree/BTApplePayCardNonce.h>
#else
#import <BraintreeApplePay/BTApplePayCardNonce.h>
#endif

@implementation BTApplePayCardNonce

- (instancetype)initWithNonce:(NSString *)nonce
                         type:(NSString *)type
                         json:(BTJSON *)json {
    self = [super initWithNonce:nonce type:type isDefault:[json[@"default"] isTrue]];
    
    if (self) {
        _binData = [[BTBinData alloc] initWithJSON:json[@"binData"]];
    }
    return self;
}

@end
