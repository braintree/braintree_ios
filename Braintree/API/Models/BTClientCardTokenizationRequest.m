#import "BTClientCardTokenizationRequest.h"

@implementation BTClientCardTokenizationRequest

- (BOOL)shouldValidate {
    return NO;
}

- (NSDictionary *)parameters {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];

    [self safeSetObject:self.number toDictionary:parameters forKey:@"number"];
    [self safeSetObject:self.expirationMonth toDictionary:parameters forKey:@"expiration_month"];
    [self safeSetObject:self.expirationYear toDictionary:parameters forKey:@"expiration_year"];
    [self safeSetObject:self.expirationDate toDictionary:parameters forKey:@"expiration_date"];
    [self safeSetObject:self.cvv toDictionary:parameters forKey:@"cvv"];

    NSDictionary *options = @{ @"validate": @(self.shouldValidate) };
    [self safeSetObject:options toDictionary:parameters forKey:@"options"];

    if (self.postalCode) {
        NSDictionary *billingAddress = @{ @"postal_code": self.postalCode };
        [self safeSetObject:billingAddress toDictionary:parameters forKey:@"billing_address"];
    }

    if (self.additionalParameters) {
        [parameters addEntriesFromDictionary:self.additionalParameters];
    }

    return [parameters copy];
}

- (void)safeSetObject:(id)object toDictionary:(NSMutableDictionary *)dictionary forKey:(NSString *)key {
    if ([dictionary respondsToSelector:@selector(setObject:forKeyedSubscript:)] && key != nil && object != nil) {
        dictionary[key] = object;
    }
}


@end
