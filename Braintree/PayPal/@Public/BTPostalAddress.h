#import <Foundation/Foundation.h>

@interface BTPostalAddress : NSObject <NSCopying>

/// Create a postal address object from a dictionary.
+ (instancetype)addressWithDictionary:(NSDictionary *)rawDictionary;

/// Line 1 of the Address (eg. number, street, etc).
- (NSString *)streetAddress;

/// Optional line 2 of the Address (eg. suite, apt #, etc.).
- (NSString *)extendedAddress;

/// City name.
- (NSString *)locality;

/// 2 letter country code.
- (NSString *)countryCodeAlpha2;

/// Zip code or equivalent is usually required for countries that have them. For list of countries that do not have postal codes please refer to http://en.wikipedia.org/wiki/Postal_code.
- (NSString *)postalCode;

/// 2 letter code for US states, and the equivalent for other countries.
- (NSString *)region;

@end
