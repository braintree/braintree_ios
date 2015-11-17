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
        _number = parameters[@"number"];
        NSArray *components = [parameters[@"expiration_date"] componentsSeparatedByString:@"/"];
        if (components.count == 2) {
            _expirationMonth = components[0];
            _expirationYear = components[1];
        }
        _postalCode = parameters[@"billing_address"][@"postal_code"];
        _cvv = parameters[@"cvv"];
        _shouldValidate = [parameters[@"options"][@"validate"] boolValue];
    }
    return self;
}

- (instancetype)initWithNumber:(NSString *)number
               expirationMonth:(NSString *)expirationMonth
                expirationYear:(NSString *)expirationYear
                           cvv:(NSString *)cvv
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
        NSMutableDictionary *billingAddressDictionary = [NSMutableDictionary new];
        if ([p[@"billing_address"] isKindOfClass:[NSDictionary class]]) {
            [billingAddressDictionary addEntriesFromDictionary:p[@"billing_address"]];
        }
        billingAddressDictionary[@"postal_code"] = self.postalCode;
        p[@"billing_address"] = [billingAddressDictionary copy];
    }
    NSMutableDictionary *optionsDictionary = [NSMutableDictionary new];
    if ([p[@"options"] isKindOfClass:[NSDictionary class]]) {
        [optionsDictionary addEntriesFromDictionary:p[@"options"]];
    }
    optionsDictionary[@"validate"] = @(self.shouldValidate);
    p[@"options"] = [optionsDictionary copy];
    return [p copy];
}

@end
