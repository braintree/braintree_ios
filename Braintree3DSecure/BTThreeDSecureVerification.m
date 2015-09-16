#import "BTThreeDSecureVerification.h"
#import "BTJSON.h"

// TODO RSS 7/31: Pretty sure we can delete this safely...

@interface BTThreeDSecureVerification ()

@property (nonatomic, strong) NSMutableDictionary *parameters;

@end

@implementation BTThreeDSecureVerification

- (instancetype)init {
    return nil;
}

- (instancetype)initWithCardTokenizationRequest:(__unused BTCard *)cardTokenizationRequest {
    self = [super init];
    if (self) {
        self.parameters = [NSMutableDictionary dictionary];
        // TODO: self.parameters = card.parameters;
    }
    return self;
}

- (instancetype)initWithPaymentMethodNonce:(NSString *)paymentMethodNonce {
    self = [super init];
    if (self) {
        self.parameters = [NSMutableDictionary dictionary];
        self.parameters[@"payment_method_nonce"] = paymentMethodNonce;
    }
    return self;
}

- (instancetype)initWithTokenizedCard:(BTTokenizedCard *)tokenizedCard {
    return [self initWithPaymentMethodNonce:tokenizedCard.paymentMethodNonce];
}

@end
