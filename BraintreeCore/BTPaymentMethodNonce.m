#import "BTPaymentMethodNonce.h"

@interface BTPaymentMethodNonce ()
@property (nonatomic, copy, readwrite) NSString *nonce;
@property (nonatomic, copy, readwrite) NSString *localizedDescription;
@property (nonatomic, copy, readwrite) NSString *type;
@end

@implementation BTPaymentMethodNonce

- (instancetype)initWithNonce:(NSString *)nonce localizedDescription:(NSString *)description type:(NSString *)type {
    if (!nonce) return nil;
    
    if (self = [super init]) {
        self.nonce = nonce;
        self.localizedDescription = description;
        self.type = type;
    }
    return self;
}

- (nullable instancetype)initWithNonce:(NSString *)nonce localizedDescription:(nullable NSString *)description {
    return [self initWithNonce:nonce localizedDescription:description type:@"Unknown"];
}

@end
