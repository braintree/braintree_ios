#import <BraintreeVenmo/BTVenmoAccountNonce.h>
#import <BraintreeCore/BraintreeCore.h>

@interface BTVenmoAccountNonce ()
@property (nonatomic, readwrite, copy) NSString *username;
@end

@implementation BTVenmoAccountNonce

- (instancetype)initWithPaymentMethodNonce:(NSString *)nonce
                                  username:(NSString *)username
                                 isDefault:(BOOL)isDefault
{
    if (self = [super initWithNonce:nonce type:@"Venmo" isDefault:isDefault]) {
        _username = username;
    }
    return self;
}

+ (instancetype)venmoAccountWithJSON:(BTJSON *)venmoAccountJSON {
    return [[[self class] alloc] initWithPaymentMethodNonce:[venmoAccountJSON[@"nonce"] asString]
                                                   username:[venmoAccountJSON[@"details"][@"username"] asString]
                                                  isDefault:[venmoAccountJSON[@"default"] isTrue]];
}

@end
