#import "BTVenmoAccountNonce.h"

@interface BTVenmoAccountNonce ()
@property (nonatomic, readwrite, copy) NSString *username;
@end

@implementation BTVenmoAccountNonce

@synthesize nonce = _paymentMethodNonce;
@synthesize localizedDescription = _localizedDescription;
@synthesize type = _type;

- (instancetype)initWithPaymentMethodNonce:(NSString *)nonce
                               description:(NSString *)description
                                  username:(NSString *)username
{
    if (self = [super init]) {
        _paymentMethodNonce = nonce;
        _localizedDescription = description;
        _username = username;
        _type = @"Venmo";
    }
    return self;
}

+ (instancetype)venmoAccountWithJSON:(BTJSON *)venmoAccountJSON {
    return [[[self class] alloc] initWithPaymentMethodNonce:venmoAccountJSON[@"nonce"].asString
                                                description:venmoAccountJSON[@"description"].asString
                                                   username:venmoAccountJSON[@"username"].asString];
}

@end
