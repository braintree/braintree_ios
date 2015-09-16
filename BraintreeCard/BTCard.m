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
    if (self = [super init]) {
        _mutableParameters = [parameters mutableCopy];
    }
    return self;
}

- (instancetype)initWithNumber:(BT_NULLABLE NSString *)number
               expirationMonth:(BT_NULLABLE NSString *)expirationMonth
                expirationYear:(BT_NULLABLE NSString *)expirationYear
                           cvv:(BT_NULLABLE NSString *)cvv
{
    if (self = [self initWithParameters:@{}]) {
        _number = number;
        _expirationMonth = expirationMonth;
        _expirationYear = expirationYear;
        _cvv = cvv;
    }
    return self;
}

#pragma mark -

- (NSDictionary *)parameters {
    NSMutableDictionary *p = [self.mutableParameters mutableCopy];
    if (self.number) {
        p[@"number"] = self.number;
    }
    if (self.expirationMonth && self.expirationYear) {
        p[@"expiration_date"] = [NSString stringWithFormat:@"%@/%@", self.expirationMonth, self.expirationYear];
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
    p[@"options"] = @{ @"validate": @(self.shouldValidate) };

    return [p copy];
}

@end
