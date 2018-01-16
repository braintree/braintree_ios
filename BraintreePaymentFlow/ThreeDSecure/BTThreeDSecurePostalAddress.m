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

- (NSString *)debugDescription {
    return [NSString stringWithFormat:@"<%@:%p \"%@\" %@, %@, %@, %@, %@, %@, %@ %@ %@>", NSStringFromClass([self class]), self, [self description], self.firstName, self.lastName, self.phoneNumber, self.streetAddress, self.extendedAddress, self.locality, self.region, self.postalCode, self.countryCodeAlpha2];
}

@end

