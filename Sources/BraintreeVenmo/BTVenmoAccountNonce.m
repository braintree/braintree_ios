#if __has_include(<Braintree/BraintreeVenmo.h>)
#import <Braintree/BTVenmoAccountNonce.h>
#import <Braintree/BraintreeCore.h>
#else
#import <BraintreeVenmo/BTVenmoAccountNonce.h>
#import <BraintreeCore/BraintreeCore.h>
#endif

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

- (instancetype)initWithPaymentContextJSON:(BTJSON *)paymentContextJSON {
    return [[self.class alloc] initWithPaymentMethodNonce:[paymentContextJSON[@"data"][@"node"][@"paymentMethodId"] asString]
                                                 username:[paymentContextJSON[@"data"][@"node"][@"userName"] asString]
                                                isDefault:NO];
}

+ (instancetype)venmoAccountWithJSON:(BTJSON *)venmoAccountJSON {
    return [[[self class] alloc] initWithPaymentMethodNonce:[venmoAccountJSON[@"nonce"] asString]
                                                   username:[venmoAccountJSON[@"details"][@"username"] asString]
                                                  isDefault:[venmoAccountJSON[@"default"] isTrue]];
}

@end
