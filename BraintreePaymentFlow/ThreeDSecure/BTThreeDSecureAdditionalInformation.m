#import "BTThreeDSecureAdditionalInformation_Internal.h"
#import "BTThreeDSecurePostalAddress_Internal.h"

@implementation BTThreeDSecureAdditionalInformation

- (NSDictionary *)asParameters {
    NSMutableDictionary *parameters = [@{} mutableCopy];

    [self insertIfExists:self.billingGivenName key:@"billingGivenName" dictionary:parameters];
    [self insertIfExists:self.billingSurname key:@"billingSurname" dictionary:parameters];
    [self insertIfExists:self.billingPhoneNumber key:@"billingPhoneNumber" dictionary:parameters];
    [self insertIfExists:self.email key:@"email" dictionary:parameters];
    [self insertIfExists:self.shippingMethod key:@"shippingMethod" dictionary:parameters];

    if (self.billingAddress) {
        [parameters addEntriesFromDictionary:[self.billingAddress asParameters]];
    }

    return [parameters copy];
}

- (void)insertIfExists:(NSString *)param key:(NSString *)key dictionary:(NSMutableDictionary *)dictionary{
    if (param != NULL) {
        dictionary[key] = param;
    }
}

@end
