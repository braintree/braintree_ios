#import "BTApplePayPaymentMethod.h"
#import "BTMutableApplePayPaymentMethod.h"

@interface BTApplePayPaymentMethod ()
@property (nonatomic, copy, readwrite) NSString *nonce;
@end

@implementation BTApplePayPaymentMethod

@synthesize nonce = _nonce;

- (id)copyWithZone:(NSZone *)zone {
    BTApplePayPaymentMethod *copy = [[BTApplePayPaymentMethod allocWithZone:zone] init];
    copy->_nonce = [self.nonce copy];
    return copy;
}

- (id)mutableCopyWithZone:(NSZone *)zone {
    BTMutableApplePayPaymentMethod *mutableInstance = [[BTMutableApplePayPaymentMethod allocWithZone:zone] init];
    [mutableInstance setNonce:self.nonce];
    return mutableInstance;
}

@end
