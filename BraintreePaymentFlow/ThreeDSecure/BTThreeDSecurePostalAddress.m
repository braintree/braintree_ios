#import "BTThreeDSecurePostalAddress_Internal.h"

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

    if (self.firstName) {
        [parameters setObject:self.firstName forKey:@"firstName"];
    }

    if (self.lastName) {
        [parameters setObject:self.lastName forKey:@"lastName"];
    }

    if (self.phoneNumber) {
        [parameters setObject:self.phoneNumber forKey:@"phoneNumber"];
    }

    if (self.streetAddress) {
        [parameters setObject:self.streetAddress forKey:@"line1"];
    }

    if (self.extendedAddress) {
        [parameters setObject:self.extendedAddress forKey:@"line2"];
    }

    if (self.locality) {
        [parameters setObject:self.locality forKey:@"city"];
    }

    if (self.region) {
        [parameters setObject:self.region forKey:@"state"];
    }

    if (self.postalCode) {
        [parameters setObject:self.postalCode forKey:@"postalCode"];
    }

    if (self.countryCodeAlpha2) {
        [parameters setObject:self.countryCodeAlpha2 forKey:@"countryCode"];
    }

    return [parameters copy];
}

- (NSString *)debugDescription {
    return [NSString stringWithFormat:@"<%@:%p \"%@\" %@, %@, %@, %@, %@, %@, %@ %@ %@>", NSStringFromClass([self class]), self, [self description], self.firstName, self.lastName, self.phoneNumber, self.streetAddress, self.extendedAddress, self.locality, self.region, self.postalCode, self.countryCodeAlpha2];
}

@end

