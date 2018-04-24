#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Postal address for 3D Secure flows
 */
@interface BTThreeDSecurePostalAddress : NSObject <NSCopying>

/**
 Optional. First name associated with the address
 */
@property (nonatomic, nullable, copy) NSString *firstName;

/**
 Optional. Last name associated with the address
 */
@property (nonatomic, nullable, copy) NSString *lastName;

/**
 Optional. The phone number associated with the address
 @note Only numbers. Remove dashes, parentheses and other characters
 */
@property (nonatomic, nullable, copy) NSString *phoneNumber;

/**
 Optional. Line 1 of the Address (eg. number, street, etc)
 */
@property (nonatomic, nullable, copy) NSString *streetAddress;

/**
 Optional. Line 2 of the Address (eg. suite, apt #, etc.)
 */
@property (nonatomic, nullable, copy) NSString *extendedAddress;

/**
 Optional. City name
 */
@property (nonatomic, nullable, copy) NSString *locality;

/**
 Optional. 2 letter country code
 */
@property (nonatomic, nullable, copy) NSString *countryCodeAlpha2;

/**
 Optional. Zip code or equivalent is usually required for countries that have them. For a list of countries that do not have postal codes please refer to http://en.wikipedia.org/wiki/Postal_code
 */
@property (nonatomic, nullable, copy) NSString *postalCode;

/**
 Optional. 2 letter code for US states, and the equivalent for other countries
 */
@property (nonatomic, nullable, copy) NSString *region;

@end

NS_ASSUME_NONNULL_END

