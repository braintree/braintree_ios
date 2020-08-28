#import <BraintreeVenmo/BTVenmoAccountNonce.h>

@interface BTVenmoAccountNonce ()

- (instancetype)initWithPaymentMethodNonce:(NSString *)nonce
                               description:(NSString *)description
                                  username:(NSString *)username
                                 isDefault:(BOOL)isDefault;

+ (instancetype)venmoAccountWithJSON:(BTJSON *)venmoAccountJSON;

@end
