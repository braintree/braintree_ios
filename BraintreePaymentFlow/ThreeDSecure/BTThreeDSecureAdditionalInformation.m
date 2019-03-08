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
        // TODO billing line 3?
        [self insertIfExists:self.billingAddress.streetAddress key:@"billingLine1" dictionary:parameters];
        [self insertIfExists:self.billingAddress.extendedAddress key:@"billingLine2" dictionary:parameters];
        [self insertIfExists:self.billingAddress.locality key:@"billingCity" dictionary:parameters];
        [self insertIfExists:self.billingAddress.region key:@"billingState" dictionary:parameters];
        [self insertIfExists:self.billingAddress.postalCode key:@"billingPostalCode" dictionary:parameters];
        [self insertIfExists:self.billingAddress.countryCodeAlpha2 key:@"billingCountryCode" dictionary:parameters];
    }

    return [parameters copy];
}

- (void)insertIfExists:(NSString *)param key:(NSString *)key dictionary:(NSMutableDictionary *)dictionary{
    if (param != nil && key != nil && dictionary != nil) {
        dictionary[key] = param;
    }
}

@end
