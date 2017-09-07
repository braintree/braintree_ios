#import "BTApplePayCardNonce.h"

@implementation BTApplePayCardNonce

- (instancetype)initWithNonce:(NSString *)nonce
         localizedDescription:(NSString *)description
                         type:(NSString *)type
                    isDefault:(BOOL)isDefault
                         json:(BTJSON *)json {
    self = [super initWithNonce:nonce localizedDescription:description type:type isDefault:isDefault];
    if (self) {
        _binData = [[BTBinData alloc] initWithJSON:json[@"binData"]];
    }
    return self;
}

@end
