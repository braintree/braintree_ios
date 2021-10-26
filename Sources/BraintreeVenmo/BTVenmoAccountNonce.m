#if __has_include(<Braintree/BraintreeVenmo.h>)
#import <Braintree/BTVenmoAccountNonce.h>
#import <Braintree/BraintreeCore.h>
#else
#import <BraintreeVenmo/BTVenmoAccountNonce.h>
#import <BraintreeCore/BraintreeCore.h>
#endif

@interface BTVenmoAccountNonce ()
@property (nonatomic, readwrite, copy) NSString *email;
@property (nonatomic, readwrite, copy) NSString *externalId;
@property (nonatomic, readwrite, copy) NSString *firstName;
@property (nonatomic, readwrite, copy) NSString *lastName;
@property (nonatomic, readwrite, copy) NSString *phoneNumber;
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
    BTVenmoAccountNonce *accountNonce = [[self.class alloc] initWithPaymentMethodNonce:[paymentContextJSON[@"data"][@"node"][@"paymentMethodId"] asString] 
                                                                              username:[paymentContextJSON[@"data"][@"node"][@"userName"] asString] isDefault:NO];

    if (paymentContextJSON[@"data"][@"node"][@"payerInfo"]) {
        accountNonce.email = [paymentContextJSON[@"data"][@"node"][@"payerInfo"][@"email"] asString];
        accountNonce.externalId = [paymentContextJSON[@"data"][@"node"][@"payerInfo"][@"externalId"] asString];
        accountNonce.firstName = [paymentContextJSON[@"data"][@"node"][@"payerInfo"][@"firstName"] asString];
        accountNonce.lastName = [paymentContextJSON[@"data"][@"node"][@"payerInfo"][@"lastName"] asString];
        accountNonce.phoneNumber = [paymentContextJSON[@"data"][@"node"][@"payerInfo"][@"phoneNumber"] asString];
    }

    return accountNonce;
}

+ (instancetype)venmoAccountWithJSON:(BTJSON *)venmoAccountJSON {
    return [[[self class] alloc] initWithPaymentMethodNonce:[venmoAccountJSON[@"nonce"] asString]
                                                   username:[venmoAccountJSON[@"details"][@"username"] asString]
                                                  isDefault:[venmoAccountJSON[@"default"] isTrue]];
}

@end
