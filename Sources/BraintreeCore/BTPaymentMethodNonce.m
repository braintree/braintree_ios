#if __has_include(<Braintree/BraintreeCore.h>)
#import <Braintree/BTPaymentMethodNonce.h>
#else
#import <BraintreeCore/BTPaymentMethodNonce.h>
#endif

@interface BTPaymentMethodNonce ()

@property (nonatomic, copy, readwrite) NSString *nonce;
@property (nonatomic, copy, readwrite) NSString *type;
@property (nonatomic, readwrite, assign) BOOL isDefault;

@end

@implementation BTPaymentMethodNonce

- (instancetype)initWithNonce:(NSString *)nonce type:(NSString *)type {
    if (!nonce) return nil;
    
    if (self = [super init]) {
        self.nonce = nonce;
        self.type = type;
    }
    return self;
}

- (nullable instancetype)initWithNonce:(NSString *)nonce {
    return [self initWithNonce:nonce type:@"Unknown"];
}

- (nullable instancetype)initWithNonce:(NSString *)nonce
                                  type:(nonnull NSString *)type
                             isDefault:(BOOL)isDefault {
    if (self = [self initWithNonce:nonce type:type]) {
        _isDefault = isDefault;
    }
    return self;
}

@end
