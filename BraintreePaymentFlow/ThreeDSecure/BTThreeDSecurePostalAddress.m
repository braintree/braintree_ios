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
        parameters[@"billingGivenName"] = self.firstName;
    }

    if (self.lastName) {
        parameters[@"billingSurname"] = self.lastName;
    }

    if (self.phoneNumber) {
        parameters[@"billingPhoneNumber"] = self.phoneNumber;
    }

    if (self.streetAddress) {
        parameters[@"billingLine1"] = self.streetAddress;
    }

    if (self.extendedAddress) {
        parameters[@"billingLine2"] = self.extendedAddress;
    }

    if (self.locality) {
        parameters[@"billingCity"] = self.locality;
    }

    if (self.region) {
        parameters[@"billingState"] = self.region;
    }

    if (self.postalCode) {
        parameters[@"billingPostalCode"] = self.postalCode;
    }

    if (self.countryCodeAlpha2) {
        parameters[@"billingCountryCode"] = self.countryCodeAlpha2;
    }

    return [parameters copy];
}

- (NSString *)debugDescription {
    return [NSString stringWithFormat:@"<%@:%p \"%@\" %@, %@, %@, %@, %@, %@, %@ %@ %@>", NSStringFromClass([self class]), self, [self description], self.firstName, self.lastName, self.phoneNumber, self.streetAddress, self.extendedAddress, self.locality, self.region, self.postalCode, self.countryCodeAlpha2];
}

@end

