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

- (NSString *)street1 {
    return self.rawDictionary[BTPostalAddressKeyStreet1];
}

- (NSString *)street2 {
    return self.rawDictionary[BTPostalAddressKeyStreet2];
}

- (NSString *)city {
    return self.rawDictionary[BTPostalAddressKeyCity];
}

- (NSString *)country {
    return self.rawDictionary[BTPostalAddressKeyCounty];
}

- (NSString *)postalCode {
    return self.rawDictionary[BTPostalAddressKeyPostalCode];
}

- (NSString *)state {
    return self.rawDictionary[BTPostalAddressKeyState];
}

@end
