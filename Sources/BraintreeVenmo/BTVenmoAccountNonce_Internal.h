#if __has_include(<Braintree/BraintreeVenmo.h>)
#import <Braintree/BTVenmoAccountNonce.h>
#else
#import <BraintreeVenmo/BTVenmoAccountNonce.h>
#endif

@interface BTVenmoAccountNonce ()

- (instancetype)initWithPaymentMethodNonce:(NSString *)nonce
                               description:(NSString *)description
                                  username:(NSString *)username
                                 isDefault:(BOOL)isDefault;

- (instancetype)initWithPaymentContextJSON:(BTJSON *)paymentContextJSON;

+ (instancetype)venmoAccountWithJSON:(BTJSON *)venmoAccountJSON;

@end
