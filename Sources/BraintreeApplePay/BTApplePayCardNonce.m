#import <BraintreeApplePay/BTApplePayCardNonce.h>

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
