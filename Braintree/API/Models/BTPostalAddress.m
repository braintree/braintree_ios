#import "BTPostalAddress_Internal.h"
#import "BTPostalAddress.h"

// Future Payments
NSString *const BTPostalAddressKeyAccountAddress = @"accountAddress";
NSString *const BTPostalAddressKeyCity = @"city";
NSString *const BTPostalAddressKeyCountry = @"country";
NSString *const BTPostalAddressKeyPostalCode = @"postalCode";
NSString *const BTPostalAddressKeyState = @"state";
NSString *const BTPostalAddressKeyStreet1 = @"street1";
NSString *const BTPostalAddressKeyStreet2 = @"street2";

// Single Payment
NSString *const BTPostalAddressKeyBillingAddress = @"billingAddress";
NSString *const BTPostalAddressKeyShippingAddress = @"shippingAddress";
NSString *const BTPostalAddressKeyRecipientName = @"recipientName";
//NSString *const BTPostalAddressKeyCity = @"city"; // Same as Future Payments
NSString *const BTPostalAddressKeyCountryCode = @"countryCode";
//NSString *const BTPostalAddressKeyPostalCode = @"postalCode"; // Same as Future Payments
//NSString *const BTPostalAddressKeyState = @"state"; // Same as Future Payments
NSString *const BTPostalAddressKeyLine1 = @"line1";
NSString *const BTPostalAddressKeyLine2 = @"line2";

@implementation BTPostalAddress

// Property names follow the `Braintree_Address` convention as documented at:
// https://developers.braintreepayments.com/ios+php/reference/response/address

- (id)copyWithZone:(__unused NSZone *)zone {
    BTPostalAddress *address = [[BTPostalAddress alloc] init];
    address.recipientName = self.recipientName;
    address.streetAddress = self.streetAddress;
    address.extendedAddress = self.extendedAddress;
    address.locality = self.locality;
    address.countryCodeAlpha2 = self.countryCodeAlpha2;
    address.postalCode = self.postalCode;
    address.region = self.region;
    return address;
}

- (NSString *)debugDescription {
    return [NSString stringWithFormat:@"<%@:%p \"%@\" %@, %@, %@, %@, %@ %@ %@>", NSStringFromClass([self class]), self, [self description], self.recipientName, self.streetAddress, self.extendedAddress, self.locality, self.region, self.postalCode, self.countryCodeAlpha2];
}

@end
