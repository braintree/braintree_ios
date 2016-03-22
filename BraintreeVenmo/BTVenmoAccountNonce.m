#import "BTVenmoAccountNonce.h"

@interface BTVenmoAccountNonce ()
@property (nonatomic, readwrite, copy) NSString *username;
@end

@implementation BTVenmoAccountNonce

- (instancetype)initWithPaymentMethodNonce:(NSString *)nonce
                               description:(NSString *)description
                                  username:(NSString *)username
                                 isDefault:(BOOL)isDefault
{
    if (self = [super initWithNonce:nonce localizedDescription:description type:@"Venmo" isDefault:isDefault]) {
        _username = username;
    }
    return self;
}

+ (instancetype)venmoAccountWithJSON:(BTJSON *)venmoAccountJSON {
    return [[[self class] alloc] initWithPaymentMethodNonce:[venmoAccountJSON[@"nonce"] asString]
                                                description:[venmoAccountJSON[@"description"] asString]
                                                   username:[venmoAccountJSON[@"username"] asString]
                                                  isDefault:[venmoAccountJSON[@"default"] isTrue]];
}

@end
