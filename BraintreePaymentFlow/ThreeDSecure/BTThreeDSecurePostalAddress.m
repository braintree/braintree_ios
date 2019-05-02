#import "BTThreeDSecurePostalAddress_Internal.h"

@implementation BTThreeDSecurePostalAddress

// Property names follow the `Braintree_Address` convention as documented at:
// https://developers.braintreepayments.com/ios+php/reference/response/address

- (void)setFirstName:(NSString *)firstName {
    _givenName = firstName;
}

- (NSString *)firstName {
    return _givenName;
}

- (void)setLastName:(NSString *)lastName {
    _surname = lastName;
}

- (NSString *)lastName {
    return _surname;
}

- (id)copyWithZone:(__unused NSZone *)zone {
    BTThreeDSecurePostalAddress *address = [[BTThreeDSecurePostalAddress alloc] init];
    address.givenName = self.givenName;
    address.surname = self.surname;
    address.phoneNumber = self.phoneNumber;
    address.streetAddress = self.streetAddress;
    address.extendedAddress = self.extendedAddress;
    address.locality = self.locality;
    address.countryCodeAlpha2 = self.countryCodeAlpha2;
    address.postalCode = self.postalCode;
    address.region = self.region;
    return address;
}

- (NSString *)prependPrefix:(NSString *)prefix toKey:(NSString *)key {
    if (prefix.length) {
        // Uppercase the first charachter in the key
        key = [key stringByReplacingCharactersInRange:NSMakeRange(0, 1)
                                           withString:[[key substringToIndex:1] uppercaseString]];
        return [NSString stringWithFormat:@"%@%@", prefix, key];
    }
    else {
        return key;
    }
}

- (NSDictionary *)asParametersWithPrefix:(NSString *)prefix {
    NSMutableDictionary *parameters = [@{} mutableCopy];

    if (self.givenName) {
        parameters[[self prependPrefix:prefix toKey:@"givenName"]] = self.givenName;
    }

    if (self.surname) {
        parameters[[self prependPrefix:prefix toKey:@"surname"]] = self.surname;
    }

    if (self.phoneNumber) {
        parameters[[self prependPrefix:prefix toKey:@"phoneNumber"]] = self.phoneNumber;
    }

    if (self.streetAddress) {
        parameters[[self prependPrefix:prefix toKey:@"line1"]] = self.streetAddress;
    }

    if (self.extendedAddress) {
        parameters[[self prependPrefix:prefix toKey:@"line2"]] = self.extendedAddress;
    }

    if (self.locality) {
        parameters[[self prependPrefix:prefix toKey:@"city"]] = self.locality;
    }

    if (self.region) {
        parameters[[self prependPrefix:prefix toKey:@"state"]] = self.region;
    }

    if (self.postalCode) {
        parameters[[self prependPrefix:prefix toKey:@"postalCode"]] = self.postalCode;
    }

    if (self.countryCodeAlpha2) {
        parameters[[self prependPrefix:prefix toKey:@"countryCode"]] = self.countryCodeAlpha2;
    }

    return [parameters copy];
}

- (NSDictionary *)asParameters {
    return [self asParametersWithPrefix:@""];
}

- (NSString *)debugDescription {
    return [NSString stringWithFormat:@"<%@:%p \"%@\" %@, %@, %@, %@, %@, %@, %@ %@ %@>", NSStringFromClass([self class]), self, [self description], self.givenName, self.surname, self.phoneNumber, self.streetAddress, self.extendedAddress, self.locality, self.region, self.postalCode, self.countryCodeAlpha2];
}

@end
