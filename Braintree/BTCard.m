#import "BTCard.h"
#import "BTJSON.h"

@interface BTCard ()
@property (nonatomic, nonnull, strong) BTJSON *parameters;
@end

@implementation BTCard

- (nonnull instancetype)initWithNumber:(nullable NSString *)number expirationDate:(nullable NSString *)expirationDate cvv:(nullable NSString *)cvv {
    self = [self init];
    if (self) {
        self.parameters = [BTJSON empty];
        self.parameters[@"number"] = number;
        self.parameters[@"expirationDate"] = expirationDate;
        self.parameters[@"cvv"] = cvv;
    }
    return self;
}

+ (nonnull instancetype)cardWithNumber:(nullable NSString *)number expirationDate:(nullable NSString *)expirationDate {
    return [self cardWithNumber:number expirationDate:expirationDate cvv:nil];
}

+ (nonnull instancetype)cardWithNumber:(nullable NSString *)number expirationDate:(nullable NSString *)expirationDate cvv:(nullable NSString *)cvv {
    return [[self alloc] initWithNumber:number expirationDate:expirationDate cvv:cvv];
}

+ (nonnull instancetype)cardWithNumber:(nullable NSString *)number expirationMonth:(nullable NSString *)expirationMonth expirationYear:(nonnull NSString *)expirationYear {
    return [self cardWithNumber:number expirationMonth:expirationMonth expirationYear:expirationMonth cvv:nil];
}

+ (nonnull instancetype)cardWithNumber:(nullable NSString *)number expirationMonth:(nullable NSString *)expirationMonth expirationYear:(nonnull NSString *)expirationYear cvv:(nullable NSString *)cvv {
    return [self cardWithNumber:number expirationDate:[NSString stringWithFormat:@"%@/%@", expirationMonth, expirationYear] cvv:cvv];
}

- (void)setAdditionalParameters:(NSDictionary<NSString *,NSString *> * __nullable)additionalParameters {
    [additionalParameters enumerateKeysAndObjectsUsingBlock:^(NSString * __nonnull key, NSString * __nonnull obj, __unused BOOL * __nonnull stop) {
        self.parameters[key] = obj;
    }];
}

@end
