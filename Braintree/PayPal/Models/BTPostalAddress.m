#import "BTPostalAddress.h"

NSString *const BTPostalAddressKeyAccountAddress = @"accountAddress";
NSString *const BTPostalAddressKeyCity = @"city";
NSString *const BTPostalAddressKeyCounty = @"country";
NSString *const BTPostalAddressKeyPostalCode = @"postalCode";
NSString *const BTPostalAddressKeyState = @"state";
NSString *const BTPostalAddressKeyStreet1 = @"street1";
NSString *const BTPostalAddressKeyStreet2 = @"street2";

@interface BTPostalAddress ()
@property (nonatomic, copy) NSDictionary *rawDictionary;
@end

@implementation BTPostalAddress

+ (instancetype)addressWithDictionary:(NSDictionary *)rawDictionary {
    BTPostalAddress *address = [[BTPostalAddress alloc] init];
    address.rawDictionary = rawDictionary;
    return address;
}

// Method names follow the `Braintree_Address` convention as documented at:
// https://developers.braintreepayments.com/ios+php/reference/response/address

- (NSString *)streetAddress {
    return self.rawDictionary[BTPostalAddressKeyStreet1];
}

- (NSString *)extendedAddress {
    return self.rawDictionary[BTPostalAddressKeyStreet2];
}

- (NSString *)locality {
    return self.rawDictionary[BTPostalAddressKeyCity];
}

- (NSString *)countryCodeAlpha2 {
    return self.rawDictionary[BTPostalAddressKeyCounty];
}

- (NSString *)postalCode {
    return self.rawDictionary[BTPostalAddressKeyPostalCode];
}

- (NSString *)region {
    return self.rawDictionary[BTPostalAddressKeyState];
}

- (id)copyWithZone:(__unused NSZone *)zone {
    return [BTPostalAddress addressWithDictionary:self.rawDictionary];
}

@end
