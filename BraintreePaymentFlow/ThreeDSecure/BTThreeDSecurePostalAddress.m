#import "BTThreeDSecurePostalAddress.h"

@implementation BTThreeDSecurePostalAddress

// Property names follow the `Braintree_Address` convention as documented at:
// https://developers.braintreepayments.com/ios+php/reference/response/address

- (id)copyWithZone:(__unused NSZone *)zone {
    BTThreeDSecurePostalAddress *address = [[BTThreeDSecurePostalAddress alloc] init];
    address.firstName = self.firstName;
    address.lastName = self.lastName;
    address.phoneNumber = self.phoneNumber;
    address.streetAddress = self.streetAddress;
    address.extendedAddress = self.extendedAddress;
    address.locality = self.locality;
    address.countryCodeAlpha2 = self.countryCodeAlpha2;
    address.postalCode = self.postalCode;
    address.region = self.region;
    return address;
}

- (NSDictionary *)asParameters {
    NSMutableDictionary *parameters = [@{} mutableCopy];
    [parameters setValue:self.firstName forKey:@"firstName"];
    [parameters setValue:self.lastName forKey:@"lastName"];
    [parameters setValue:self.phoneNumber forKey:@"phoneNumber"];
    [parameters setValue:self.streetAddress forKey:@"line1"];
    [parameters setValue:self.extendedAddress forKey:@"line2"];
    [parameters setValue:self.locality forKey:@"city"];
    [parameters setValue:self.region forKey:@"state"];
    [parameters setValue:self.postalCode forKey:@"postalCode"];
    [parameters setValue:self.countryCodeAlpha2 forKey:@"countryCode"];
    return [parameters copy];
}

- (NSString *)debugDescription {
    return [NSString stringWithFormat:@"<%@:%p \"%@\" %@, %@, %@, %@, %@, %@, %@ %@ %@>", NSStringFromClass([self class]), self, [self description], self.firstName, self.lastName, self.phoneNumber, self.streetAddress, self.extendedAddress, self.locality, self.region, self.postalCode, self.countryCodeAlpha2];
}

@end

