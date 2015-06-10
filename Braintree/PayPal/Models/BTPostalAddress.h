#import <Foundation/Foundation.h>

/// Keys for PostalAddress
extern NSString *const BTPostalAddressKeyAccountAddress;
extern NSString *const BTPostalAddressKeyCity;
extern NSString *const BTPostalAddressKeyCounty;
extern NSString *const BTPostalAddressKeyPostalCode;
extern NSString *const BTPostalAddressKeyState;
extern NSString *const BTPostalAddressKeyStreet1;
extern NSString *const BTPostalAddressKeyStreet2;

@interface BTPostalAddress : NSObject

/// Create a postal address object from a dictionary.
+ (instancetype)addressWithDictionary:(NSDictionary *)rawDictionary;

/// Line 1 of the Address (eg. number, street, etc).
- (NSString *)street1;

/// Optional line 2 of the Address (eg. suite, apt #, etc.).
- (NSString *)street2;

/// City name.
- (NSString *)city;

/// 2 letter country code.
- (NSString *)country;

/// Zip code or equivalent is usually required for countries that have them. For list of countries that do not have postal codes please refer to http://en.wikipedia.org/wiki/Postal_code.
- (NSString *)postalCode;

/// 2 letter code for US states, and the equivalent for other countries.
- (NSString *)state;

/// Raw data dictionary.
- (NSDictionary *)rawDictionary;

@end
