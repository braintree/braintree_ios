#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BTThreeDSecurePostalAddress : NSObject <NSCopying>

/**
 @brief Optional. First name associated with the address
 */
@property (nonatomic, nullable, copy) NSString *firstName;

/**
 @brief Optional. Last name associated with the address
 */
@property (nonatomic, nullable, copy) NSString *lastName;

/**
 @brief Optional. The phone number associated with the address
 @note Only numbers. Remove dashes, parentheses and other characters
 */
@property (nonatomic, nullable, copy) NSString *phoneNumber;

/**
 @brief Line 1 of the Address (eg. number, street, etc)
 */
@property (nonatomic, copy) NSString *streetAddress;

/**
 @brief Optional line 2 of the Address (eg. suite, apt #, etc.)
 */
@property (nonatomic, nullable, copy) NSString *extendedAddress;

/**
 @brief City name
 */
@property (nonatomic, copy) NSString *locality;

/**
 @brief 2 letter country code
 */
@property (nonatomic, copy) NSString *countryCodeAlpha2;

/**
 @brief Zip code or equivalent is usually required for countries that have them. For list of countries that do not have postal codes please refer to http://en.wikipedia.org/wiki/Postal_code
 */
@property (nonatomic, nullable, copy) NSString *postalCode;

/**
 @brief 2 letter code for US states, and the equivalent for other countries
 */
@property (nonatomic, nullable, copy) NSString *region;

@end

NS_ASSUME_NONNULL_END

