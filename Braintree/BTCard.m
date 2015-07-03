#import "BTCard_Internal.h"
#import "BTJSON.h"

@interface BTCard ()
@property (nonatomic, strong) NSMutableDictionary *mutableParameters;
@end

@implementation BTCard

- (instancetype)init {
    return [self initWithParameters:@{}];
}

- (nonnull instancetype)initWithParameters:(NSDictionary *)parameters {
    self = [super init];
    if (self) {
        self.mutableParameters = [parameters mutableCopy];
    }
    return self;
}

- (instancetype)initWithNumber:(NSString *)number expirationDate:(NSString *)expirationDate cvv:(NSString *)cvv {
    self = [self initWithParameters:@{}];
    if (self) {
        self.number = number;
        self.expirationDate = expirationDate;
        self.cvv = cvv;
    }
    return self;
}

#pragma mark -

- (NSDictionary *)parameters {
    NSMutableDictionary *p = [self.mutableParameters mutableCopy];
    if (self.number) {
        p[@"number"] = self.number;
    }
    if (self.expirationDate) {
        p[@"expiration_date"] = self.expirationDate;
    }
    if (self.cvv) {
        p[@"cvv"] = self.cvv;
    }
    if (self.postalCode) {
        if (![p[@"billing_address"] isKindOfClass:[NSDictionary class]]) {
            p[@"billing_address"] = @{ @"postal_code": self.postalCode };
        } else if ([p[@"billing_address"] isKindOfClass:[NSDictionary class]]) {
            NSMutableDictionary *billingAddress = [p[@"billing_address"] mutableCopy];
            billingAddress[@"postal_code"] = self.postalCode;
            p[@"billing_address"] = [billingAddress copy];
        }
    }

    return [p copy];
}

@end
