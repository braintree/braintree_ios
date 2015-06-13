#import "BTPostalAddress_Internal.h"
#import "BTPostalAddress.h"

NSString *const BTPostalAddressKeyAccountAddress = @"accountAddress";
NSString *const BTPostalAddressKeyLocality = @"city";
NSString *const BTPostalAddressKeyCountry = @"country";
NSString *const BTPostalAddressKeyPostalCode = @"postalCode";
NSString *const BTPostalAddressKeyRegion= @"state";
NSString *const BTPostalAddressKeyStreetAddress = @"street1";
NSString *const BTPostalAddressKeyExtendedAddress = @"street2";

@implementation BTPostalAddress

// Property names follow the `Braintree_Address` convention as documented at:
// https://developers.braintreepayments.com/ios+php/reference/response/address

- (id)copyWithZone:(__unused NSZone *)zone {
    BTPostalAddress *address = [[BTPostalAddress alloc] init];
    address.streetAddress = self.streetAddress;
    address.extendedAddress = self.extendedAddress;
    address.locality = self.locality;
    address.countryCodeAlpha2 = self.countryCodeAlpha2;
    address.postalCode = self.postalCode;
    address.region = self.region;
    return address;
}

@end
